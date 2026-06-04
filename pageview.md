# Article Detail Page → PageView Migration Plan

> **Goal**: Replace the scrollable `CustomScrollView` with a paginated `PageView` for a book-like reading experience. Production-grade, annotation-system compatible.

---

## 1. Architecture Overview

```
Before:
  DetailPage
    └── CustomScrollView (slivers)
          ├── SliverToBoxAdapter → DetailHeroImage
          ├── SliverToBoxAdapter → ContentHeader
          └── AnnotatedChunkList (SliverList of SelectableText segments)

After:
  DetailPage
    └── PageView.builder
          ├── Page 0:
          │     ├── DetailHeroImage
          │     ├── ContentHeader
          │     └── SegmentGroup (batch of SelectableText segments)
          ├── Page 1:
          │     └── SegmentGroup (next batch)
          ├── Page 2:
          │     └── SegmentGroup (next batch)
          └── ...
```

### Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Hero visible on | Page 0 only | Matches book chapter-opening design |
| Page height | Full viewport (screen - nav bar - page indicator) | No scrolling within a page |
| Pagination trigger | `fontSize` or `lineHeight` change | Settings change → recalculate all pages |
| Page indicator | Bottom-center, translucent overlay | Minimal obstruction |

---

## 2. How Pagination Works

### 2.1 Height Estimation with TextPainter

We use `TextPainter` to measure segment heights BEFORE building widgets. This is accurate and fast — no trial-and-error layout needed.

```dart
double measureSegmentHeight(String text, TextStyle style, double maxWidth) {
  final tp = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    maxLines: null, // no limit
  );
  tp.layout(maxWidth: maxWidth);
  return tp.height;
}
```

### 2.2 Page Assignment Algorithm

```dart
List<PageSlice> paginate({
  required List<MarkdownSegment> allSegments,
  required double pageHeight,
  required double pageWidth,
  required double fontSize,
  required double lineHeight,
  required bool hasHero, // true for page 0
}) {
  final slices = <PageSlice>[];
  double remaining = pageHeight;

  // Page 0: subtract hero + header heights
  if (hasHero) {
    remaining -= heroHeight;     // ~240 px
    remaining -= headerHeight;   // ~120 px (varies)
  }

  int segmentIndex = 0;
  List<int> currentSliceSegmentIndices = [];

  while (segmentIndex < allSegments.length) {
    final seg = allSegments[segmentIndex];
    final segHeight = measureSegmentHeight(
      seg.text, buildTextStyle(seg.style, fontSize, lineHeight), pageWidth);

    if (segHeight <= remaining || currentSliceSegmentIndices.isEmpty) {
      // Segment fits (or it's the first on the page — always include at least one)
      currentSliceSegmentIndices.add(segmentIndex);
      remaining -= segHeight;
      segmentIndex++;
    } else {
      // Segment doesn't fit → start new page
      slices.add(PageSlice(
        segmentIndices: List.from(currentSliceSegmentIndices),
        isFirstPage: slices.isEmpty,
      ));
      currentSliceSegmentIndices = [];
      remaining = pageHeight;
    }
  }

  // Flush last page
  if (currentSliceSegmentIndices.isNotEmpty) {
    slices.add(PageSlice(
      segmentIndices: List.from(currentSliceSegmentIndices),
      isFirstPage: slices.isEmpty,
    ));
  }

  return slices;
}
```

### 2.3 When to Re-paginate

| Trigger | Action |
|---------|--------|
| Article first loaded | Parse markdown → calculate pages |
| `settingsService.notifyListeners` (fontSize/lineHeight/fontFamily change) | Recalculate all pages |
| Screen rotation | `MediaQuery` → `didChangeMetrics` → recalculate |
| Same article, same settings | Cache page slices (no recalculation) |

---

## 3. Data Model

### 3.1 PageSlice

```dart
class PageSlice {
  final List<int> segmentIndices; // indices into the full segment list
  final bool isFirstPage;         // true → include hero + header

  const PageSlice({
    required this.segmentIndices,
    required this.isFirstPage,
  });
}
```

### 3.2 ReadingProgress (modified)

```dart
class ReadingProgress {
  final String blogId;
  final int pageIndex;       // NEW: replaces scrollOffset
  final int totalPages;      // NEW: total page count
  final double progress;     // pageIndex / totalPages
  final String blogTitle;
  final String? coverImg;
  final DateTime updatedAt;
}
```

