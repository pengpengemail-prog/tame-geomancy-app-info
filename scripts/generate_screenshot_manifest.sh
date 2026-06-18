#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

OUTPUT_FILE="AppStoreAssets/MANIFEST.md"

expected_public=(
  "01-dual-compass.png"
  "02-opening-reference.png"
  "03-flying-star.png"
  "04-floor-plan-heatmap.png"
  "05-bazhai.png"
  "06-record-share.png"
)

get_prop() {
  local file="${1:-}"
  local key="${2:-}"
  sips -g "$key" "$file" 2>/dev/null | awk -F': ' -v prop="$key" '$1 ~ prop {print $2}' | tail -1 | xargs
}

write_public_section() {
  local dir="${1:-}"
  local label="${2:-}"
  local name=""

  {
    echo "## $label"
    echo
    echo "| 文件 | 状态 | 格式 | Alpha | 尺寸 |"
    echo "| --- | --- | --- | --- | --- |"
  } >> "$OUTPUT_FILE"

  for name in "${expected_public[@]}"; do
    local file="$dir/$name"
    if [[ -f "$file" ]]; then
      local format has_alpha width height
      format="$(get_prop "$file" format | tr '[:upper:]' '[:lower:]')"
      has_alpha="$(get_prop "$file" hasAlpha | tr '[:upper:]' '[:lower:]')"
      width="$(get_prop "$file" pixelWidth)"
      height="$(get_prop "$file" pixelHeight)"
      echo "| $name | 已存在 | ${format:-unknown} | ${has_alpha:-unknown} | ${width:-?}x${height:-?} |" >> "$OUTPUT_FILE"
    else
      echo "| $name | 缺失 | - | - | - |" >> "$OUTPUT_FILE"
    fi
  done

  echo >> "$OUTPUT_FILE"
}

write_review_only_section() {
  {
    echo "## review-only"
    echo
    echo "| 文件 | 格式 | Alpha | 尺寸 |"
    echo "| --- | --- | --- | --- |"
  } >> "$OUTPUT_FILE"

  local found=0
  local file=""
  while IFS= read -r -d '' file; do
    found=1
    local base format has_alpha width height
    base="$(basename "$file")"
    format="$(get_prop "$file" format | tr '[:upper:]' '[:lower:]')"
    has_alpha="$(get_prop "$file" hasAlpha | tr '[:upper:]' '[:lower:]')"
    width="$(get_prop "$file" pixelWidth)"
    height="$(get_prop "$file" pixelHeight)"
    echo "| $base | ${format:-unknown} | ${has_alpha:-unknown} | ${width:-?}x${height:-?} |" >> "$OUTPUT_FILE"
  done < <(find "AppStoreAssets/review-only" -maxdepth 1 -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' \) -print0)

  if [[ "$found" -eq 0 ]]; then
    echo "| 无 | - | - | - |" >> "$OUTPUT_FILE"
  fi

  echo >> "$OUTPUT_FILE"
}

cat > "$OUTPUT_FILE" <<'EOF'
# TAME Space Compass Screenshot Manifest

更新时间：自动生成

本清单用于核对 `AppStoreAssets/` 当前实际素材情况。

EOF

write_public_section "AppStoreAssets/zh-Hans" "zh-Hans"
write_public_section "AppStoreAssets/en-US" "en-US"
write_review_only_section

echo "Generated screenshot manifest at $OUTPUT_FILE"
