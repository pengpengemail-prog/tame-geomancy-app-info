#!/bin/zsh
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

CACHE_DIR=".build-cache"
REPORT_FILE="$CACHE_DIR/xcode_simulator_diagnostics.md"
SUMMARY_FILE="$CACHE_DIR/xcode_simulator_diagnostics_summary.tmp"

mkdir -p "$CACHE_DIR"
: > "$SUMMARY_FILE"

probe_failures=0

run_probe() {
  local label="$1"
  shift

  local output=""
  local exit_code=0
  if output="$("$@" 2>&1)"; then
    exit_code=0
    printf '| `%s` | PASS |\n' "$label" >> "$SUMMARY_FILE"
  else
    exit_code=$?
    probe_failures=$((probe_failures + 1))
    printf '| `%s` | FAIL (%s) |\n' "$label" "$exit_code" >> "$SUMMARY_FILE"
  fi

  {
    echo
    echo "## $label"
    echo
    echo '```text'
    if [[ -n "$output" ]]; then
      echo "$output"
    else
      echo "<no output>"
    fi
    echo '```'
  } >> "$REPORT_FILE"
}

cat > "$REPORT_FILE" <<EOF
# Xcode / Simulator Read-only Diagnostics

更新时间：$(date '+%Y-%m-%d %H:%M:%S %z')

该报告只执行只读诊断命令，不 reset、不 delete、不 boot 模拟器。

## Summary

| 命令 | 状态 |
| --- | --- |
EOF

run_probe "xcodebuild -version" xcodebuild -version
run_probe "xcode-select -p" xcode-select -p
run_probe "xcrun --find simctl" xcrun --find simctl
run_probe "xcrun simctl list runtimes" xcrun simctl list runtimes
run_probe "xcrun simctl list devices available" xcrun simctl list devices available
run_probe "xcrun simctl list devicetypes" xcrun simctl list devicetypes
run_probe "xcrun simctl list pairs" xcrun simctl list pairs

summary="$(cat "$SUMMARY_FILE")"
perl -0pi -e 's/\| 命令 \| 状态 \|\n\| --- \| --- \|\n/\| 命令 \| 状态 \|\n\| --- \| --- \|\n'"$(printf '%s\n' "$summary" | perl -0pe 's/([\\\/&])/\\$1/g')"'\n/' "$REPORT_FILE"
rm -f "$SUMMARY_FILE"

cat >> "$REPORT_FILE" <<EOF

## Interpretation

- 若 \`simctl list runtimes\` 或 \`simctl list devices available\` 失败，当前构建 / smoke blocker 应优先按 Xcode Simulator 服务链路处理。
- 若只读诊断失败但 Swift parse、截图校验、StoreKit JSON 与 WebLegal 构建均通过，不能把失败直接归因于业务代码。
- 该报告不能替代最终 \`xcodebuild\`、fresh install、App Store Connect 在线核对。
EOF

echo "Generated diagnostics report at $REPORT_FILE"

if [[ "$probe_failures" -gt 0 ]]; then
  exit 1
fi
