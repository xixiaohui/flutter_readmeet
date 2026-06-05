# Multi-Language Support — Implementation Plan

> Target languages: 简体中文 (zh), 繁体中文 (zh-Hant), 日文 (ja), 英文 (en)

## 1. Architecture

```
lib/l10n/
  app_zh.arb          # Simplified Chinese
  app_zh_Hant.arb     # Traditional Chinese
  app_ja.arb          # Japanese
  app_en.arb          # English

pubspec.yaml          # Enable Flutter code generation
lib/app.dart          # Add locale support to CupertinoApp
lib/setting_page.dart # Add language picker
lib/main.dart         # Load saved locale
```

### Data Flow

```
SettingPage → ReaderSettingsService.setLocale()
→ setState in App → CupertinoApp(locale: ...)
→ all Text(AppLocalizations.of(context)!.key) auto-updates
```

---

## 2. Dependencies & Configuration

### 2.1 pubspec.yaml

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.2  # already present

flutter:
  generate: true  # Enable l10n code generation
```

### 2.2 l10n.yaml (create at project root)

```yaml
arb-dir: lib/l10n
template-arb-file: app_zh.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
synthetic-package: false
output-dir: lib/l10n/generated
nullable-getter: false
```

---

## 3. ARB Translation Files

### 3.1 `lib/l10n/app_zh.arb` (Simplified Chinese — template)

```json
{
  "@@locale": "zh",
  "appTitle": "ReadMeet",
  "homeTab": "首页",
  "allArticlesTab": "全部文章",
  "favoritesTab": "收藏",
  "annotationsTab": "标注",
  "settingsTab": "设置",
  "myAnnotations": "我的标注",
  "myFavorites": "我的收藏",
  "annotationList": "标注列表",
  "readingSettings": "阅读设置",
  "fontSize": "字体大小",
  "lineHeight": "行间距",
  "paragraphSpacing": "段落间距",
  "fontStyle": "字体样式",
  "readingBackground": "阅读背景",
  "copy": "复制",
  "selectAll": "全选",
  "highlight": "高亮标记",
  "underline": "下划线",
  "addNote": "添加笔记",
  "generatePoster": "生成海报",
  "changeColor": "更换颜色",
  "editNote": "编辑笔记",
  "deleteAnnotation": "删除标记",
  "clearNotes": "清空笔记",
  "note": "笔记",
  "delete": "删除",
  "savedToGallery": "已保存",
  "savedToGalleryMsg": "海报已保存到相册",
  "saveFailed": "保存失败",
  "checkPermission": "请检查相册权限",
  "selectColor": "选择颜色",
  "writeNote": "写下你的想法...",
  "noAnnotations": "暂无标注",
  "noFavorites": "暂无收藏",
  "noContent": "暂无内容",
  "noFeatured": "暂无精选内容",
  "loading": "加载中...",
  "typesetting": "排版中...",
  "confirm": "确定",
  "cancel": "取消",
  "save": "保存",
  "back": "返回",
  "viewAll": "查看全部",
  "confirmDeleteAll": "清空所有标注",
  "irreversible": "此操作不可撤销",
  "clear": "清空",
  "systemDefault": "系统默认",
  "serif": "宋体",
  "monospace": "等宽",
  "white": "白色",
  "parchment": "米色",
  "dark": "深色",
  "latestArticles": "最新文章",
  "chineseFeatured": "中文精选",
  "japaneseFeatured": "日文精选",
  "startReading": "开始阅读",
  "language": "语言",
  "requestFailed": "请求失败",
  "articleNotFound": "文章不存在",
  "searchFailed": "搜索失败",
  "poster": "海报",
  "pageIndicator": "{current} / {total}",
  "@pageIndicator": {
    "placeholders": {
      "current": {},
      "total": {}
    }
  }
}
```

### 3.2 `lib/l10n/app_zh_Hant.arb` (Traditional Chinese)

```json
{
  "@@locale": "zh_Hant",
  "appTitle": "ReadMeet",
  "homeTab": "首頁",
  "allArticlesTab": "全部文章",
  "favoritesTab": "收藏",
  "annotationsTab": "標註",
  "settingsTab": "設定",
  "myAnnotations": "我的標註",
  "myFavorites": "我的收藏",
  "annotationList": "標註列表",
  "readingSettings": "閱讀設定",
  "fontSize": "字型大小",
  "lineHeight": "行間距",
  "paragraphSpacing": "段落間距",
  "fontStyle": "字型樣式",
  "readingBackground": "閱讀背景",
  "copy": "複製",
  "selectAll": "全選",
  "highlight": "高亮標記",
  "underline": "底線",
  "addNote": "新增筆記",
  "generatePoster": "產生海報",
  "changeColor": "更換顏色",
  "editNote": "編輯筆記",
  "deleteAnnotation": "刪除標記",
  "clearNotes": "清除筆記",
  "note": "筆記",
  "delete": "刪除",
  "savedToGallery": "已儲存",
  "savedToGalleryMsg": "海報已儲存到相簿",
  "saveFailed": "儲存失敗",
  "checkPermission": "請檢查相簿權限",
  "selectColor": "選擇顏色",
  "writeNote": "寫下你的想法...",
  "noAnnotations": "暫無標註",
  "noFavorites": "暫無收藏",
  "noContent": "暫無內容",
  "noFeatured": "暫無精選內容",
  "loading": "載入中...",
  "typesetting": "排版中...",
  "confirm": "確定",
  "cancel": "取消",
  "save": "儲存",
  "back": "返回",
  "viewAll": "檢視全部",
  "confirmDeleteAll": "清空所有標註",
  "irreversible": "此操作無法復原",
  "clear": "清空",
  "systemDefault": "系統預設",
  "serif": "明體",
  "monospace": "等寬",
  "white": "白色",
  "parchment": "米色",
  "dark": "深色",
  "latestArticles": "最新文章",
  "chineseFeatured": "中文精選",
  "japaneseFeatured": "日文精選",
  "startReading": "開始閱讀",
  "language": "語言",
  "requestFailed": "請求失敗",
  "articleNotFound": "文章不存在",
  "searchFailed": "搜尋失敗",
  "poster": "海報",
  "pageIndicator": "{current} / {total}",
  "@pageIndicator": {
    "placeholders": {
      "current": {},
      "total": {}
    }
  }
}
```

### 3.3 `lib/l10n/app_ja.arb` (Japanese)

```json
{
  "@@locale": "ja",
  "appTitle": "ReadMeet",
  "homeTab": "ホーム",
  "allArticlesTab": "すべての記事",
  "favoritesTab": "お気に入り",
  "annotationsTab": "注釈",
  "settingsTab": "設定",
  "myAnnotations": "マイ注釈",
  "myFavorites": "お気に入り",
  "annotationList": "注釈リスト",
  "readingSettings": "読書設定",
  "fontSize": "フォントサイズ",
  "lineHeight": "行間",
  "paragraphSpacing": "段落間隔",
  "fontStyle": "フォントスタイル",
  "readingBackground": "読書背景",
  "copy": "コピー",
  "selectAll": "すべて選択",
  "highlight": "ハイライト",
  "underline": "下線",
  "addNote": "メモ追加",
  "generatePoster": "ポスター生成",
  "changeColor": "色変更",
  "editNote": "メモ編集",
  "deleteAnnotation": "注釈削除",
  "clearNotes": "メモ消去",
  "note": "メモ",
  "delete": "削除",
  "savedToGallery": "保存完了",
  "savedToGalleryMsg": "ポスターをギャラリーに保存しました",
  "saveFailed": "保存失敗",
  "checkPermission": "ギャラリー権限を確認してください",
  "selectColor": "色を選択",
  "writeNote": "考えを書いてください...",
  "noAnnotations": "注釈なし",
  "noFavorites": "お気に入りなし",
  "noContent": "コンテンツなし",
  "noFeatured": "おすすめ記事なし",
  "loading": "読み込み中...",
  "typesetting": "組版中...",
  "confirm": "確認",
  "cancel": "キャンセル",
  "save": "保存",
  "back": "戻る",
  "viewAll": "すべて見る",
  "confirmDeleteAll": "すべての注釈を消去",
  "irreversible": "この操作は取り消せません",
  "clear": "消去",
  "systemDefault": "システム既定",
  "serif": "明朝体",
  "monospace": "等幅",
  "white": "白",
  "parchment": "生成り",
  "dark": "ダーク",
  "latestArticles": "最新記事",
  "chineseFeatured": "中国語おすすめ",
  "japaneseFeatured": "日本語おすすめ",
  "startReading": "読み始める",
  "language": "言語",
  "requestFailed": "リクエスト失敗",
  "articleNotFound": "記事が見つかりません",
  "searchFailed": "検索失敗",
  "poster": "ポスター",
  "pageIndicator": "{current} / {total}",
  "@pageIndicator": {
    "placeholders": {
      "current": {},
      "total": {}
    }
  }
}
```

### 3.4 `lib/l10n/app_en.arb` (English)

```json
{
  "@@locale": "en",
  "appTitle": "ReadMeet",
  "homeTab": "Home",
  "allArticlesTab": "Articles",
  "favoritesTab": "Favorites",
  "annotationsTab": "Notes",
  "settingsTab": "Settings",
  "myAnnotations": "My Notes",
  "myFavorites": "My Favorites",
  "annotationList": "Notes",
  "readingSettings": "Reading Settings",
  "fontSize": "Font Size",
  "lineHeight": "Line Height",
  "paragraphSpacing": "Paragraph Spacing",
  "fontStyle": "Font Style",
  "readingBackground": "Background",
  "copy": "Copy",
  "selectAll": "Select All",
  "highlight": "Highlight",
  "underline": "Underline",
  "addNote": "Add Note",
  "generatePoster": "Poster",
  "changeColor": "Change Color",
  "editNote": "Edit Note",
  "deleteAnnotation": "Delete",
  "clearNotes": "Clear Notes",
  "note": "Note",
  "delete": "Delete",
  "savedToGallery": "Saved",
  "savedToGalleryMsg": "Poster saved to gallery",
  "saveFailed": "Save Failed",
  "checkPermission": "Please grant gallery permission",
  "selectColor": "Select Color",
  "writeNote": "Write your thoughts...",
  "noAnnotations": "No notes yet",
  "noFavorites": "No favorites yet",
  "noContent": "No content",
  "noFeatured": "No featured articles",
  "loading": "Loading...",
  "typesetting": "Typesetting...",
  "confirm": "OK",
  "cancel": "Cancel",
  "save": "Save",
  "back": "Back",
  "viewAll": "View All",
  "confirmDeleteAll": "Delete all notes?",
  "irreversible": "This action cannot be undone",
  "clear": "Clear",
  "systemDefault": "System",
  "serif": "Serif",
  "monospace": "Monospace",
  "white": "White",
  "parchment": "Parchment",
  "dark": "Dark",
  "latestArticles": "Latest",
  "chineseFeatured": "Chinese",
  "japaneseFeatured": "Japanese",
  "startReading": "Start Reading",
  "language": "Language",
  "requestFailed": "Request failed",
  "articleNotFound": "Article not found",
  "searchFailed": "Search failed",
  "poster": "Poster",
  "pageIndicator": "{current} / {total}",
  "@pageIndicator": {
    "placeholders": {
      "current": {},
      "total": {}
    }
  }
}
```

---

## 4. Code Changes

### 4.1 `lib/main.dart`

```dart
import 'package:flutter/cupertino.dart';
import 'app.dart';
import 'l10n/generated/app_localizations.dart';
import 'services/api_service.dart';
import 'services/favorite_service.dart';
import 'services/reader_settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apiService = ApiService();
  final settingsService = ReaderSettingsService();
  final favoriteService = FavoriteService();
  await settingsService.load();
  await favoriteService.load();
  runApp(App(
    apiService: apiService,
    settingsService: settingsService,
    favoriteService: favoriteService,
  ));
}
```

> No changes needed — `AppLocalizations` is auto-loaded by the delegate.

### 4.2 `lib/app.dart`

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/generated/app_localizations.dart';
import 'services/api_service.dart';
import 'services/favorite_service.dart';
import 'services/reader_settings_service.dart';
import 'pages/home/home_page.dart';
import 'pages/list/list_page.dart';
import 'pages/favorites/favorites_page.dart';
import 'pages/annotations/global_annotations_page.dart';
import 'pages/setting/setting_page.dart';

class App extends StatefulWidget {
  final ApiService apiService;
  final ReaderSettingsService settingsService;
  final FavoriteService favoriteService;

  const App({
    super.key,
    required this.apiService,
    required this.settingsService,
    required this.favoriteService,
  });

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _syncLocale();
    widget.settingsService.addListener(_syncLocale);
  }

  @override
  void dispose() {
    widget.settingsService.removeListener(_syncLocale);
    super.dispose();
  }

  void _syncLocale() {
    final code = widget.settingsService.localeCode;
    if (code == null) {
      setState(() => _locale = null); // follow system
    } else {
      setState(() => _locale = Locale(code));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'ReadMeet',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh'),
        Locale('zh', 'Hant'),
        Locale('ja'),
        Locale('en'),
      ],
      // Fallback to English if system language is not supported
      localeResolutionCallback: (locale, supportedLocales) {
        // 1. User explicitly chose a language → use it
        if (_locale != null) return _locale;
        // 2. System locale is supported → use it
        if (locale != null) {
          for (final supported in supportedLocales) {
            if (supported.languageCode == locale.languageCode) {
              return supported;
            }
          }
        }
        // 3. Fallback to English
        return const Locale('en');
      },
      ...
      // Tab bar items use AppLocalizations:
      items: [
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.house_fill),
          label: AppLocalizations.of(context)!.homeTab,
        ),
        ...
      ],
      ...
    );
  }
}
```

