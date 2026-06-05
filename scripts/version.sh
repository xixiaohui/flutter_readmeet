#!/bin/bash

VERSION_NAME=$(date +%Y.%m.%d)
BUILD_NUMBER=$(date +%s)

echo "$VERSION_NAME+$BUILD_NUMBER"