# 情书 App 设计规格

> 2026-06-02 · 一次性付费下载 · Apple Store iOS 应用

## 概述

将现有 Flutter 计数器项目改造为一款名为"情书"的电子书/博客阅读应用。内容通过 REST API 从 `readmeet.club` 获取，使用 Cupertino 原生 iOS 风格，按 Apple 设计规范（DESIGN.md）优化视觉细节。

- **Base URL**: `https://readmeet.club/api`
- **目标平台**: iOS（优先）、Android（兼容）
- **商业模式**: Apple Store 一次性付费下载
- **UI 风格**: Cupertino 原生 + Apple 设计规范
- **最低版本**: iOS 15.0, Android 6.0

---

## 架构

```
CupertinoApp
  └── CupertinoTabScaffold
        ├── Tab 1: HomePage
        │     ├── HeroTile (暗色大图区域，展示精选文章)
        │     ├── FeaturedCards (横向滚动精选卡片)
        │     └── "查看全部" → push ListPage
        ├── Tab 2: ListPage
        │     ├── SearchBar (pill 搜索框)
        │     ├── BlogRow[] (列表行，上拉加载更多)
        │     └── 点击行 → push DetailPage
        └── DetailPage (push，非 tab)
              ├── HeroImage (顶部封面大图)
              └── ContentCard (Markdown 渲染正文)
```

## 页面设计

### Home 页（Tab 1）

**HeroTile**: 暗色背景（`#272729`），展示最新/精选文章的封面大图 + 标题（`display-lg` 规格）+ 副标题 + 蓝色 pill 按钮"开始阅读"

**FeaturedCards**: 白色背景区域，标题"最新文章"，横向滚动精选卡片（parchment 底色 `#f5f5f7`，`rounded-lg` 18px），每张卡片含封面缩略图 + 标题 + 作者名

**底部搜索**: 搜索输入框（pill 形状），点击跳转至搜索页

### List 页（Tab 2）

**BlogRow**: 封面缩略图（90x90, `rounded-sm` 8px）+ 标题（15px / 600）+ 摘要（13px，两行）+ 作者头像（18px 圆形）+ 作者名 + tag 标签胶囊

**分页**: 上拉触底加载更多，`page` + `pageSize=20`，使用 `total` 计算是否还有更多

**搜索**: 顶部 pill 搜索框，输入关键词后调用 `searchall` 接口，结果替换当前列表

### Detail 页（Push）

**HeroImage**: 文章封面图全宽展示，高度约 200px

**ContentCard**: 白色圆角卡片（`rounded-lg` 18px），向上覆盖封面图底部形成叠加效果。标题 26px/600，作者信息行，正文 17px/400/1.8 行高（Markdown 渲染），引用块蓝色左边框

**底部操作栏**: 蓝色 pill 按钮

**导航**: 左上角蓝色"← 返回"文字链接

---

## 数据流

```
HomePage                    ListPage                   DetailPage
  │                           │                           │
  │ GET /blogs                │ GET /blogs                │ GET /blogs/:id
  │   page=1, pageSize=5     │   page=N, pageSize=20     │
  ▼                           ▼                           ▼
featured blogs[]          all blogs[] + total       blog detail + content
  │                           │                        (markdown)
  │ 点击/查看全部             │ 点击行                   
  ▼                           ▼                          
push ──────────────────► DetailPage ◄──────────────── push
```

每个页面独立管理三种状态：`loading` / `error` / `data`

---

## API 接口

| 接口 | 方法 | 路径 | 用途 |
|------|------|------|------|
| 博客列表 | GET | `/api/blogs?page=N&pageSize=20` | List 页分页列表 |
| 首页精选 | GET | `/api/blogs?page=1&pageSize=5` | Home 页精选卡片 |
| 博客详情 | GET | `/api/blogs/:id` | Detail 页完整内容 |
| 搜索 | GET | `/api/blogs/searchall?q=keyword&limit=20&offset=0` | 搜索功能 |

数据模型 `CardItem`:
```dart
class CardItem {
  final int id;
  final String? img;
  final String? tag;
  final String title;
  final String? description;
  final List<Author> authors;
  final String? content;      // 仅详情接口返回，Markdown 格式
  final String? createdAt;
  final String? slug;
  final String? blogIndex;
}
```

---

## 依赖包

```yaml
dependencies:
  http: ^1.2.0                    # HTTP 网络请求
  flutter_markdown: ^0.7.0        # Markdown 内容渲染
  cached_network_image: ^3.3.0    # 远程图片缓存与懒加载
  intl: ^0.19.0                   # 日期格式化
```

---

## iOS 专项优化

| 项目 | 实现方式 |
|------|---------|
| 安全区域 | `SafeArea` + `CupertinoPageScaffold` 自动适配 |
| 触觉反馈 | `HapticFeedback.lightImpact()` 用于按钮和交互 |
| 毛玻璃导航 | `BackdropFilter` + `ClipRect` 实现导航栏模糊效果 |
| SF Pro 字体 | iOS 系统自带，使用 `fontFamily: '.SF Pro Text'` 和 `'.SF Pro Display'` |
| 暗色模式 | 自动跟随系统，深色表面用纯黑 `#000000`，浅色用 `#ffffff` |
| 最低版本 | iOS 15.0 |
| 付费模式 | Apple Store 一次性付费下载（非 IAP） |

---

## 文件结构

```
lib/
├── main.dart
├── app.dart
├── config/
│   └── api.dart
├── models/
│   ├── card_item.dart
│   └── author.dart
├── services/
│   └── api_service.dart
├── pages/
│   ├── home/
│   │   ├── home_page.dart
│   │   └── widgets/
│   │       ├── hero_tile.dart
│   │       └── featured_card.dart
│   ├── list/
│   │   ├── list_page.dart
│   │   └── widgets/
│   │       ├── blog_row.dart
│   │       └── search_bar.dart
│   └── detail/
│       ├── detail_page.dart
│       └── widgets/
│           ├── hero_image.dart
│           └── content_card.dart
├── widgets/
│   └── loading_indicator.dart
└── theme/
    └── app_theme.dart
```

---

## 暂不实现

- 阅读标记功能（`POST /api/blogMark`），后续版本添加
- 文件列表功能（`GET /api/files`），后续版本添加
- 用户账户/登录系统

---

## 空状态与错误处理

- **加载中**: `CupertinoActivityIndicator` 居中显示
- **网络错误**: 显示错误信息 + "重试"按钮
- **空列表**: 居中文字 "暂无文章"
- **搜索无结果**: 居中文字 "未找到相关内容"
- **404**: 显示 "文章不存在"

---

## 设计规范参照

- **DESIGN.md**: Apple 设计语言 — Action Blue `#0066cc` 为唯一交互色，SF Pro 字体系统，17px 正文，交替明暗 tile，pill 按钮，单投影规则
- **api_doc.md**: API 1-4 接口完整覆盖，Markdown 内容渲染，分页策略