### 4.3 `lib/services/reader_settings_service.dart` — Add locale field

```dart
// Add storage key
static const _keyLocale = 'reader_locale';

// Add field
String? _localeCode; // null = follow system

// Add getter/setter
String? get localeCode => _localeCode;

Future<void> setLocale(String? code) async {
  if (code == _localeCode) return;
  _localeCode = code;
  notifyListeners();
  await _persistLocale();
}

// In load():
_localeCode = prefs.getString(_keyLocale);

// In _persist():
if (_localeCode != null) {
  await prefs.setString(_keyLocale, _localeCode!);
} else {
  await prefs.remove(_keyLocale);
}
```

### 4.4 `lib/pages/setting/setting_page.dart` — Add language picker

Add a new section at the end of the ListView:

```dart
_SectionLabel(AppLocalizations.of(context)!.language),
_SegmentedRow<String?>(
  value: _s.localeCode,
  options: const [null, 'zh', 'zh_Hant', 'ja', 'en'],
  labels: const ['跟随系统', '中文简体', '中文繁體', '日本語', 'English'],
  onChanged: _s.setLocale,
),
```

### 4.5 Migration: Replace hardcoded Chinese strings

In every file currently using hardcoded Chinese, wrap with `AppLocalizations.of(context)!`:

**Before:**
```dart
Text('加载中...')
```

