# Plan: Extract Hardcoded Strings → AppLocalizations (i18n)

## Context

The project has a fully functional ARB-based l10n infrastructure (4 locales: zh/zh_Hant/ja/en, 64 keys), but **only ~5% of the app uses it** — just 5 tab labels in `app.dart`. The other 18+ files contain **~80 hardcoded Chinese strings**. This plan extracts them all, adds 12 new ARB keys where needed, and wires everything into `AppLocalizations`.

**Pattern**: `AppLocalizations.of(context)?.key ?? 'zh_fallback'` (mandatory due to `nullable-getter: true`)

---

## Phase 1: Add 12 New ARB Keys + Regenerate

**File**: `lib/l10n/app_zh.arb` (template — add all 12 here first, then propagate)

| Key | zh | zh_Hant | en | ja |
|-----|----|---------|----|----|
| `retry` | 重试 | 重試 | Retry | 再試行 |
| `unknownAuthor` | 未知作者 | 未知作者 | Unknown Author | 不明な著者 |
| `enterSearchKeyword` | 请输入搜索关键词 | 請輸入搜尋關鍵詞 | Please enter a search keyword | 検索キーワードを入力してください |
| `closeButton` | 关闭 | 關閉 | Close | 閉じる |
| `searchArticleHint` | 搜索文章... | 搜尋文章... | Search articles... | 記事を検索... |
| `noSearchResults` | 未找到相关内容 | 未找到相關內容 | No results found | 該当する結果がありません |
| `noArticles` | 暂无文章 | 暫無文章 | No articles | 記事がありません |
| `followSystem` | 跟随系统 | 跟隨系統 | Follow System | システムに従う |
| `chineseSimplified` | 中文简体 | 中文簡體 | Simplified Chinese | 簡体字中国語 |
| `chineseTraditional` | 中文繁體 | 中文繁體 | Traditional Chinese | 繁体字中国語 |
| `japaneseLang` | 日本語 | 日本語 | Japanese | 日本語 |
| `posterTitlePrefix` | ——  | ——  | —  | ——  |

> **Skip `latestTag`**: `'最新'` in `home_page.dart:78` is an API search parameter, not a UI string. Localizing it would break the featured feed.

**After editing ARB files, run**: `flutter gen-l10n`

---

## Phase 2: Replace Hardcoded Strings in Widget Files (has BuildContext)

Standard pattern for every file:

```dart
// Extract once at top of build():
final l10n = AppLocalizations.of(context);

// BEFORE: Text('最新文章')
// AFTER:  Text(l10n?.latestArticles ?? '最新文章')
```

### Files to modify (with existing-key replacements):

| File | Keys to replace | Count |
|------|----------------|-------|
| `lib/widgets/loading_indicator.dart` | `noContent` (EmptyView fallback), `retry` (new) | 2 |
| `lib/pages/favorites/favorites_page.dart` | `myFavorites`, `noFavorites` | 2 |
| `lib/pages/hot/hot_page.dart` | `loading`, `noFeatured` | 2 |
| `lib/pages/home/home_page.dart` | `latestArticles`, `viewAll`, `chineseFeatured`, `japaneseFeatured` | ~20 |
| `lib/pages/home/widgets/hero_tile.dart` | `startReading` | 1 |
| `lib/pages/detail/detail_page.dart` | `back`, `loading`, `typesetting`, `addNote`, `writeNote`, `cancel`, `save` | 8 |
| `lib/pages/detail/widgets/page_content.dart` | `copy`, `selectAll`, `highlight`, `underline`, `addNote`, `generatePoster`, `selectColor`, `cancel` | 8 |
| `lib/pages/detail/widgets/annotated_chunk_list.dart` | Same 8 keys as page_content (duplicate dropdown logic) | 8 |
| `lib/pages/detail/widgets/annotated_span_builder.dart` | `note`, `closeButton` (new) | 2 |
| `lib/pages/detail/widgets/poster_generator.dart` | `generatePoster`, `save`, `posterTitlePrefix` (new), `savedToGallery`, `savedToGalleryMsg`, `saveFailed`, `checkPermission`, `confirm` | 8 |
| `lib/pages/detail/annotation_summary_page.dart` | `clear`, `noAnnotations`, `confirmDeleteAll`, `irreversible`, `cancel`, `poster`, `note`, `clearNotes`, `delete`, `addNote`, `writeNote`, `save` | 12 |
| `lib/pages/list/list_page.dart` | `allArticlesTab`, `loading`, `noSearchResults` (new), `noArticles` (new) | 4 |
| `lib/pages/list/widgets/search_bar.dart` | `searchArticleHint` (new) | 1 |
| `lib/pages/annotations/global_annotations_page.dart` | `annotationList`, `noAnnotations` | 2 |
| `lib/pages/setting/setting_page.dart` | `readingSettings`, `fontSize`, `lineHeight`, `paragraphSpacing`, `fontStyle`, `readingBackground`, `language`, `followSystem` (new), `chineseSimplified` (new), `chineseTraditional` (new), `japaneseLang` (new) | 11 |

