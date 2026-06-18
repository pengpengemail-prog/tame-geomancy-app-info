#!/bin/zsh
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

REPORT_FILE="SubmissionKit/RELEASE_GATE_REPORT.md"
PREFLIGHT_REPORT="SubmissionKit/PREFLIGHT_REPORT.md"
DIAGNOSTICS_REPORT=".build-cache/xcode_simulator_diagnostics.md"
READINESS_LOG=".build-cache/release_gate_readiness.log"
PREFLIGHT_LOG=".build-cache/release_gate_preflight.log"
DIAGNOSTICS_LOG=".build-cache/release_gate_diagnostics.log"

mkdir -p ".build-cache"
mkdir -p "SubmissionKit"

status_from_report() {
  local label="$1"
  local file="$2"
  local value
  value="$(awk -F'|' -v label="$label" '
    $2 ~ label {
      gsub(/^[ \t]+|[ \t]+$/, "", $3)
      print $3
      exit
    }
  ' "$file" 2>/dev/null || true)"
  if [[ -n "$value" ]]; then
    echo "$value"
  else
    echo "UNKNOWN"
  fi
}

unchecked_count() {
  local file="$1"
  rg -n '^- \[ \]' "$file" 2>/dev/null | wc -l | tr -d ' '
}

run_and_capture() {
  local log_file="$1"
  shift
  if "$@" >"$log_file" 2>&1; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

readiness_status="$(run_and_capture "$READINESS_LOG" zsh scripts/readiness_check.sh)"
diagnostics_status="$(run_and_capture "$DIAGNOSTICS_LOG" zsh scripts/diagnose_xcode_simulator.sh)"
preflight_status="$(run_and_capture "$PREFLIGHT_LOG" zsh scripts/preflight_audit.sh)"

xcodegen_status="$(status_from_report "XcodeGen" "$PREFLIGHT_REPORT")"
xcode_build_status="$(status_from_report "Xcode build" "$PREFLIGHT_REPORT")"
preflight_readiness_status="$(status_from_report "Readiness check" "$PREFLIGHT_REPORT")"
manifest_status="$(status_from_report "Screenshot manifest" "$PREFLIGHT_REPORT")"
weblegal_status="$(status_from_report "WebLegal dist" "$PREFLIGHT_REPORT")"
simulator_status="$(status_from_report "Xcode / Simulator diagnostics" "$PREFLIGHT_REPORT")"

asc_pending="$(unchecked_count "SubmissionKit/02_ASC_Live_Checklist.md")"
final_pending="$(unchecked_count "FINAL_SUBMISSION_CHECKLIST.md")"

critical_blockers="$(
  {
    if ! rg -q "cc-design.*通过|cc-design.*PASS|Visual design gate \\| PASS" \
      "FINAL_SUBMISSION_CHECKLIST.md" "marketing/appstore/review-readiness-matrix.md" 2>/dev/null; then
      if ! command -v cc-design >/dev/null 2>&1; then
        echo "- cc-design command is missing and no local cc-design visual-pass evidence was found."
      fi
    fi
    rg -n "Release archive|ASC API|ASC live|真机 fresh install|cc-design|codesign|IAP 挂载|买断解锁项|在线截图预览|当前版本状态|正确选择最新构建" \
      "FINAL_SUBMISSION_CHECKLIST.md" "marketing/appstore/review-readiness-matrix.md" 2>/dev/null \
      | sed 's/^/- /' || true
  } | sed -n '1,80p'
)"

manual_status="PASS"
if [[ "$asc_pending" -gt 0 || "$final_pending" -gt 0 ]]; then
  manual_status="PENDING"
fi

verdict="需补充验证后再提交"
release_gate_status="BLOCKED"
if [[ "$readiness_status" == "PASS" && "$preflight_status" == "PASS" && "$diagnostics_status" == "PASS" && "$manual_status" == "PASS" ]]; then
  verdict="可进入 App Store Connect 提交流程"
  release_gate_status="PASS"
fi

cat > "$REPORT_FILE" <<EOF
# TAME Space Compass Release Gate Report

更新时间：$(date '+%Y-%m-%d %H:%M:%S %z')

## 总结论

- Release Gate：\`$release_gate_status\`
- 当前提交判断：\`$verdict\`
- 该报告用于防止把“静态材料已通过”误判为“可以提交”

## 自动门禁

| 门禁项 | 状态 | 证据 |
| --- | --- | --- |
| Readiness check | $readiness_status | \`$READINESS_LOG\` |
| Preflight audit | $preflight_status | \`$PREFLIGHT_REPORT\` |
| Xcode / Simulator diagnostics | $diagnostics_status | \`$DIAGNOSTICS_REPORT\` |

## Preflight 子项

| 子项 | 状态 |
| --- | --- |
| XcodeGen | $xcodegen_status |
| Xcode build | $xcode_build_status |
| Readiness check | $preflight_readiness_status |
| Screenshot manifest | $manifest_status |
| WebLegal dist | $weblegal_status |
| Xcode / Simulator diagnostics | $simulator_status |

## 人工 / 外部门禁

| 门禁项 | 状态 | 未核销项数量 |
| --- | --- | --- |
| ASC 在线核对清单 | $manual_status | $asc_pending |
| 最终提交清单 | $manual_status | $final_pending |

## 当前关键阻塞

\`\`\`text
$(rg -n "No available simulator runtimes|CoreSimulatorService|simdiskimaged|CompileAssetCatalogVariant|BUILD FAILED" "$PREFLIGHT_REPORT" 2>/dev/null | tail -n 40 || true)
\`\`\`

## 当前人工 / 外部阻塞摘录

\`\`\`text
${critical_blockers:-No current manual blocker details captured.}
\`\`\`

## 下一步

$(if [[ "$readiness_status" != "PASS" || "$preflight_status" != "PASS" || "$diagnostics_status" != "PASS" ]]; then
  echo "1. 修复自动门禁失败项后重跑 \`./scripts/release_gate.sh\`"
  echo "2. 完成 \`SubmissionKit/02_ASC_Live_Checklist.md\` 中的 ASC 在线状态、build、IAP、截图预览核对"
  echo "3. 完成 \`FINAL_SUBMISSION_CHECKLIST.md\` 中的 fresh install、功能路径、真实链接与上传预览核销"
  echo "4. 所有自动与人工门禁均为 PASS 前，不更新为“可提交”"
else
  echo "1. 自动门禁已通过，继续完成 \`SubmissionKit/02_ASC_Live_Checklist.md\` 中的 ASC 在线状态、build、IAP、截图预览核对"
  echo "2. 完成 \`FINAL_SUBMISSION_CHECKLIST.md\` 中剩余人工项，尤其是 ASC 在线预览与买断解锁项挂载核对"
  echo "3. 若 App Store Connect API / 页面仍无法实时读取，保持当前结论为 \`需补充验证后再提交\`"
  echo "4. 所有自动与人工门禁均为 PASS 前，不更新为“可提交”"
fi)
EOF

echo "Generated release gate report at $REPORT_FILE"

if [[ "$release_gate_status" != "PASS" ]]; then
  exit 1
fi
