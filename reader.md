# Reader Annotation & Comment System — Implementation Plan

> **Target**: Production-grade annotation system for the Flutter reader (detail page).
> Supports text highlighting, underlining, inline comments, annotation export, and PNG poster generation.

---

## 1. Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                     DetailPage                          │
│  ┌───────────────────────────────────────────────────┐ │
│  │              AnnotationStore (ChangeNotifier)      │ │
│  │  - annotations: List<Annotation>                  │ │
│  │  - load(blogId) / add() / update() / delete()     │ │
│  │  - persist to shared_preferences (JSON)           │ │
│  └───────────────────────────────────────────────────┘ │
│                         │                              │
│  ┌──────────────────────▼────────────────────────────┐ │
│  │            AnnotatedChunkList                      │ │
│  │  markdown → AST → List<TextSpan>                   │ │
│  │  each span checked against AnnotationStore         │ │
│  │  → apply highlight / underline / comment badge     │ │
│  └───────────────────────────────────────────────────┘ │
│                         │                              │
│  ┌──────────────────────▼────────────────────────────┐ │
│  │         SelectionArea (contextMenuBuilder)         │ │
│  │  Copy | Highlight | Underline | Note | Poster      │ │
│  └───────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### Data Flow

```
User selects text → context menu appears
  ├─ "高亮" → AnnotationStore.add(type: highlight, color: yellow)
  ├─ "下划线" → AnnotationStore.add(type: underline, color: red)
  ├─ "笔记" → open note input dialog → AnnotationStore.add(note: "用户输入")
  └─ "海报" → open poster preview sheet → save PNG to gallery

AnnotationStore notifies → AnnotatedChunkList rebuilds → highlights visible
Tap existing annotation → annotation popup (edit/delete)
```

---

## 2. Data Model

### `lib/models/annotation.dart`

```dart
enum AnnotationType { highlight, underline }

class Annotation {
  final String id;           // uuid
  final String blogId;       // belongs to which article
  final int startOffset;     // character offset in plain text
  final int endOffset;
  final String selectedText; // the actual text (for display & dedup)
  final AnnotationType type;
  final int color;           // 0xAARRGGBB
  final String? note;        // user's comment (nullable)
  final DateTime createdAt;
  final DateTime updatedAt;

  const Annotation({...});

  // JSON serialization for shared_preferences
  Map<String, dynamic> toJson();
  factory Annotation.fromJson(Map<String, dynamic> json);
}
```

### Color Presets

```dart
class AnnotationColors {
  static const int yellow    = 0x80FFEB3B;  // 黄色荧光笔
  static const int green     = 0x804CAF50;  // 绿色
  static const int blue      = 0x802196F3;  // 蓝色
  static const int pink      = 0x80E91E63;  // 粉色
  static const int orange    = 0x80FF9800;  // 橙色

  // Underline colors (opaque)
  static const int red       = 0xFFE53935;
  static const int black     = 0xFF1D1D1F;

  static const List<int> highlightColors = [yellow, green, blue, pink, orange];
  static const List<int> underlineColors = [red, black];
}
```

---

## 3. Annotation Store

### `lib/services/annotation_store.dart`

```dart
class AnnotationStore extends ChangeNotifier {
  static const _prefix = 'annotations_';

  List<Annotation> _annotations = [];
  String? _blogId;

  List<Annotation> get annotations => _annotations;

  /// Load annotations for a blog from shared_preferences.
  Future<void> load(String blogId) async { ... }

  /// Add a new annotation. Auto-generates id and timestamps.
  Future<void> add({
    required String selectedText,
    required int startOffset,
    required int endOffset,
    required AnnotationType type,
    required int color,
    String? note,
  }) async { ... }

  /// Update an existing annotation (e.g., change color or edit note).
  Future<void> update(String id, {int? color, String? note}) async { ... }

  /// Delete an annotation by id.
  Future<void> delete(String id) async { ... }

  /// Get all annotations that intersect a given offset range.
  List<Annotation> annotationsInRange(int start, int end) => ...

  /// Persist to disk.
  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final json = _annotations.map((a) => a.toJson()).toList();
    await prefs.setString('$_prefix$_blogId', jsonEncode(json));
  }
}
```

**Persistence format** (stored in `shared_preferences`):
```
Key:   annotations_<blogId>
Value: '[{"id":"uuid1","startOffset":42,"endOffset":89,...}, ...]'
```

---

## 4. Markdown-to-Annotated-Text Rendering

This is the **core engineering challenge**. We replace `MarkdownBody` with a custom pipeline.

### 4.1 Pipeline

