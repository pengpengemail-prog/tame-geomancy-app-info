#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE_ICON="/Users/pengpeng/.codex/generated_images/019e5026-cb7b-7b12-a377-8d470bfc73fb/ig_08b66cf9df574b65016a108bbd326c8194831f1f9de73ce73a.png"
OUTPUT_ICON="$ROOT_DIR/TAMEGeomancy/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"

if [[ ! -f "$SOURCE_ICON" ]]; then
  echo "Missing source icon: $SOURCE_ICON" >&2
  exit 1
fi

sips -z 1024 1024 "$SOURCE_ICON" --out "$OUTPUT_ICON" >/dev/null
echo "Generated $OUTPUT_ICON"