**Important**: Remove `const` from any widget that now contains `AppLocalizations.of(context)`.

### `EmptyView` refactor (loading_indicator.dart)

Change to resolve `noContent` fallback in `build()`, removing the const default:

```dart
class EmptyView extends StatelessWidget {
  final String? message;
  const EmptyView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message ?? AppLocalizations.of(context)?.noContent ?? '暂无内容',
      ),
    );
  }
}
```

---

## Phase 3: Non-Widget Files (No BuildContext) — Special Strategies

### 3a. `lib/services/api_service.dart` — ApiException Messages

**Strategy**: Add `errorCode` field. UI layer maps code → l10n key.

```dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String errorCode;  // NEW

  const ApiException(this.message, {this.statusCode, this.errorCode = ''});
}
```

Add error codes at 5 throw sites: `requestFailed`, `articleNotFound`, `enterSearchKeyword`, `searchFailed`. Then in `ErrorView.build()`, map `errorCode` to `AppLocalizations` getter.

### 3b. `lib/services/reader_settings_service.dart` — Static Label Maps

**Strategy**: Delete `fontFamilyLabels` and `backgroundColorLabels` static maps. Move label resolution into `setting_page.dart` using existing ARB keys (`systemDefault`, `serif`, `monospace`, `white`, `parchment`, `dark`).

### 3c. `lib/models/card_item.dart` — "Unknown Author" Fallback

**Strategy**: Change `authorName` getter to return `String?` (null when no author). UI layer provides the fallback.

```dart
// Model: return null instead of '未知作者'
String? get authorName => authors.isNotEmpty ? authors.first.name : null;
```

Then at 6 call sites across 5 files, add:
```dart
blog.authorName ?? l10n?.unknownAuthor ?? '未知作者'
```

Call sites: `content_card.dart:101`, `featured_card.dart:66`, `detail_page.dart:200,308`, `annotation_summary_page.dart`, `poster_generator.dart:97`, `favorites_page.dart`.

---

## Phase 4: Verification

1. **`flutter analyze`** — zero errors (especially: no const context errors, no missing imports)
2. **`flutter gen-l10n`** — regenerated files contain all 76 keys (64 + 12)
3. **ARB key count** — all 4 ARB files have same message keys
4. **Manual smoke test** — cycle through all 4 locales; verify all text translates correctly (tab labels, section headers, buttons, dialogs, empty states, error messages, poster UI, locale picker labels)
5. **Edge cases** — cold start (no NPE), network error (localized message), unknown author (localized fallback)
6. **Final grep sweep**:
   ```bash
   grep -rP '[\x{4e00}-\x{9fff}]' lib/ --include='*.dart' | grep -v 'l10n/' | grep -v 'generated/'
   ```
   Should return zero results (except the intentional `'最新'` API keyword).

---

## Files NOT Changed

- `lib/l10n/generated/*` — auto-generated, not hand-edited
- `lib/config/api.dart` — no strings
- `lib/main.dart` — no strings
- All model/service files without hardcoded strings (~15 files)
