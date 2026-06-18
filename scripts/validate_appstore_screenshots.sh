#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

failures=0

expected_public=(
  "01-dual-compass.png"
  "02-opening-reference.png"
  "03-flying-star.png"
  "04-floor-plan-heatmap.png"
  "05-bazhai.png"
  "06-record-share.png"
)

is_expected_public() {
  local candidate="${1:-}"
  local name=""
  for name in "${expected_public[@]}"; do
    if [[ "$candidate" == "$name" ]]; then
      return 0
    fi
  done
  return 1
}

get_prop() {
  local file="${1:-}"
  local key="${2:-}"
  sips -g "$key" "$file" 2>/dev/null | awk -F': ' -v prop="$key" '$1 ~ prop {print $2}' | tail -1 | xargs
}

validate_locale_dir() {
  local dir="${1:-}"
  local label="${2:-}"
  local dims=()
  local name=""

  echo "== Checking $label =="

  for name in "${expected_public[@]}"; do
    local file="$dir/$name"
    if [[ ! -f "$file" ]]; then
      echo "[FAIL] 缺少截图: $file"
      failures=$((failures + 1))
      continue
    fi

    local format="" has_alpha="" width="" height="" dim=""
    local file_failures=0
    format="$(get_prop "$file" format | tr '[:upper:]' '[:lower:]')"
    has_alpha="$(get_prop "$file" hasAlpha | tr '[:upper:]' '[:lower:]')"
    width="$(get_prop "$file" pixelWidth)"
    height="$(get_prop "$file" pixelHeight)"
    dim="${width}x${height}"

    if [[ "$format" != "png" ]]; then
      echo "[FAIL] 公开截图必须为 PNG: $file (format=$format)"
      failures=$((failures + 1))
      file_failures=$((file_failures + 1))
    fi

    if [[ "$has_alpha" == "yes" ]]; then
      echo "[FAIL] PNG 不可带 alpha: $file"
      failures=$((failures + 1))
      file_failures=$((file_failures + 1))
    fi

    if [[ -z "$width" || -z "$height" ]]; then
      echo "[FAIL] 无法读取尺寸: $file"
      failures=$((failures + 1))
      file_failures=$((file_failures + 1))
    elif (( height <= width )); then
      echo "[FAIL] 截图应为竖图: $file (${dim})"
      failures=$((failures + 1))
      file_failures=$((file_failures + 1))
    fi

    if [[ "$file_failures" -eq 0 ]]; then
      echo "[OK] $name -> ${dim}, alpha=${has_alpha}"
      dims+=("$dim")
    fi
  done

  local unexpected=""
  local extra_file=""
  local base=""
  while IFS= read -r -d '' extra_file; do
    base="$(basename "$extra_file")"
    if ! is_expected_public "$base"; then
      unexpected+="$extra_file"$'\n'
    fi
  done < <(find "$dir" -maxdepth 1 -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' \) -print0)
  if [[ -n "$unexpected" ]]; then
    echo "[WARN] 发现未在公开清单中的截图文件:"
    printf '%s' "$unexpected"
  fi

  if [[ ${#dims[@]} -gt 0 ]]; then
    local unique_dims=""
    unique_dims="$(printf '%s\n' "${dims[@]}" | sort -u)"
    local unique_count=""
    unique_count="$(printf '%s\n' "$unique_dims" | sed '/^$/d' | wc -l | tr -d ' ')"
    if [[ "$unique_count" -gt 1 ]]; then
      echo "[FAIL] 同一 locale 的公开截图尺寸不一致:"
      echo "$unique_dims"
      failures=$((failures + 1))
    else
      echo "[OK] $label 尺寸一致: $(printf '%s' "$unique_dims")"
    fi
  fi

  echo
}

validate_review_only_dir() {
  local dir="${1:-}"
  echo "== Checking review-only =="

  local collision=""
  local name=""
  for name in "${expected_public[@]}"; do
    if [[ -f "$dir/$name" ]]; then
      collision+="$dir/$name"$'\n'
    fi
  done

  if [[ -n "$collision" ]]; then
    echo "[FAIL] review-only 目录不应复用公开截图文件名:"
    printf '%s' "$collision"
    failures=$((failures + 1))
  else
    echo "[OK] review-only 未混用公开截图文件名"
  fi

  local count=""
  count="$(find "$dir" -maxdepth 1 -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' \) | wc -l | tr -d ' ')"
  if [[ "$count" -eq 0 ]]; then
    echo "[WARN] review-only 目录当前无审核辅助素材"
  else
    echo "[OK] review-only 素材数: $count"
  fi

  echo
}

validate_locale_dir "AppStoreAssets/zh-Hans" "zh-Hans"
validate_locale_dir "AppStoreAssets/en-US" "en-US"
validate_review_only_dir "AppStoreAssets/review-only"

if [[ "$failures" -gt 0 ]]; then
  echo "Screenshot Validation: FAIL ($failures)"
  exit 1
else
  echo "Screenshot Validation: PASS"
fi
