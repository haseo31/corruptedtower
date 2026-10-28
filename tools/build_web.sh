#!/usr/bin/env bash
# Builds the web version of the game into build/web/ (needs the Godot 4.7.2 export templates).
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build/web
"tools/godot/Godot_v4.7.2-stable_win64_console.exe" --headless --path . --export-release "Web" build/web/index.html
echo "Built: build/web/index.html"
