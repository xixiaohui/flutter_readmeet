#!/bin/bash
set -e

ENV=$1

if [ -z "$ENV" ]; then
  echo "❌ 用法: ./build.sh dev|test|prod"
  exit 1
fi

echo "🚀 构建环境: $ENV"

# ======================
# 1. 版本号
# ======================
VERSION=$(bash scripts/version.sh)
echo "📦 version: $VERSION"

if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i "" "s/^version:.*/version: $VERSION/" pubspec.yaml
else
  sed -i "s/^version:.*/version: $VERSION/" pubspec.yaml
fi

# ======================
# 2. 环境变量
# ======================
if [ "$ENV" == "dev" ]; then
  API_URL="https://www.readmeet.club/"
  APP_NAME="Readmeet Dev"
elif [ "$ENV" == "test" ]; then
  API_URL="https://www.readmeet.club/"
  APP_NAME="Readmeet Test"
else
  API_URL="https://www.readmeet.club/"
  APP_NAME="Readmeet"
fi

# ======================
# 3. 签名检查
# ======================
bash scripts/keystore.sh

# ======================
# 4. Flutter准备
# ======================
flutter clean
flutter pub get

# ======================
# 5. 输出目录
# ======================
OUTPUT="build_output/$ENV-$VERSION"
mkdir -p $OUTPUT

# ======================
# 6. Android（重点🔥）
# ======================
echo "📱 Android 构建..."

flutter build appbundle \
  --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define=API_URL=$API_URL \
  --dart-define=APP_NAME="$APP_NAME" \
  --dart-define=ENV=$ENV

cp build/app/outputs/bundle/release/app-release.aab $OUTPUT/

# APK（可选）
flutter build apk --release \
  --dart-define=API_URL=$API_URL \
  --dart-define=APP_NAME="$APP_NAME" \
  --dart-define=ENV=$ENV

cp build/app/outputs/flutter-apk/app-release.apk $OUTPUT/

# ======================
# 7. iOS（半自动）
# ======================
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "🍎 iOS 构建..."

  flutter build ios \
    --release \
    --no-codesign \
    --dart-define=API_URL=$API_URL \
    --dart-define=APP_NAME="$APP_NAME" \
    --dart-define=ENV=$ENV

  echo "👉 用 Xcode archive 上传"
fi

# ======================
# 8. Web（可选）
# ======================
flutter build web \
  --dart-define=API_URL=$API_URL \
  --dart-define=APP_NAME="$APP_NAME" \
  --dart-define=ENV=$ENV

cp -r build/web $OUTPUT/web

# ======================
# 9. changelog
# ======================
git log -5 --pretty=format:"- %s" > $OUTPUT/changelog.txt

# ======================
# 完成
# ======================
echo ""
echo "✅ 构建完成: $OUTPUT"