```
Markdown String
  │
  ▼
markdown.Document (AST)        ← parse with `markdown` package
  │
  ▼
List<MarkdownSegment>          ← flatten AST nodes
  │  - MarkdownSegment.text
  │  - MarkdownSegment.style (bold/italic/heading/code/blockquote)
  │  - MarkdownSegment.isBlock
  │
  ▼
List<TextSpan>                 ← build Flutter spans
  │  - apply markdown styles (fontSize, fontWeight, etc.)
  │  - query AnnotationStore for overlapping annotations
  │  - wrap annotated ranges with background color / underline
  │
  ▼
SelectableText.rich(           ← render
  TextSpan(children: spans),
  contextMenuBuilder: ...,
)
```

### 4.2 MarkdownSegment

```dart
enum MarkdownStyle {
  body, h1, h2, h3, bold, italic, code, blockquote
}

class MarkdownSegment {
  final String text;
  final MarkdownStyle style;
  final bool isBlock; // true if this segment ends a block (adds newline spacing)

  // Offset tracking for annotation alignment
  int globalOffset; // start position in the concatenated plain text
}
```

### 4.3 AST Flattener

```dart
/// Recursively walks the markdown AST and produces a flat list of
/// [MarkdownSegment]s with accurate global offset tracking.
List<MarkdownSegment> flattenAst(markdown.Node root) {
  final segments = <MarkdownSegment>[];
  int offset = 0;

  void walk(markdown.Node node, MarkdownStyle inheritedStyle) {
    if (node is markdown.Text) {
      final style = _resolveStyle(node, inheritedStyle);
      segments.add(MarkdownSegment(
        text: node.text,
        style: style,
        isBlock: false,
        globalOffset: offset,
      ));
      offset += node.text.length;
    }
    // Recurse into children
    for (final child in node.children ?? []) {
      walk(child, inheritedStyle);
    }
    // After block elements, add block spacing signal
    if (_isBlockNode(node)) {
      segments.last.isBlock = true;
    }
  }

  walk(root, MarkdownStyle.body);
  return segments;
}
```

### 4.4 Span Builder with Annotations

```dart
TextSpan buildAnnotatedSpan({
  required List<MarkdownSegment> segments,
  required AnnotationStore store,
  required ReaderSettingsService settings,
}) {
  final s = settings;
  final isDark = s.backgroundColor == 'dark';
  final textColor = isDark ? AppColors.onDark : AppColors.ink;
  final spans = <InlineSpan>[];

  for (final seg in segments) {
    final start = seg.globalOffset;
    final end = start + seg.text.length;

    // Find annotations overlapping this segment
    final anns = store.annotationsInRange(start, end);

    if (anns.isEmpty) {
      // No annotation — plain styled text
      spans.add(TextSpan(
        text: seg.text,
        style: _textStyleFor(seg.style, s, textColor),
      ));
    } else {
      // Build annotated span with highlight/underline layers
      spans.add(_buildAnnotatedText(seg, anns, start, s, textColor));
    }
  }

  return TextSpan(children: spans);
}

InlineSpan _buildAnnotatedText(
  MarkdownSegment seg,
  List<Annotation> annotations,
  int segStart,
  ReaderSettingsService s,
  Color textColor,
) {
  // For overlapping annotations, apply multiple decorations
  var span = TextSpan(
    text: seg.text,
    style: _textStyleFor(seg.style, s, textColor),
  ) as InlineSpan;

  for (final ann in annotations) {
    if (ann.type == AnnotationType.highlight) {
      span = TextSpan(
        children: [span],
        style: TextStyle(backgroundColor: Color(ann.color)),
      );
    } else if (ann.type == AnnotationType.underline) {
      span = TextSpan(
        children: [span],
        style: TextStyle(
          decoration: TextDecoration.underline,
          decorationColor: Color(ann.color),
          decorationThickness: 2,
        ),
      );
    }
  }

  // Add comment badge if annotation has a note
  final noteAnn = annotations.firstWhereOrNull((a) => a.note != null);
  if (noteAnn != null) {
    return WidgetSpan(
      child: _AnnotationBadge(annotation: noteAnn, child: span),
    );
  }

  return span;
}
```

### 4.5 Comment Badge Widget

```dart
/// A small inline badge that appears after annotated text with a comment.
/// Shows a speech-bubble icon. Tap to view/edit the note.
class _AnnotationBadge extends StatelessWidget {
  final Annotation annotation;
  final InlineSpan child;

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showNotePopup(context, annotation),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text.rich(child),
          const SizedBox(width: 2),
          Icon(CupertinoIcons.text_bubble, size: 14,
               color: AppColors.primary),
        ],
      ),
    );
  }
}
```

