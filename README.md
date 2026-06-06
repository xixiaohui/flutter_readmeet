# 见书 · ReadMeet

> 见书如面，落笔有光 — 一款为深度阅读者打造的跨平台移动阅读应用。

翻页式阅读体验，支持文本批注、彩色高亮、笔记摘录与一键海报生成。聚合多语经典文学作品，从莎士比亚到徐霞客，让每一次阅读都留下可回味的痕迹。

---

## 功能

### 📖 阅读器

- **PageView 翻页** — 模拟纸质书翻页，页数由 `TextPainter` 根据字号、行高和屏幕尺寸动态计算
- **Markdown 渲染** — 自定义 AST 解析器，支持标题、引用、代码块、粗体、斜体等内联格式
- **阅读进度恢复** — 每篇文章的阅读页码自动保存，再次打开时恢复

### ✍️ 批注与笔记

- **高亮 & 下划线** — 选中 2 字以上弹出菜单，5 种高亮色 + 2 种下划线色
- **批注笔记** — 任意批注可附加多条笔记，内联显示并汇总到批注摘要页
- **全局批注** — App 级标签页，按文章分组展示所有批注，支持编辑和删除
- **文本匹配** — 批注基于实际文本内容匹配（`indexOf`），不受文章重新加载后偏移量变化影响
- **持久化** — 通过 `shared_preferences` 存储，按文章 ID 分组

### 🖼️ 海报生成

- 选中文本 → 「生成海报」→ 引文卡片预览（含引用、标题、作者、日期、App 水印）
- 一键保存 PNG 至手机相册

### 🎛️ 阅读设置

| 设置项 | 范围 |
| --- | --- |
| 字号 | 14 – 24 |
| 行高 | 1.2 – 2.4 |
| 段落间距 | 8 – 32 px |
| 字体 | 系统默认 / 宋体 / 等宽 |
| 背景色 | 白色 / 米色 / 深色 |

### 🏠 首页

- **Hero 轮播** — 3~5 篇精选自动翻页，渐变遮罩叠加标题与作者
- **最新文章** — 双列网格（iPad 三列），大卡片展示
- **中文精选 / 日文精选** — 横向滑动卡片，圆形作者头像
- **作者专栏** — Shakespeare、Twain、Byron、Jefferson、Lincoln、Sand、Burnand 七位经典作者
- **Shimmer 骨架屏** — 加载态微光动画占位
- **下拉刷新** — 全板块并行重新加载
- **搜索** — 导航栏搜索图标直达搜索页，关键词搜索文章

---

## 技术栈

| 类别 | 技术 |
|------|------|
| 框架 | Flutter 3.44（Dart 3.12） |
| UI 风格 | Cupertino（iOS 原生风格） |
| 状态管理 | `ChangeNotifier` + `ListenableBuilder` |
| HTTP | `package:http` |
| Markdown | 自定义 AST 解析器 |
| 本地存储 | `shared_preferences` |
| 图片缓存 | `cached_network_image` |
| 相册保存 | `gal` |
| 权限管理 | `permission_handler` |
| 国际化 | `flutter_localizations`（zh / zh-Hant / ja / en） |

---

## 项目结构

```
lib/
├── main.dart                              # 入口
├── app.dart                               # CupertinoApp + 5 标签页导航
├── config/
│   └── api.dart                           # API 端点配置
├── l10n/
│   └── generated/                         # ARB 生成的本地化代码（zh / ja / en）
├── models/
│   ├── annotation.dart                    # 批注数据模型
│   ├── author.dart                        # 作者模型
│   ├── card_item.dart                     # 文章卡片模型
│   ├── favorite.dart                      # 收藏数据模型
│   └── reading_progress.dart              # 阅读进度模型
├── services/
│   ├── api_service.dart                   # HTTP API 客户端
│   ├── annotation_store.dart              # 批注 CRUD 持久化
│   ├── content_cache_service.dart         # 文章内容缓存（24h TTL）
│   ├── favorite_service.dart              # 收藏持久化
│   ├── reader_settings_service.dart       # 阅读设置（ChangeNotifier）
│   └── reading_progress_service.dart      # 进度保存/加载
├── theme/
│   └── app_theme.dart                     # 设计令牌（颜色、排版、间距、圆角）
├── utils/
│   ├── markdown_chunker.dart              # Markdown 分块器
│   └── responsive.dart                    # 响应式断点适配
├── widgets/
│   ├── loading_indicator.dart             # 加载/错误/空态通用组件
│   ├── section_header.dart                # 栏目标题行
│   └── shimmer.dart                       # Shimmer 骨架屏动画
└── pages/
    ├── home/
    │   ├── home_page.dart                 # 首页（轮播 + 网格 + 横向滑动）
    │   └── widgets/
    │       ├── hero_carousel.dart          # Hero 自动轮播
    │       ├── grid_card.dart              # 双列网格卡片
    │       ├── horizontal_card.dart        # 横向滑动卡片
    │       ├── hero_tile.dart              # [旧] 静态 Hero 卡片
    │       └── featured_card.dart          # [旧] 横向滑动卡片
    ├── list/
    │   ├── list_page.dart                 # 全部文章（无限滚动）
    │   └── widgets/
    │       ├── blog_row.dart               # 列表行组件
    │       └── search_bar.dart            # 搜索栏
    ├── search/
    │   └── search_page.dart               # 搜索页
    ├── hot/
    │   └── hot_page.dart                  # 精选/作者文章列表
    ├── favorites/
    │   └── favorites_page.dart            # 收藏列表
    ├── annotations/
    │   └── global_annotations_page.dart   # 全局批注列表
    ├── setting/
    │   └── setting_page.dart              # 阅读设置页（排版 + 外观 + 语言）
    └── detail/
        ├── detail_page.dart               # 文章详情（PageView 阅读器）
        ├── annotation_summary_page.dart   # 单文章批注摘要
        ├── services/
        │   └── page_calculator.dart       # TextPainter 分页算法
        └── widgets/
            ├── page_reader.dart            # PageView 包装 + 页码指示器
            ├── page_content.dart           # 单页内容 + 批注菜单
            ├── markdown_ast.dart           # Markdown 解析器
            ├── annotated_chunk_list.dart   # 滚动分块列表
            ├── annotated_span_builder.dart # 批注 Span 树构建器
            ├── hero_image.dart             # 详情页 Hero 图
            ├── content_card.dart           # 文章头部卡片
            └── poster_generator.dart       # PNG 海报生成与保存
```

---

## 构建

```bash
# 获取依赖
flutter pub get

# 开发运行
flutter run -d <device-id>

# 构建发布版本
./scripts/build.sh prod          # 生产构建（Android APK + AAB + Web）
./scripts/build.sh dev           # 开发构建
./scripts/build.sh test          # 测试构建

# 静态分析
flutter analyze

# 运行测试
flutter test
```

构建输出位于 `build_output/<env>-<version>/`。

---

## 平台支持

| Android | iOS | Web | Windows | macOS | Linux |
| :-: | :-: | :-: | :-: | :-: | :-: |
| ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

## 环境要求

- **Flutter** 3.44.1（stable）
- **Dart** 3.12.1
- **Android** minSdk 24 · targetSdk 36
- **iOS** 最低版本见 `ios/Podfile`
