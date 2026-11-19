#!/usr/bin/env bash
set -e
echo "======================================="
echo "Building Milkdown Editor HTML Bundle..."
echo "======================================="
cd editor
pnpm install --frozen-lockfile
pnpm build
cd ..
echo "======================================="
echo "Milkdown Editor bundle updated in assets/editor_bundle/index.html!"
echo "======================================="