---

## 5. Selection Context Menu

### `lib/pages/detail/widgets/selection_menu.dart`

Use `SelectionArea` wrapping the content, with a custom `contextMenuBuilder`:

```dart
SelectionArea(
  contextMenuBuilder: (context, editableTextState) {
    return AdaptiveTextSelectionToolbar(
      anchors: editableTextState.contextMenuAnchors,
      children: [
        // System buttons
        _MenuButton(label: '复制', icon: CupertinoIcons.doc_on_doc,
          onTap: () => editableTextState.copySelection(...)),
        _MenuButton(label: '全选', icon: CupertinoIcons.selection_pin_in,
          onTap: () => editableTextState.selectAll(...)),

        const SizedBox(width: 8), // divider

        // Annotation buttons
        _MenuButton(label: '高亮', icon: CupertinoIcons.highlighter,
          onTap: () => _onHighlight(context, editableTextState)),
        _MenuButton(label: '下划线', icon: CupertinoIcons.underline,
          onTap: () => _onUnderline(context, editableTextState)),
        _MenuButton(label: '笔记', icon: CupertinoIcons.text_bubble,
          onTap: () => _onAddNote(context, editableTextState)),

        const SizedBox(width: 8),

        _MenuButton(label: '海报', icon: CupertinoIcons.photo,
          onTap: () => _onGeneratePoster(context, editableTextState)),
      ],
    );
  },
  child: CustomScrollView(...),
)
```

### Action Handlers

```dart
void _onHighlight(BuildContext context, EditableTextState state) {
  final text = state.textEditingValue.selection.textInside(...);
  final range = state.textEditingValue.selection;
  // Show color picker sheet → then add annotation
  _showColorPicker(context, AnnotationType.highlight).then((color) {
    if (color != null) {
      annotationStore.add(
        selectedText: text,
        startOffset: range.start,
        endOffset: range.end,
        type: AnnotationType.highlight,
        color: color,
      );
    }
  });
}

void _onAddNote(BuildContext context, EditableTextState state) {
  final text = state.textEditingValue.selection.textInside(...);
  _showNoteInput(context, prefill: text).then((note) {
    if (note != null && note.isNotEmpty) {
      annotationStore.add(
        selectedText: text,
        startOffset: range.start,
        endOffset: range.end,
        type: AnnotationType.highlight,
        color: AnnotationColors.yellow,
        note: note,
      );
    }
  });
}
```

---

## 6. Annotation Popup (Edit / Delete)

When the user taps an existing annotation (highlighted text or comment badge):

```dart
void _showAnnotationPopup(BuildContext context, Annotation ann) {
  showCupertinoModalPopup(
    context: context,
    builder: (_) => CupertinoActionSheet(
      title: Text(ann.selectedText, maxLines: 2, overflow: TextOverflow.ellipsis),
      message: ann.note != null ? Text('📝 ${ann.note}') : null,
      actions: [
        CupertinoActionSheetAction(
          onPressed: () { /* Change color */ },
          child: const Text('更换颜色'),
        ),
        CupertinoActionSheetAction(
          onPressed: () { /* Edit note */ },
          child: Text(ann.note != null ? '编辑笔记' : '添加笔记'),
        ),
        CupertinoActionSheetAction(
          onPressed: () { /* Generate poster from this annotation */ },
          child: const Text('生成海报'),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () {
            annotationStore.delete(ann.id);
            Navigator.pop(context);
          },
          child: const Text('删除标记'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(context),
        child: const Text('取消'),
      ),
    ),
  );
}
```

---

## 7. PNG Poster Generation

### `lib/pages/detail/widgets/poster_generator.dart`

```dart
class PosterGenerator {
  /// Generate a PNG poster from annotation or selected text.
  /// Returns the image bytes.
  static Future<Uint8List> generate({
    required String quote,
    required String articleTitle,
    required String authorName,
    required String date,
    int? highlightColor,
  }) async {
    // 1. Build a widget tree
    final widget = _PosterWidget(
      quote: quote,
      title: articleTitle,
      author: authorName,
      date: date,
      highlightColor: highlightColor,
    );

    // 2. Render to image via RepaintBoundary
    final boundaryKey = GlobalKey();
    final element = RenderRepaintBoundary();
    // ... pump widget offscreen, capture with boundaryKey ...

    // 3. Convert to PNG bytes
    final image = await boundaryKey.currentContext!.findRenderObject()!
        .toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// Save PNG bytes to phone gallery.
  static Future<void> saveToGallery(Uint8List bytes) async {
    // Request storage permission
    final status = await Permission.storage.request();
    if (!status.isGranted) throw Exception('需要存储权限');

    // Save
    final result = await ImageGallerySaver.saveImage(bytes,
      name: 'readmeet_${DateTime.now().millisecondsSinceEpoch}',
    );
    if (result['isSuccess'] != true) throw Exception('保存失败');
  }
}
```

