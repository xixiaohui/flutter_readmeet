# Plan: Android Adaptive Icon 自动生成方案

## Context

- **Logo 源文件**: `assets/logo.png` — 1254×1254 PNG (~976KB)，已就位
- **现状**: Android 仍使用 Flutter 默认占位图标（5 个小 PNG），无 adaptive icon 支持
- **目标**: 自动从 logo 生成所有 Android 密度桶图标 + Android 8.0+ adaptive icon（前景/背景分层）

---

## 方案：使用 `flutter_launcher_icons` 包（推荐）

这是 Flutter 生态中最标准的图标自动生成方案，零手动裁剪。

### Step 1: 添加 dev dependency

```bash
flutter pub add --dev flutter_launcher_icons
```

### Step 2: 配置 `pubspec.yaml`

在 `pubspec.yaml` 末尾添加配置块：

```yaml
flutter_launcher_icons:
  android: true
  image_path: "assets/logo.png"
  adaptive_icon_background: "#FFFFFF"       # 自适应图标背景色（白色）
  adaptive_icon_foreground: "assets/logo.png" # 自适应图标前景（logo）
  min_sdk_android: 21                        # 最低 API 21
```

同时需要把 `assets/logo.png` 注册到 Flutter assets：

```yaml
flutter:
  assets:
    - assets/logo.png
```

### Step 3: 生成图标

```bash
flutter pub run flutter_launcher_icons
```

### 自动生成的内容

| 生成物 | 说明 |
|--------|------|
| `mipmap-mdpi/ic_launcher.png` (48×48) | 低密度 |
| `mipmap-hdpi/ic_launcher.png` (72×72) | 中密度 |
| `mipmap-xhdpi/ic_launcher.png` (96×96) | 高密度 |
| `mipmap-xxhdpi/ic_launcher.png` (144×144) | 超高密度 |
| `mipmap-xxxhdpi/ic_launcher.png` (192×192) | 超超高密度 |
| `mipmap-anydpi-v26/ic_launcher.xml` | Adaptive icon 定义 |
| `drawable/ic_launcher_background.xml` | 背景层（纯色 #FFFFFF） |
| `drawable/ic_launcher_foreground.xml` | 前景层（缩放后的 logo） |

### Adaptive Icon 自动剪切原理

`flutter_launcher_icons` 自动处理：
- Logo 缩放到 108dp 画布的安全区域（66dp 内圈）
- 自动添加 18dp 四边留白（OEM 启动器会裁切外层）
- 前景层居中放置，适配圆形/方形/圆角方形等多种 OEM 遮罩

---

## 验证方式

1. `flutter pub run flutter_launcher_icons` 无报错
2. 检查 `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` 是否生成
3. `flutter build apk` 构建成功
4. 安装到 Android 设备/模拟器，确认桌面图标显示正确

---

## 涉及文件

| 操作 | 文件 |
|------|------|
| 新增依赖 | `pubspec.yaml` (dev_dependencies) |
| 新增配置 | `pubspec.yaml` (flutter_launcher_icons + assets 声明) |
| 自动覆盖 | `android/app/src/main/res/mipmap-*/ic_launcher.png`（5 个密度桶） |
| 自动创建 | `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` |
| 自动创建 | `android/app/src/main/res/drawable/ic_launcher_background.xml` |
| 自动创建 | `android/app/src/main/res/drawable/ic_launcher_foreground.xml` |

---

## 补充：背景色可自定义

`adaptive_icon_background` 支持任何 hex 颜色。如果 logo 本身有品牌背景色，建议使用对应色值；如果 logo 是透明底，建议用白色 `#FFFFFF` 或应用主题色。