**After:**
```dart
Text(AppLocalizations.of(context)!.loading)
```

---

## 5. Files Affected

### New Files

| File | Content |
|------|---------|
| `l10n.yaml` | Generator config |
| `lib/l10n/app_zh.arb` | 63 keys, Simplified Chinese |
| `lib/l10n/app_zh_Hant.arb` | 63 keys, Traditional Chinese |
| `lib/l10n/app_ja.arb` | 63 keys, Japanese |
| `lib/l10n/app_en.arb` | 63 keys, English |
| `lib/l10n/generated/app_localizations.dart` | Auto-generated |

### Modified Files

| File | Changes |
|------|---------|
| `pubspec.yaml` | `flutter_localizations` dep, `generate: true` |
| `lib/app.dart` | StatefulWidget, locale support, delegates |
| `lib/services/reader_settings_service.dart` | `_localeCode` field + getter/setter |
| `lib/pages/setting/setting_page.dart` | Language picker section |
| `lib/pages/home/home_page.dart` | Replace hardcoded strings |
| `lib/pages/detail/detail_page.dart` | Replace hardcoded strings |
| `lib/pages/detail/widgets/page_content.dart` | Replace hardcoded strings |
| `lib/pages/detail/widgets/poster_generator.dart` | Replace hardcoded strings |
| `lib/pages/detail/annotation_summary_page.dart` | Replace hardcoded strings |
| `lib/pages/annotations/global_annotations_page.dart` | Replace hardcoded strings |
| `lib/pages/list/list_page.dart` | Replace hardcoded strings |
| `lib/pages/hot/hot_page.dart` | Replace hardcoded strings |
| `lib/pages/favorites/favorites_page.dart` | Replace hardcoded strings |
| `lib/widgets/loading_indicator.dart` | Replace hardcoded strings |
| `lib/services/api_service.dart` | Replace hardcoded error messages |