### Poster Widget Design

```
┌──────────────────────────────────┐
│                                  │  ← padding 24px
│  ┌────────────────────────────┐  │
│  │ ▎"选中的标注文字内容..."    │  │  ← quote block, left border
│  │                            │  │     fontSize: 21, height: 1.6
│  │                            │  │     highlight color as left border
│  └────────────────────────────┘  │
│                                  │
│  —— 《文章标题》                  │  ← 14px, gray
│      作者名 · 2024-01-01         │  ← 12px, lighter gray
│                                  │
│                                  │
│            READMEET              │  ← bottom-right watermark
│                                  │     12px, ultra-light gray
└──────────────────────────────────┘
  ↑ card width: screenWidth - 48
  ↑ card background: white or parchment (matches reader setting)
```

---

## 8. Annotation Summary Page

### `lib/pages/detail/widgets/annotation_summary.dart`

A page listing all annotations for an article:

```
┌──────────────────────────────────┐
│  我的标注 (3)          导航栏      │
├──────────────────────────────────┤
│  ┌────────────────────────────┐  │
│  │ "第一段标注的文字..."  🟡   │  │  ← annotation card
│  │ 📝 这段写得太好了           │  │  ← note below
│  └────────────────────────────┘  │
│  ┌────────────────────────────┐  │
│  │ "第二段..."  🟢             │  │
│  └────────────────────────────┘  │
│  ┌────────────────────────────┐  │
│  │ "第三段..."  🔵  ───       │  │  ← underline
│  └────────────────────────────┘  │
│                                  │
│  [ 导出所有标注 ]  ← 底部按钮     │
│  [ 生成合集海报 ]                │
└──────────────────────────────────┘
```

Trigger: navigation bar trailing button (replacing the share icon), or from the context menu.

---

## 9. Files to Create / Modify

### New Files

| File | Lines (est.) | Responsibility |
|------|-------------|----------------|
| `lib/models/annotation.dart` | ~80 | Data model + JSON serialization |
| `lib/services/annotation_store.dart` | ~120 | CRUD + persistence via shared_preferences |
| `lib/pages/detail/widgets/markdown_ast.dart` | ~150 | AST parsing: markdown → List\<MarkdownSegment\> |
| `lib/pages/detail/widgets/annotated_span_builder.dart` | ~150 | Build TextSpan tree with annotation decorations |
| `lib/pages/detail/widgets/annotated_chunk_list.dart` | ~80 | SliverList wrapper, wires store + settings + AST |
| `lib/pages/detail/widgets/selection_menu.dart` | ~120 | Custom contextMenuBuilder + action handlers |
| `lib/pages/detail/widgets/annotation_popup.dart` | ~100 | Edit/delete popup for existing annotations |
| `lib/pages/detail/widgets/poster_generator.dart` | ~120 | Render → PNG → save to gallery |
| `lib/pages/detail/widgets/poster_preview.dart` | ~100 | Poster preview sheet before saving |
| `lib/pages/detail/annotation_summary_page.dart` | ~150 | List all annotations, export entry point |

### Modified Files

| File | Changes |
|------|---------|
| `lib/pages/detail/detail_page.dart` | Wire `AnnotationStore`, navigation bar: add annotation summary button |
| `lib/pages/detail/widgets/markdown_chunk_list.dart` | Replace with `AnnotatedChunkList` (or keep both, switch by flag) |
| `pubspec.yaml` | Add `markdown`, `image_gallery_saver`, `permission_handler`, `uuid` |
| `android/app/src/main/AndroidManifest.xml` | Add `WRITE_EXTERNAL_STORAGE` + `READ_EXTERNAL_STORAGE` permissions |
| `ios/Runner/Info.plist` | Add `NSPhotoLibraryAddUsageDescription` |

### Deleted Files

| File | Reason |
|------|--------|
| `lib/pages/detail/widgets/markdown_chunk_list.dart` | Replaced by `annotated_chunk_list.dart` (archive as `markdown_chunk_list_legacy.dart` initially) |

---

## 10. Dependencies to Add

