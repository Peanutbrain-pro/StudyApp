@echo off
echo =======================================
echo Building Milkdown Editor HTML Bundle...
echo =======================================
cd editor
call pnpm install --frozen-lockfile
call pnpm build
cd ..
echo =======================================
echo Milkdown Editor bundle updated in assets/editor_bundle/index.html!
echo =======================================