---

## 6. Implementation Steps (9 steps)

### Step 1: Configure code generation

- Create `l10n.yaml`
- Update `pubspec.yaml`
- Run `flutter pub get`
- Run `flutter gen-l10n` to verify

### Step 2: Create ARB files

- Create all 4 ARB files with full translations

### Step 3: Update `ReaderSettingsService`

- Add `_localeCode` field, getter, setter, persist

### Step 4: Update `app.dart`

- Convert to `StatefulWidget`
- Add `AppLocalizations.delegate`
- Listen to settings locale changes
- Replace tab bar labels with localized strings

### Step 5: Update `setting_page.dart`

- Add language picker using `CupertinoSlidingSegmentedControl`

### Step 6: Replace strings in detail page widgets

- `detail_page.dart`, `page_content.dart`, `poster_generator.dart`, `annotation_summary_page.dart`

### Step 7: Replace strings in list/home pages

- `home_page.dart`, `list_page.dart`, `hot_page.dart`, `favorites_page.dart`

### Step 8: Replace strings in shared widgets

- `loading_indicator.dart`, `api_service.dart`, `global_annotations_page.dart`

### Step 9: Test all 4 languages

- Switch language in settings → verify all pages update
- Kill app, restart → verify language persists
- Add annotation → verify labels are localized

---

## 7. Estimated Effort

| Category | Lines |
|----------|-------|
| ARB files (4 × 63 keys) | ~252 |
| l10n.yaml | ~8 |
| Code generation output | auto |
| app.dart changes | ~40 |
| settings_service changes | ~15 |
| setting_page changes | ~20 |
| String replacement (15 files) | ~200 |
| **Total** | **~535** |