---

## 4. File Changes

### New Files

| File | Lines (est.) | Responsibility |
|------|-------------|----------------|
| `lib/pages/detail/services/page_calculator.dart` | ~120 | `TextPainter`-based height measurement + `paginate()` |
| `lib/pages/detail/widgets/page_content.dart` | ~80 | Renders one page: hero+header+segments or just segments |
| `lib/pages/detail/widgets/page_reader.dart` | ~150 | `PageView.builder` + page indicator + navigation callbacks |

### Modified Files

| File | Changes |
|------|---------|
| `lib/pages/detail/detail_page.dart` | Remove `CustomScrollView` + `_scrollController`, add `PageController` + page state. Wire `page_calculator`. |
| `lib/models/reading_progress.dart` | `scrollOffset` → `pageIndex` + `totalPages` |
| `lib/services/reading_progress_service.dart` | Adapt save/restore to page indices |
| `lib/utils/markdown_chunker.dart` | Remove chunking — we now parse entire markdown at once |
| `lib/pages/detail/widgets/markdown_ast.dart` | No change (already handles full markdown) |
| `lib/pages/detail/widgets/annotated_chunk_list.dart` | Deprecated: replaced by `page_content.dart`. Keep file for reference. |

### Deleted Files

| File | Reason |
|------|--------|
| `lib/pages/detail/widgets/annotated_chunk_list.dart` | Replaced by page-based rendering |

---

## 5. UI Layout

### Page 0 (First Page)
```
┌─────────────────────────────────┐
│  Navigation Bar                  │
├─────────────────────────────────┤
│  ┌───────────────────────────┐  │
│  │     Hero Image (240px)    │  │
│  └───────────────────────────┘  │
│  Content Header                  │
│    Tag · Title · Author · Date   │
│  ─────────────────────────────   │
│  Segments (batch 0)              │
│    Paragraph 1 text...           │
│    Paragraph 2 text...           │
│                                  │
│                           [1/8]  │  ← page indicator
└─────────────────────────────────┘
```

### Page N (Content Page)
```
┌─────────────────────────────────┐
│  Navigation Bar                  │
├─────────────────────────────────┤
│  Segments (batch N)              │
│    Heading 2 text...             │
│    Paragraph text...             │
│    Blockquote text...            │
│                                  │
│                                  │
│                           [3/8]  │
└─────────────────────────────────┘
```

### Page Indicator
```dart
Positioned(
  bottom: 16,
  left: 0,
  right: 0,
  child: Center(
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${currentPage + 1} / $totalPages',
        style: TextStyle(color: Colors.white70, fontSize: 13),
      ),
    ),
  ),
)
```

---

## 6. Annotation System Impact: NONE

Annotations use **text-based matching** (committed in `968dc2a`). The `_buildAnnotatedSpans` function does `text.indexOf(annotation.selectedText)` — it doesn't care about page boundaries, scroll position, or layout. Annotations will work identically on any page.

**No changes required** to:
- `Annotation` model
- `AnnotationStore`
- `_buildAnnotatedSpans`
- Selection context menu (`_buildMenu`)
- `annotation_summary_page.dart`
- `global_annotations_page.dart`

Each `SelectableText` on each page independently handles its own selection and annotation rendering.

---

## 7. Implementation Steps (8 steps)

### Step 1: Reading Progress Migration

**File:** `lib/models/reading_progress.dart`

Change `scrollOffset` → `pageIndex` + `totalPages`:
```dart
class ReadingProgress {
  final String blogId;
  final int pageIndex;    // was: double scrollOffset
  final int totalPages;   // NEW
  final double progress;  // was: calculated from scroll; now: pageIndex / totalPages
  final String blogTitle;
  final String? coverImg;
  final DateTime updatedAt;
}
```

**File:** `lib/services/reading_progress_service.dart`

Replace `scrollOffset` save/restore with `pageIndex`:
```dart
// Save
prefs.setInt('progress_${p.blogId}_page', p.pageIndex);
// Restore
final page = prefs.getInt('progress_${blogId}_page') ?? 0;
```

### Step 2: Page Calculator

**Create:** `lib/pages/detail/services/page_calculator.dart`

