#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

REPORT_FILE="SubmissionKit/PREFLIGHT_REPORT.md"
BUILD_LOG=".build-cache/preflight_build.log"
SIMCTL_RUNTIMES_LOG=".build-cache/preflight_simctl_runtimes.log"
SIMCTL_DEVICES_LOG=".build-cache/preflight_simctl_devices.log"
DIAGNOSTICS_REPORT=".build-cache/xcode_simulator_diagnostics.md"

mkdir -p ".build-cache"
mkdir -p "SubmissionKit"

xcodegen_status="未执行"
build_status="未执行"
readiness_status="未执行"
manifest_status="未执行"
weblegal_status="未执行"
diagnostics_status="未执行"
overall_status="PASS"
submission_verdict="$(perl -ne 'if (/当前状态仍为：`([^`]+)`/) { print $1; exit }' FINAL_EXECUTION_BOARD.md 2>/dev/null || true)"
display_name="$(perl -0ne 'if (/<key>CFBundleDisplayName<\/key>\s*<string>([^<]+)<\/string>/s) { print $1; exit }' TAMEGeomancy/Resources/Info.plist 2>/dev/null || true)"

if [[ -z "$submission_verdict" ]]; then
  submission_verdict="需补充验证后再提交"
fi

if [[ -z "$display_name" ]]; then
  display_name="未读取到"
fi

run_step() {
  local label="${1:-}"
  shift
  echo "== $label =="
  if "$@"; then
    echo "[OK] $label"
    return 0
  else
    echo "[FAIL] $label"
    return 1
  fi
}

echo "Running preflight audit..."

if run_step "XcodeGen" xcodegen -s project.yml -p . -r . >/dev/null 2>&1; then
  xcodegen_status="PASS"
else
  xcodegen_status="FAIL"
  overall_status="FAIL"
fi

if CLANG_MODULE_CACHE_PATH="$PWD/.build-cache/module-cache" \
   SWIFT_MODULE_CACHE_PATH="$PWD/.build-cache/module-cache" \
   xcodebuild -project TAMEGeomancy.xcodeproj \
     -scheme TAMEGeomancy \
     -derivedDataPath "$PWD/.DerivedData" \
     -destination "generic/platform=iOS Simulator" build \
     >"$BUILD_LOG" 2>&1; then
  build_status="PASS"
else
  build_status="FAIL"
  overall_status="FAIL"
fi

if zsh "scripts/readiness_check.sh" >/tmp/tamegeomancy-readiness.txt 2>&1; then
  readiness_status="PASS"
else
  readiness_status="FAIL"
  overall_status="FAIL"
fi

if zsh "scripts/generate_screenshot_manifest.sh" >/tmp/tamegeomancy-manifest.txt 2>&1; then
  manifest_status="PASS"
else
  manifest_status="FAIL"
  overall_status="FAIL"
fi

if zsh "scripts/build_weblegal_dist.sh" >/tmp/tamegeomancy-weblegal.txt 2>&1; then
  weblegal_status="PASS"
else
  weblegal_status="FAIL"
  overall_status="FAIL"
fi

if zsh "scripts/diagnose_xcode_simulator.sh" >/tmp/tamegeomancy-xcode-simulator-diagnostics.txt 2>&1; then
  diagnostics_status="PASS"
else
  diagnostics_status="FAIL"
  overall_status="FAIL"
fi

xcrun simctl list runtimes >"$SIMCTL_RUNTIMES_LOG" 2>&1 || true
xcrun simctl list devices available >"$SIMCTL_DEVICES_LOG" 2>&1 || true

cat > "$REPORT_FILE" <<EOF
# TAME Space Compass Preflight Report

更新时间：$(date '+%Y-%m-%d %H:%M:%S %z')

## 总结论

- 总状态：\`$overall_status\`
- 当前显示名：\`$display_name\`
- 当前提交判断：\`$submission_verdict\`
- 当前提交判断仍应结合 \`FINAL_EXECUTION_BOARD.md\`

## 子项结果

| 项目 | 状态 | 说明 |
| --- | --- | --- |
| XcodeGen | $xcodegen_status | 已按 \`project.yml\` 重新同步工程 |
| Xcode build | $build_status | 详见 \`.build-cache/preflight_build.log\` |
| Readiness check | $readiness_status | 详见下方摘录 |
| Screenshot manifest | $manifest_status | 已生成 \`AppStoreAssets/MANIFEST.md\` |
| WebLegal dist | $weblegal_status | 已生成 \`WebLegal/dist/\` |
| Xcode / Simulator diagnostics | $diagnostics_status | 详见 \`$DIAGNOSTICS_REPORT\` |

## Xcode Build 摘录

### Error Lines

\`\`\`text
$(rg -n "error:|CoreSimulator|ibtool|ibtoold|actool|simdiskimaged|No available simulator runtimes|BUILD FAILED|Failed|Unable" "$BUILD_LOG" 2>/dev/null | tail -n 80 || true)
\`\`\`

### Tail

\`\`\`text
$(tail -n 80 "$BUILD_LOG" 2>/dev/null || true)
\`\`\`

## Simulator 只读诊断

完整诊断报告：\`$DIAGNOSTICS_REPORT\`

### Diagnostics Summary

\`\`\`text
$(sed -n '/^## Summary/,/^## xcodebuild -version/p' "$DIAGNOSTICS_REPORT" 2>/dev/null | sed '$d' || true)
\`\`\`

### Runtimes

\`\`\`text
$(tail -n 40 "$SIMCTL_RUNTIMES_LOG" 2>/dev/null || true)
\`\`\`

### Available Devices

\`\`\`text
$(tail -n 80 "$SIMCTL_DEVICES_LOG" 2>/dev/null || true)
\`\`\`

## Readiness Check 摘录

\`\`\`text
$(tail -n 60 /tmp/tamegeomancy-readiness.txt 2>/dev/null || true)
\`\`\`

## 外部 blocker 仍待核销

1. fresh install / smoke test
2. App Store Connect 当前版本状态核对
3. 真实 Support / Privacy / Terms 链接上线并回填
4. App Store Connect 截图上传后的在线预览核对
5. 本机 Xcode build / Simulator 服务链路恢复后重新构建

## 下一步

1. 若 \`Xcode build\` 为 FAIL，先处理 \`.build-cache/preflight_build.log\` 中的构建 / Simulator 服务错误
2. 完成 \`SMOKE_TEST_RUNBOOK.md\`
3. 完成 \`SubmissionKit/02_ASC_Live_Checklist.md\`
4. 在 App Store Connect 上传截图后核对在线预览
5. 在 \`BLOCKER_CLEARANCE_LOG.md\` 中逐项核销
EOF

echo "Generated preflight report at $REPORT_FILE"

if [[ "$overall_status" == "FAIL" ]]; then
  exit 1
fi
