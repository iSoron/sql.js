#!/usr/bin/env bash
# Standalone build script for custom sql.js
set -euo pipefail

EMSDK_VERSION="3.1.64"
SQLJS_VERSION="v1.11.0"
OUTPUT_DIR="./output"

# 1. Setup temporary build workspace
BUILD_DIR=".sqljs-build-tmp"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

echo "Downloading sql.js $SQLJS_VERSION..."
git clone --depth 1 https://github.com/sql-js/sql.js.git "$BUILD_DIR"
cd "$BUILD_DIR"
git fetch --tags --depth 1 origin "$SQLJS_VERSION"
git checkout FETCH_HEAD

echo "Patching sql.js for Loop Habit Tracker..."
# Export FS for filesystem access
perl -pi -e 's/"addFunction"/"addFunction", "FS"/' src/exported_runtime_methods.json
# Fix SHA3 check for environments without sha3sum
perl -pi -e 's/sha3sum -a 256 -c cache\/check.txt/openssl dgst -sha3-256 -r .\/cache\/\$(SQLITE_AMALGAMATION).zip | grep -q "^\$(SQLITE_AMALGAMATION_ZIP_SHA3) " || (echo "SHA3 mismatch"; exit 1)/' Makefile

echo "Building sql.js via Docker (emscripten/emsdk:$EMSDK_VERSION)..."
docker run --rm \
    -v "$(pwd):/src" \
    -u "$(id -u):$(id -g)" \
    -w "/src" \
    "emscripten/emsdk:$EMSDK_VERSION" \
    make

# 2. Prepare output artifacts
echo "Preparing output artifacts..."
cd ..
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/dist"
cp "$BUILD_DIR/dist/sql-wasm.js" "$OUTPUT_DIR/dist/"
cp "$BUILD_DIR/dist/sql-wasm.wasm" "$OUTPUT_DIR/dist/"
cp "$BUILD_DIR/package.json" "$OUTPUT_DIR/"
cp -R "$BUILD_DIR/src" "$OUTPUT_DIR/"

# Cleanup
rm -rf "$BUILD_DIR"

echo "Build complete. Artifacts are in $OUTPUT_DIR"
