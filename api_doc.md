# 情书 API 文档 (Qingshu API Documentation)

> 本文档供移动应用（iOS / Android / Flutter / React Native 等）接入使用。

## 基础信息

| 项目 | 说明 |
|------|------|
| **Base URL** | `https://readmeet.club/api` |
| **请求格式** | `application/json` |
| **响应格式** | `application/json` |
| **字符编码** | UTF-8 |

---

## 通用数据结构

### CardItem（博客卡片）

```json
{
  "id": 1,
  "img": "https://example.com/cover.jpg",
  "tag": "精選",
  "title": "文章标题",
  "description": "文章摘要",
  "authors": [
    {
      "name": "作者名",
      "avatar": "https://example.com/avatar.jpg"
    }
  ],
  "content": "Markdown 正文内容（仅详情接口返回）",
  "created_at": "2025-11-12T00:00:00.000Z",
  "slug": "article-slug",
  "blog_index": "001"
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | number | 博客 ID |
| `img` | string | 封面图 URL |
| `tag` | string | 标签/分类 |
| `title` | string | 标题 |
| `description` | string | 摘要描述 |
| `authors` | object[] | 作者列表 |
| `authors[].name` | string | 作者名称 |
| `authors[].avatar` | string | 作者头像 URL |
| `content` | string? | Markdown 正文（仅详情接口） |
| `created_at` | string? | 创建时间 (ISO 8601) |
| `slug` | string? | URL 友好标识 |
| `blog_index` | string? | 博客序号 |

---

## API 接口列表

### 1. 获取博客列表

获取分页博客列表，按创建时间倒序排列。

```
GET /api/blogs
```

**请求参数（Query）**

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| `page` | number | 否 | 1 | 页码，从 1 开始 |
| `pageSize` | number | 否 | 10 | 每页条数 |

**响应示例**

```json
{
  "data": [
    {
      "id": 123,
      "title": "文章标题",
      "created_at": "2025-12-01T10:00:00.000Z",
      "description": "摘要...",
      "tag": "精選",
      "img": "https://...",
      "slug": "article-slug",
      "updated_at": "2025-12-01T10:00:00.000Z",
      "authors": [{ "name": "作者", "avatar": "https://..." }],
      "blog_index": "001"
    }
  ],
  "total": 256
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `data` | CardItem[] | 当前页博客列表 |
| `total` | number | 博客总数（用于计算总页数） |

**移动端使用示例**

```swift
// Swift
let url = URL(string: "\(baseURL)/api/blogs?page=1&pageSize=20")!
```

```kotlin
// Kotlin
val url = "$baseURL/api/blogs?page=1&pageSize=20"
```

---

### 2. 获取博客详情

根据 ID 获取单篇博客完整内容（包含正文）。

```
GET /api/blogs/:identifier
```

**路径参数**

| 参数 | 类型 | 说明 |
|------|------|------|
| `identifier` | number | 博客 ID（与列表中的 `id` 对应） |

**响应示例（成功）**

```json
{
  "id": 123,
  "img": "https://example.com/cover.jpg",
  "tag": "精選",
  "title": "文章标题",
  "description": "摘要描述",
  "authors": [{ "name": "作者名", "avatar": "https://..." }],
  "content": "# Markdown 正文内容\n\n这是完整的文章内容...",
  "created_at": "2025-11-12T00:00:00.000Z",
  "updated_at": "2025-11-12T00:00:00.000Z",
  "slug": "article-slug",
  "blog_index": "001"
}
```

**响应示例（未找到）**

```json
{
  "message": "Blog not found"
}
```
> HTTP Status: `404`

**错误响应**

```json
{
  "message": "Internal Server Error"
}
```
> HTTP Status: `500`

> **注意**：`content` 字段为 Markdown 格式，移动端需使用 Markdown 渲染组件（如 flutter_markdown、MarkdownView 等）展示。

---

### 3. 搜索博客（简单搜索）

按关键字搜索博客，依次匹配标签 → 标题 → 正文，返回首个有结果的匹配。

```
GET /api/blogs/search
```

**请求参数（Query）**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `q` | string | 是 | 搜索关键字 |

**响应示例**

```json
[
  {
    "id": 45,
    "img": "https://...",
    "tag": "表白專欄",
    "title": "搜索结果标题",
    "description": "匹配到的内容...",
    "authors": [{ "name": "作者", "avatar": "https://..." }],
    "slug": "result-slug",
    "blog_index": "045",
    "created_at": "2025-11-01T00:00:00.000Z"
  }
]
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `[]` | CardItem[] | 搜索结果数组（最多 50 条），无结果时返回 `[]` |

**匹配顺序**：`tag` → `title` → `content`（不区分大小写）

**移动端使用示例**

```dart
// Flutter
final response = await http.get(
  Uri.parse('$baseURL/api/blogs/search?q=${Uri.encodeComponent(keyword)}'),
);
```

---

### 4. 搜索全部（全字段搜索）

跨标签、标题、正文同时搜索，支持分页。推荐移动端使用此接口。

```
GET /api/blogs/searchall
```

**请求参数（Query）**

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| `q` | string | 是 | - | 搜索关键字 |
| `limit` | number | 否 | 50 | 返回条数上限 |
| `offset` | number | 否 | 0 | 偏移量（分页） |

**响应示例**

```json
[
  {
    "id": 45,
    "img": "https://...",
    "tag": "表白專欄",
    "title": "搜索结果标题",
    "description": "匹配到的内容...",
    "authors": [{ "name": "作者", "avatar": "https://..." }],
    "slug": "result-slug",
    "blog_index": "045",
    "created_at": "2025-11-01T00:00:00.000Z"
  }
]
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `[]` | CardItem[] | 搜索结果数组，无结果时返回 `[]` |

**分页示例**

```typescript
// 第 1 页
GET /api/blogs/searchall?q=爱情&limit=20&offset=0

// 第 2 页
GET /api/blogs/searchall?q=爱情&limit=20&offset=20
```

**错误响应**

| HTTP Status | 说明 |
|-------------|------|
| `400` | 缺少 `q` 参数 |
| `500` | 服务器内部错误 |

---

### 5. 创建阅读标记

保存用户对博客文本的高亮或下划线标记。

```
POST /api/blogMark
```

**请求体（JSON）**

```json
{
  "id": "uuid-string",
  "blog_id": 123,
  "start": 42,
  "end": 89,
  "bg_color": "#FFEB3B",
  "text_color": "#000000",
  "style": "highlight",
  "excerpt": "被标记的文本内容...",
  "created_at": "2025-12-15T10:30:00.000Z"
}
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `id` | string | 是 | 标记唯一 ID（客户端生成 UUID） |
| `blog_id` | number | 是 | 关联的博客 ID |
| `start` | number | 是 | 标记起始位置（字符索引） |
| `end` | number | 是 | 标记结束位置（字符索引） |
| `bg_color` | string | 是 | 背景颜色（HEX 格式，如 `#FFEB3B`） |
| `text_color` | string | 否 | 文字颜色（HEX 格式） |
| `style` | string | 是 | 标记样式：`"highlight"`（高亮）或 `"underline"`（下划线） |
| `excerpt` | string | 否 | 标记的文本摘录 |
| `created_at` | string | 是 | 创建时间 (ISO 8601) |

**响应示例（成功）**

```json
{
  "success": true
}
```

**响应示例（失败）**

```json
{
  "error": "错误描述信息"
}
```
> HTTP Status: `500`

---


### 6. 获取文件列表

从文件服务器获取文件列表。

```
GET /api/files
```

**请求参数**

无。

**响应示例（成功）**

```json
{
  "success": true,
  "files": [
    {
      "name": "example.pdf",
      "size": 102400,
      "url": "https://files.readmeet.club/...",
      "updated_at": "2025-12-01T00:00:00.000Z"
    }
  ]
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `success` | boolean | 是否成功 |
| `files` | object[] | 文件列表（具体字段取决于文件服务器返回） |

**响应示例（失败）**

```json
{
  "success": false,
  "message": "请求文件服务器失败"
}
```
> HTTP Status: `500`

> **说明**：此接口代理转发至内部文件服务器 `files.readmeet.club`，需要服务端配置 `FILE_SERVER_API_KEY` 环境变量。

---

## 接口汇总

| 序号 | 方法 | 路径 | 说明 | 分页 |
|------|------|------|------|------|
| 1 | `GET` | `/api/blogs` | 博客列表 | ✅ page/pageSize |
| 2 | `GET` | `/api/blogs/:identifier` | 博客详情（含正文） | - |
| 3 | `GET` | `/api/blogs/search` | 简单搜索 | 固定 50 条 |
| 4 | `GET` | `/api/blogs/searchall` | 全字段搜索 | ✅ limit/offset |
| 5 | `POST` | `/api/blogMark` | 创建阅读标记 | - |
| 6 | `GET` | `/api/files` | 文件列表 | - |

---

## 错误处理

所有接口在异常情况下返回统一格式：

```json
{
  "message": "错误描述"
}
```

或

```json
{
  "error": "错误描述"
}
```

### HTTP 状态码一览

| 状态码 | 说明 |
|--------|------|
| `200` | 请求成功 |
| `400` | 请求参数错误（如缺少必填参数） |
| `404` | 资源不存在 |
| `500` | 服务器内部错误 |

---

## 移动端接入建议

1. **Base URL 管理**：建议通过配置文件或环境变量管理 Base URL，方便切换开发/生产环境。

2. **网络层封装**：封装统一的网络请求层，处理以下逻辑：
   - 请求/响应日志
   - 错误统一处理
   - Token 认证（如后续接入）
   - 请求重试

3. **数据缓存**：对于博客列表和详情，建议在客户端做适当的本地缓存，减少重复请求。

4. **Markdown 渲染**：博客内容为 Markdown 格式，推荐使用：
   - iOS: [MarkdownUI](https://github.com/gonzalezreal/swift-markdown-ui)
   - Android: [Markwon](https://github.com/noties/Markwon)
   - Flutter: [flutter_markdown](https://pub.dev/packages/flutter_markdown)
   - React Native: [react-native-markdown-display](https://github.com/iamacup/react-native-markdown-display)

5. **图片加载**：封面图和头像使用远程 URL，建议集成图片加载库（如 SDWebImage、Glide、Coil 等）实现懒加载和缓存。

6. **分页策略**：
   - 列表接口：使用 `page` + `pageSize`，通过 `total` 计算总页数
   - 搜索接口：使用 `limit` + `offset`，无匹配数据时 `[]` 表示已到末尾