- `measureSegmentHeight(seg, style, maxWidth)` → `double`
- `paginate(segments, pageHeight, pageWidth, settings)` → `List<PageSlice>`
- `buildTextStyle(seg, settings)` → `TextStyle` (matching `_buildSegment` in annotated_chunk_list)

### Step 3: Page Content Widget

**Create:** `lib/pages/detail/widgets/page_content.dart`

```dart
class PageContent extends StatelessWidget {
  final PageSlice slice;
  final CardItem? blog;              // only for first page
  final List<MarkdownSegment> allSegments;
  final ReaderSettingsService settings;
  final AnnotationStore annotationStore;
  final AnnotationCallback onAnnotate;
  final void Function(String, int, int)? onAddNote;
  final void Function(String, int, int)? onPoster;

  // Page 0: render hero + header + segments
  // Page 1+: render segments only
}
```

### Step 4: Page Reader Wrapper

**Create:** `lib/pages/detail/widgets/page_reader.dart`

```dart
class PageReader extends StatefulWidget {
  // Wraps PageView.builder + page indicator
  // Exposes PageController for external navigation
}

class _PageReaderState extends State<PageReader> {
  late PageController _controller;
  int _currentPage = 0;

  // onPageChanged → update currentPage + save progress
  // settingsService listener → recalculate pages
}
```

### Step 5: Replace CustomScrollView in DetailPage

**Modify:** `lib/pages/detail/detail_page.dart`

- Remove `_scrollController`, related listeners, `_onScroll`, `_saveProgress`
- Remove `MarkdownChunker.chunk()` — pass full markdown to `parseMarkdownToSegments`
- Add `PageController _pageController`
- Replace `_buildBody`:
  ```dart
  // Before:
  return SafeArea(child: CustomScrollView(controller: _scrollController, slivers: [...]));
  
  // After:
  return PageReader(
    controller: _pageController,
    slices: _slices,
    allSegments: _allSegments,
    blog: _blog,
    settingsService: widget.settingsService,
    annotationStore: _annotationStore,
    onAnnotate: _onAnnotate,
    onAddNote: _onAddNoteCallback,
    onPoster: _onPosterCallback,
  );
  ```
- Add `_calculatePages()` method that calls `paginate()` and rebuilds on settings change
- Save progress: `pageIndex` instead of `scrollOffset`

### Step 6: Deprecate AnnotatedChunkList

- Remove import and usage of `annotated_chunk_list.dart`
- Keep file on disk for git history; mark as deprecated in comment

### Step 7: Test

- Widget test: `PageReader` renders pages, page indicator correct
- Integration: annotations persist across page turns
- Settings: font size change triggers re-pagination
- Progress: page index saved/restored correctly

### Step 8: Polish

- Page turn animation: `PageView` with `CupertinoPageRoute`-style slide
- Preload adjacent pages: `PageView` default behavior caches ±1 page
- Long segment that doesn't fit on a single page: split across pages (edge case handling)
- First page height calculation must account for hero + header (subtract from `pageHeight`)

---

## 8. Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| `TextPainter` height estimate differs from actual `SelectableText` height | Page overflow / underflow | Add 2px tolerance per segment; run integration test with real articles |
| Very long code block doesn't fit one page | Content clipped | Split long code blocks across pages (special handling in paginate) |
| `fontFamily` change affects glyph metrics | Re-pagination needed | Already handled: `settingsService` listener triggers recalculation |
| First page hero+header takes >50% of page | Awkward layout | Minimum 3 segments on first page; if hero+header > 60% height, skip header |
| Large article (100+ pages) → slow initial render | User waits | Build pages lazily: only calculate slices for current ±2 pages; lazy-expand as user navigates |
| `ReadingProgress` backward compatibility | Old progress data lost | Migration: if `pageIndex` key not found, fall back to `scrollOffset` key and reset to page 0 |

---

## 9. Estimated Effort

| Category | Lines |
|----------|-------|
| `page_calculator.dart` | ~120 |
| `page_content.dart` | ~80 |
| `page_reader.dart` | ~150 |
| Detail page refactor | ~100 (diff: delete old, add new) |
| Progress model + service | ~30 |
| Tests | ~100 |
| **Total new/changed code** | **~580** |
| **Total files** | 3 new, 3 modified, 1 deprecated |
