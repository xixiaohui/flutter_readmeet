# 首页 UI 优化设计文档

**日期**：2026-06-06  
**状态**：已确认  
**方案**：方案二 — 视觉提升

---

## 目标

在保持 Cupertino 风格基础上，提升首页视觉层次和交互体验：
- 静态单张英雄图 → 多篇轮播
- 所有栏目统一布局 → 差异化卡片（网格 + 横向滑动）
- 无加载态 → Shimmer 骨架屏
- 搜索图标无效 → 启用搜索跳转
- 无下拉刷新 → 下拉刷新整个首页

---

## 一、整体布局结构

```
┌─────────────────────────────────┐
│  Navigation Bar                 │
│  [Readmeet]              [🔍]  │  ← 搜索图标启用
├─────────────────────────────────┤
│  Hero Carousel (自动轮播)        │  ← 3~5 篇精选，PageView + 指示器
│  • 封面图全宽 + 渐变遮罩          │
│  • 标题 & 作者叠加在图片上         │
│  • 3 秒自动翻页 + 手动滑动         │
├─────────────────────────────────┤
│  最新文章                        │
│  ┌─────────┐ ┌─────────┐       │  ← 2 列网格
│  │ 网格卡片 │ │ 网格卡片 │       │
│  └─────────┘ └─────────┘       │
│          [查看全部 →]            │
├─────────────────────────────────┤
│  中文精选  ──→  横向滑动卡片      │
├─────────────────────────────────┤
│  日文精选  ──→  横向滑动卡片      │
├─────────────────────────────────┤
│  Shakespeare  ──→  横向滑动卡片  │
│  ...更多作者栏目                  │
└─────────────────────────────────┘
```

## 二、英雄轮播（Hero Carousel）

### 数据
- 从 `/api/blogs?page=1&pageSize=5` 获取最新 5 篇
- 替换当前硬编码 `blog_index=23876` 的单篇 `HeroTile`

### 布局
- `PageView` 全宽，图片区高度响应式：iPhone 220px / iPad 350px
- 底部渐变遮罩（黑色 0% → 60% opacity）
- 标题 28px white bold + 作者 15px white 0.8 opacity 叠加在图片上
- 「开始阅读 →」按钮在文字下方
- 圆点指示器（当前页高亮）

### 交互
- 3 秒自动翻页，用户手动滑动后重置计时器
- 切换动画：`Curves.easeInOut`，400ms
- 图片视差：滑动时图片偏移量 = 文字偏移 × 0.3
- 首次加载：图片从 0.9 scale → 1.0 + 淡入

### 加载态
- Shimmer 骨架屏：灰色矩形占位，带微光动画

## 三、最新文章 — 双列网格

### 数据
- 来源：`searchBlogs('最新', limit: 6)`（保持现有）
- 加载态：6 个 Shimmer 骨架卡片

### 布局（响应式）
| 设备 | 列数 | 间距 |
|------|------|------|
| iPhone | 2 列 | 12px |
| iPad | 3 列 | 16px |

### 卡片设计
```
┌──────────────────┐
│  封面图           │  圆角 12px，高 120px
│  (CachedNetwork) │
├──────────────────┤
│  文章标题         │  15px, 最多 2 行, AppColors.ink
│  ● 作者名 · 标签  │  12px, AppColors.inkMuted48
└──────────────────┘
```

### 交互
- 点击 → `DetailPage`
- 长按 → 触觉反馈 + 收藏/分享快捷菜单
- 「查看全部 →」→ `HotPage(query: '最新')`

## 四、作者/语言精选 — 横向滑动

### 数据
- 栏目：中文精选、日文精选、Shakespeare、Twain、Byron、Jefferson、Lincoln、Sand、Burnand
- 每栏 `limit: 6`（保持现有 API 调用）
- 加载态：每行 4 个 Shimmer 占位卡片

### 卡片设计（160×200px）
```
┌──────────────┐
│              │
│   封面图      │  封面占卡片 70% 面积
│   (圆角12px)  │
│              │
├──────────────┤
│  文章标题     │  1 行, 14px
│  ● 作者名     │  12px, 圆形头像+名称
└──────────────┘
```

### 交互
- 横向滑动，右边缘渐隐提示可滑动
- 点击卡片 → `DetailPage`
- 「查看全部」→ `HotPage`（保持现有逻辑）
- 首次加载：每行卡片依次从右淡入（staggered fade-in, 100ms interval）

## 五、全局功能

### Shimmer 骨架屏
- 新增 `ShimmerWrapper` 组件：灰色底 + 半透明渐变从左到右扫过（`AnimationController` 驱动）
- 各区块的骨架形状对应实际卡片布局
- Hero 区：矩形 220px 高
- 网格区：6 个圆角矩形卡片占位
- 横向滑动区：4 个圆角矩形卡片占位

### 下拉刷新
- 整个首页内容包裹在 `CupertinoSliverRefreshControl` 或 `RefreshIndicator` 中
- 下拉时重新并行加载所有数据（`Future.wait` 优化）
- 刷新完成后一次性 `setState` 更新全部内容

### 搜索启用
- 导航栏右侧搜索图标 → 推送 `SearchPage`（新建，调用 `searchBlogs`）
- 搜索页包含搜索输入框 + 结果列表（复用 `BlogRow`）

### 错误处理改进
- 所有栏目加载失败时显示轻量错误提示 + 重试按钮
- Hero 区失败 → 显示默认占位 + 重试
- 各栏目失败 → 「加载失败，轻触重试」文字

## 六、代码结构

### 新增文件
| 文件 | 职责 |
|------|------|
| `lib/widgets/shimmer.dart` | Shimmer 动画包装器 |
| `lib/widgets/section_header.dart` | 栏目标题行（标题 + 查看全部） |
| `lib/pages/home/widgets/hero_carousel.dart` | 英雄轮播组件 |
| `lib/pages/home/widgets/grid_card.dart` | 双列网格卡片 |
| `lib/pages/home/widgets/horizontal_card.dart` | 横向滑动卡片（升级版） |
| `lib/pages/search/search_page.dart` | 搜索页面 |

### 修改文件
| 文件 | 变更 |
|------|------|
| `lib/pages/home/home_page.dart` | 重构：使用新组件、下拉刷新、shimmer 加载态、并行数据加载 |
| `lib/pages/home/widgets/featured_card.dart` | 升级为 horizontal_card.dart 的设计 |
| `lib/pages/home/widgets/hero_tile.dart` | 替换为 hero_carousel.dart |

## 七、性能优化

- 11 个 API 调用改为 `Future.wait` 并行发出（截止时间 10s）
- `CachedNetworkImage` 已有缓存，无需改动
- 图片懒加载：滚动到附近才加载（ListView.builder 默认行为）
- 页面 dispose 时取消所有 pending 请求（通过 `_mounted` 检查）
