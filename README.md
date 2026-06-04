# ReadMeet

A cross-platform reading application built with Flutter, featuring paginated reading, text annotations, poster generation, and customizable typography settings.

## Features

### Article Reader

- **PageView Pagination** — book-like page-turning instead of infinite scrolling. Pages are dynamically calculated using `TextPainter` based on font size, line height, and screen dimensions.
- **Markdown Rendering** — custom AST parser that handles headings, blockquotes, code blocks, bold, italic, and inline formatting.
- **Reading Progress** — page index saved per article and restored on revisit.

### Text Annotations

- **Highlight & Underline** — select text (≥2 chars) to show a dropdown menu with highlight and underline options. Color picker with 5 highlight colors and 2 underline colors.
- **Notes** — attach multiple comments to any annotation. Notes appear inline and in the annotation summary.
- **Annotation Summary** — per-article page listing all annotations with edit/delete. Per-annotation poster generation.
- **Global Annotations** — app-level tab showing annotations across all articles, grouped by article.
- **Persistence** — annotations stored via `shared_preferences`, keyed by article ID.
- **Text-based Matching** — annotations are matched by actual text content using `indexOf`, making them robust against offset drift when articles reload.

### Poster Generation

- Select text → "Generate Poster" → styled preview with quote block, article title, author, date, and app watermark.
- Save as PNG directly to the phone photo gallery.

### Reader Settings

Customizable via the Settings tab and applied globally to the reader, annotation summary, and posters:

| Setting | Range |
| --- | --- |
| Font Size | 14 – 24 |
| Line Height | 1.2 – 2.4 |
| Paragraph Spacing | 8 – 32 px |
| Font Family | System Default / Serif / Monospace |
| Background Color | White / Parchment / Dark |

### Home Page

Modular home page with independently-loading content sections:
- **Hero** — featured article from `/api/blogs/hero`
- **最新文章** — latest articles
- **中文精选 / 日文精选** — Chinese and Japanese curated content
- **Author Collections** — Shakespeare, Twain, Byron, Jefferson, Lincoln, Sand, Burnand

Each module loads asynchronously and appears as data arrives (progressive rendering).

## Project Structure

```
lib/
├── main.dart                          # Entry point
├── app.dart                           # CupertinoApp + tab navigation
├── config/
│   └── api.dart                       # API endpoint constants
├── models/
│   ├── annotation.dart                # Annotation data model
│   ├── card_item.dart                 # Blog article model
│   └── reading_progress.dart          # Reading progress model (page index)
├── services/
│   ├── annotation_store.dart          # Annotation CRUD + persistence
│   ├── api_service.dart               # HTTP client for blog API
│   ├── reader_settings_service.dart   # Typography settings (ChangeNotifier)
│   └── reading_progress_service.dart  # Progress save/load
├── theme/
│   └── app_theme.dart                 # Design tokens (colors, spacing, text)
├── utils/
│   └── markdown_chunker.dart          # Markdown chunker (legacy)
├── widgets/
│   └── loading_indicator.dart         # Shared loading/error/empty widgets
└── pages/
    ├── home/
    │   ├── home_page.dart             # Home page with modular sections
    │   └── widgets/
    │       ├── hero_tile.dart          # Hero card
    │       └── featured_card.dart      # Horizontal scroll card
    ├── list/
    │   ├── list_page.dart             # All articles list
    │   └── widgets/
    │       └── blog_row.dart           # List row item
    ├── hot/
    │   └── hot_page.dart              # Curated content list
    ├── setting/
    │   └── setting_page.dart          # Reader settings UI
    ├── annotations/
    │   └── global_annotations_page.dart # Cross-article annotations
    └── detail/
        ├── detail_page.dart           # Article detail (PageView reader)
        ├── annotation_summary_page.dart # Per-article annotation list
        ├── services/
        │   └── page_calculator.dart   # TextPainter-based pagination
        └── widgets/
            ├── page_reader.dart        # PageView wrapper + indicator
            ├── page_content.dart       # Single page content + annotation menus
            ├── markdown_ast.dart       # Custom markdown parser
            ├── annotated_chunk_list.dart # Scroll-based chunk list (legacy)
            ├── annotated_span_builder.dart # Annotation span tree builder
            ├── hero_image.dart         # Detail page hero image
            ├── content_card.dart       # Article header card
            └── poster_generator.dart   # PNG poster generation + save
```

## Tech Stack

| Category | Technology |
| --- | --- |
| Framework | Flutter 3.44 (Dart 3.12) |
| UI | Cupertino (iOS-style) |
| State | `ChangeNotifier` + `ListenableBuilder` |
| HTTP | `package:http` |
| Markdown | Custom AST parser (`markdown_ast.dart`) |
| Storage | `shared_preferences` |
| Image Caching | `cached_network_image` |
| Gallery Save | `gal` |
| Permissions | `permission_handler` |

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run on device/emulator
flutter run -d <device-id>

# Run on Android
flutter run -d android

# Static analysis
flutter analyze

# Run tests
flutter test
```

## Platform Support

- Android
- iOS
- Windows
- macOS
- Linux
- Web

## Environment

- **Flutter** 3.44.1 (stable)
- **Dart** 3.12.1
- **Linter**: `package:flutter_lints/flutter.yaml` (v6.0.0)
