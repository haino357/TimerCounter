#!/bin/zsh
# Release ビルドを作り、アプリケーションフォルダに入れる。
# 入れたあとは Finder・Launchpad・Spotlight からアイコンで起動できる。
# 使い方: scripts/install.sh [インストール先フォルダ]   （省略時は /Applications）
set -euo pipefail

cd "$(dirname "$0")/.."
dest="${1:-/Applications}"
app="build/Build/Products/Release/TimerCounter.app"

xcodebuild -project TimerCounter.xcodeproj -scheme TimerCounter \
    -configuration Release -derivedDataPath build -quiet build

# 古いファイルが残らないよう、入れ替える
rm -rf "$dest/TimerCounter.app"
ditto "$app" "$dest/TimerCounter.app"

echo "インストールしました: $dest/TimerCounter.app"
