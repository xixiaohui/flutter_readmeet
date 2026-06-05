#!/bin/bash

KEYSTORE_PATH="android/app/upload-keystore.jks"

if [ ! -f "$KEYSTORE_PATH" ]; then
  echo "🔐 生成 keystore..."

  keytool -genkeypair \
    -v \
    -keystore $KEYSTORE_PATH \
    -storepass readmeet2026 \
    -keypass readmeet2026 \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -alias upload \
    -dname "CN=Dev, OU=Dev, O=Company, L=City, S=State, C=CN"

  echo "storePassword=readmeet2026" > android/key.properties
  echo "keyPassword=readmeet2026" >> android/key.properties
  echo "keyAlias=upload" >> android/key.properties
  echo "storeFile=upload-keystore.jks" >> android/key.properties

else
  echo "🔐 keystore 已存在"
fi