```yaml
# pubspec.yaml additions
dependencies:
  markdown: ^7.2.0           # AST parsing (already used by flutter_markdown, explicit for direct use)
  image_gallery_saver: ^2.0.3 # Save PNG to phone gallery
  permission_handler: ^11.3.0 # Storage permission
  uuid: ^4.2.0                # Generate annotation IDs
```

---

## 11. Implementation Phases

### Phase 1: Foundation (core data + rendering) — ~400 lines

| Step | File | What |
|------|------|------|
| 1.1 | `annotation.dart` | Data model |
| 1.2 | `annotation_store.dart` | CRUD + persistence |
| 1.3 | `markdown_ast.dart` | Markdown → AST → List\<MarkdownSegment\> |
| 1.4 | `annotated_span_builder.dart` | Segments → TextSpan with annotation decorations |
| 1.5 | `annotated_chunk_list.dart` | SliverList rendering |
| 1.6 | `detail_page.dart` (modify) | Wire store + new chunk list, remove old |

**Milestone**: Annotations load/persist/render. No UI to create them yet.

### Phase 2: Selection + Annotation Creation — ~300 lines

| Step | File | What |
|------|------|------|
| 2.1 | `selection_menu.dart` | Custom context menu with highlight/underline/note/poster |
| 2.2 | `annotation_popup.dart` | Tap annotation → edit/delete sheet |
| 2.3 | `detail_page.dart` (modify) | Wire SelectionArea + menu |
| 2.4 | `annotation_store.dart` (modify) | Add color picker, note input dialogs |

**Milestone**: User can select text → create annotation. Tap to edit/delete.

### Phase 3: Poster + Export — ~250 lines

| Step | File | What |
|------|------|------|
| 3.1 | `poster_generator.dart` | Render → PNG → save |
| 3.2 | `poster_preview.dart` | Preview sheet |
| 3.3 | `annotation_summary_page.dart` | Annotation list + export |
| 3.4 | `pubspec.yaml`, manifests | Permissions + dependencies |

**Milestone**: Full feature complete.

### Phase 4: Polish — ~100 lines

- Debounced persistence (avoid write on every drag)
- Undo last annotation
- Annotation count badge on detail page nav bar
- Scroll-to-annotation from summary page
- Performance: cache TextSpan tree, rebuild only on annotation change
- Accessibility: semantic labels on annotations

---

## 12. Key Design Decisions

### 12.1 Why replace MarkdownBody instead of wrapping it?

`MarkdownBody` creates opaque widget subtrees. We can't:
- Inject inline styles mid-span (annotations are partial-span)
- Add WidgetSpan badges after specific text
- Get accurate global character offsets for annotation positioning

By owning the rendering pipeline, we get full control.

### 12.2 Offset tracking strategy

The global offset is the character position in the **concatenated plain text** of the entire article (excluding markdown syntax characters). This is stable across renders because it's derived from the markdown source, not the rendered pixel positions.

```
Markdown: "# Hello\n\nWorld **bold**"
Plain:    "Hello\nWorld bold"
           ^     ^    ^
           0     6    12
```

Annotations store `(startOffset: 6, endOffset: 11)` → "World " gets highlighted.

### 12.3 Why shared_preferences and not SQLite?

- Typical user has < 500 annotations total → fits in shared_preferences
- No migration headaches
- JSON encoding is fast enough for this scale
- If annotations grow beyond 1000 per article, migrate to `sqflite` (already in pubspec)

### 12.4 Plan for h1/h2/code/blockquote styling

Flatten the AST and tag each segment with its `MarkdownStyle`. The span builder applies the correct TextStyle for each style, THEN overlays annotation decorations on top. Block elements (headings, code blocks) get block-level padding between segments.

---

## 13. Tests

| Test file | What |
|-----------|------|
| `test/annotation_test.dart` | Model serialization round-trip |
| `test/annotation_store_test.dart` | CRUD + persistence + offset queries |
| `test/markdown_ast_test.dart` | AST parsing → correct segments + offsets |
| `test/annotated_span_builder_test.dart` | Span tree with various annotation overlaps |
| `test/poster_generator_test.dart` | Image generation output format |

---

## 14. Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| `SelectionArea` + `CustomScrollView` incompatibility | Can't show custom menu | Fallback: wrap each chunk individually with custom menu |
| AST offset drift (markdown syntax not in plain text) | Annotation highlights wrong text | Add offset validation tests; recalculate on markdown change |
| Large articles (100K+ chars) cause slow span building | UI jank during annotation creation | Cache span tree; rebuild only changed segment; use `compute()` isolate for AST parsing |
| Cross-device annotation loss | User frustration | Document as known limitation; suggest cloud sync as future feature |
