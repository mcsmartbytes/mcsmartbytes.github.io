#!/usr/bin/env bash
set -euo pipefail

# Vercel build script for Flutter Web
# - Installs Flutter (stable) into /tmp/flutter
# - Enables web, gets dependencies, builds with env.json
# - Copies vercel.json into build output

echo "[vercel_build] Installing Flutter stable..."
mkdir -p /tmp
git clone --depth 1 -b stable https://github.com/flutter/flutter.git /tmp/flutter >/dev/null 2>&1
export PATH="/tmp/flutter/bin:$PATH"
flutter --version

echo "[vercel_build] Enabling web target..."
flutter config --enable-web

echo "[vercel_build] Running flutter pub get..."
flutter pub get

echo "[vercel_build] Building web (release) with env.json..."
flutter build web --release --dart-define-from-file=env.json

echo "[vercel_build] Copying vercel.json into build/web..."
cp -f web/vercel.json build/web/ 2>/dev/null || true

echo "[vercel_build] Done. Output at: build/web"

