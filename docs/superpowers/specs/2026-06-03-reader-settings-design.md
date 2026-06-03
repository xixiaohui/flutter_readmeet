# Reader Settings Page Design

## Overview

Add a settings page (`lib/pages/setting/`) that allows users to customize reader typography: font size, line height, paragraph spacing, font family, and background color. Settings are persisted via `shared_preferences` and take effect immediately in the article reader.

## Architecture

```
lib/
  services/
    reader_settings_service.dart   # NEW — persist/load reader settings
  pages/
    setting/
      setting_page.dart            # NEW — settings UI
  pages/
    detail/
      widgets/
        markdown_chunk_list.dart   # MODIFY — read settings dynamically
  app.dart                         # MODIFY — add 3rd tab
```

### Data Flow

```
SettingPage ──(writes)──> ReaderSettingsService ──(shared_preferences)──> disk
MarkdownChunkList <──(reads)── ReaderSettingsService <──(shared_preferences)── disk
```

- `ReaderSettingsService` exposes a `ChangeNotifier` so `MarkdownChunkList` can listen and rebuild when settings change.
- `SettingPage` writes through the service; readers react automatically.

## ReaderSettingsService

- Uses `shared_preferences` (already a dependency).
- Stores: `fontSize` (double), `lineHeight` (double), `paragraphSpacing` (double), `fontFamily` (String), `backgroundColor` (String key).
- Provides sensible defaults matching existing `AppText` / `AppSpacing` design tokens.
- Exposes `ChangeNotifier` via mixin so widgets can `addListener` / `removeListener`.

### Defaults

| Key | Default | Range |
|-----|---------|-------|
| `fontSize` | 17.0 | 14.0 – 24.0 |
| `lineHeight` | 1.8 | 1.2 – 2.4 |
| `paragraphSpacing` | 17.0 | 8.0 – 32.0 |
| `fontFamily` | `null` (system default) | `null`, `serif`, `monospace` |
| `backgroundColor` | `parchment` | `white`, `parchment`, `dark` |

## SettingPage UI

A standard `CupertinoPageScaffold` with grouped `CupertinoFormSection` rows:

- **Font size**: `CupertinoSlider` with min/max labels and current value display.
- **Line height**: `CupertinoSlider`.
- **Paragraph spacing**: `CupertinoSlider`.
- **Font family**: `CupertinoSegmentedControl` — 系统默认 / 宋体(serif) / 楷体(monospace).
- **Background color**: `CupertinoSegmentedControl` — 白色 / 米色 / 深色.

Each control writes immediately to `ReaderSettingsService` on change (no save button needed). A brief description label accompanies each row.

## MarkdownChunkList Changes

- Instead of a static top-level `_markdownStyle`, build the `MarkdownStyleSheet` inside the widget's `build` method.
- Read current settings from `ReaderSettingsService`.
- Apply:
  - `fontSize` → `p` style `fontSize`, also scale `h1`/`h2`/`h3` proportionally.
  - `lineHeight` → `p` style `height` and `blockquote` `height`.
  - `paragraphSpacing` → `separatorBuilder` gap.
  - `fontFamily` → `p` style `fontFamily` (and headings).
  - `backgroundColor` → parent `Container` color.

## App Tab Bar Changes

Add a 3rd `BottomNavigationBarItem` with `CupertinoIcons.settings` icon and label `设置`. The `tabBuilder` case 2 returns a `CupertinoTabView` wrapping `SettingPage`.

## Files to Create

- `lib/services/reader_settings_service.dart`
- `lib/pages/setting/setting_page.dart`

## Files to Modify

- `lib/pages/detail/widgets/markdown_chunk_list.dart` — dynamic stylesheet from settings
- `lib/pages/detail/detail_page.dart` — pass background color from settings
- `lib/app.dart` — 3rd tab

## Error Handling

- `shared_preferences` read/write failures fall back to defaults silently (service catches and returns defaults).
- No network calls — settings are purely local.

## Testing

- Unit test `ReaderSettingsService` to verify defaults, save/load round-trip.
- Widget test `SettingPage` to verify controls render and update service.
