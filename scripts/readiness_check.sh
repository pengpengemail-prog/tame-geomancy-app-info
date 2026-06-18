#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

failures=0

check_exists() {
  local path="$1"
  if [[ -e "$path" ]]; then
    echo "[OK] 文件存在: $path"
  else
    echo "[FAIL] 文件缺失: $path"
    failures=$((failures + 1))
  fi
}

check_no_matches() {
  local label="$1"
  shift
  local output
  output="$(rg -n "$@" 2>/dev/null || true)"
  if [[ -n "$output" ]]; then
    echo "[FAIL] 发现不应出现的内容: $label"
    echo "$output"
    failures=$((failures + 1))
  else
    echo "[OK] 未发现不应出现的内容: $label"
  fi
}

check_required_match() {
  local label="$1"
  local pattern="$2"
  shift 2
  if rg -n "$pattern" "$@" >/dev/null 2>&1; then
    echo "[OK] $label"
  else
    echo "[FAIL] 缺少预期内容: $label"
    failures=$((failures + 1))
  fi
}

check_plist_value() {
  local label="$1"
  local file="$2"
  local key="$3"
  local expected="$4"
  local value
  value="$(/usr/bin/plutil -extract "$key" raw -o - "$file" 2>/dev/null || true)"
  if [[ "$value" == "$expected" ]]; then
    echo "[OK] $label"
  else
    echo "[FAIL] $label，当前值: ${value:-<empty>}"
    failures=$((failures + 1))
  fi
}

check_directory_has_real_assets() {
  local dir="$1"
  local label="$2"
  local count
  count="$(find "$dir" -maxdepth 1 -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' \) | wc -l | tr -d ' ')"
  if [[ "$count" -gt 0 ]]; then
    echo "[OK] $label 已有素材文件: $count"
  else
    echo "[WARN] $label 目录尚无实际截图素材: $dir"
  fi
}

echo "== TAMEGeomancy Readiness Check =="

check_exists "FINAL_EXECUTION_BOARD.md"
check_exists "BLOCKER_CLEARANCE_LOG.md"
check_exists "SMOKE_TEST_RUNBOOK.md"
check_exists "SubmissionKit/00_Submission_Runbook.md"
check_exists "SubmissionKit/01_Copy_Paste_Fields.md"
check_exists "SubmissionKit/02_ASC_Live_Checklist.md"
check_exists "SubmissionKit/03_Execution_Commands.md"
check_exists "scripts/configure_weblegal.sh"
check_exists "scripts/build_weblegal_dist.sh"
check_exists "scripts/validate_appstore_screenshots.sh"
check_exists "scripts/generate_screenshot_manifest.sh"
check_exists "scripts/preflight_audit.sh"
check_exists "scripts/diagnose_xcode_simulator.sh"
check_exists "scripts/release_gate.sh"
check_exists "WebLegal/support.html"
check_exists "WebLegal/privacy-policy.html"
check_exists "WebLegal/terms-of-use.html"
check_exists "TAMEGeomancy.storekit"

if zsh "scripts/build_weblegal_dist.sh" >/dev/null 2>&1; then
  echo "[OK] WebLegal dist 已同步构建"
else
  echo "[FAIL] WebLegal dist 构建失败"
  failures=$((failures + 1))
fi

check_exists "WebLegal/dist/index.html"
check_exists "WebLegal/dist/support.html"
check_exists "WebLegal/dist/privacy-policy.html"
check_exists "WebLegal/dist/terms-of-use.html"

check_plist_value \
  "Info.plist 显示名为 探觅·空间罗盘" \
  "TAMEGeomancy/Resources/Info.plist" \
  "CFBundleDisplayName" \
  "探觅·空间罗盘"

check_required_match \
  "project.yml 显示名配置为 探觅·空间罗盘" \
  "CFBundleDisplayName: 探觅·空间罗盘" \
  "project.yml"

check_required_match \
  "project.yml 已收口为 iPhone 设备族" \
  'TARGETED_DEVICE_FAMILY: "1"' \
  "project.yml"

check_required_match \
  "project.yml 已关闭 Mac Designed for iPhone/iPad" \
  "SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD: NO" \
  "project.yml"

check_required_match \
  "project.yml 已关闭 XR Designed for iPhone/iPad" \
  "SUPPORTS_XR_DESIGNED_FOR_IPHONE_IPAD: NO" \
  "project.yml"

check_required_match \
  "project.yml 已绑定 StoreKit 配置" \
  "STOREKIT_CONFIG_PATH: TAMEGeomancy.storekit" \
  "project.yml"

check_required_match \
  "Xcode 工程已同步关闭 Mac Designed for iPhone/iPad" \
  "SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD = NO" \
  "TAMEGeomancy.xcodeproj/project.pbxproj"

check_required_match \
  "Xcode 工程已同步关闭 XR Designed for iPhone/iPad" \
  "SUPPORTS_XR_DESIGNED_FOR_IPHONE_IPAD = NO" \
  "TAMEGeomancy.xcodeproj/project.pbxproj"

check_required_match \
  "审核备注包含中文对外名称" \
  "探觅·空间罗盘" \
  "APP_REVIEW_NOTES.md"

check_required_match \
  "审核备注包含英文对外名称" \
  "TAME Space Compass" \
  "APP_REVIEW_NOTES.md"

check_no_matches \
  "公开法务、支持与审核备注仍暴露内部工程名" \
  "TAMEGeomancy" \
  "WebLegal/support.html" "WebLegal/privacy-policy.html" "WebLegal/terms-of-use.html" \
  "WebLegal/dist/index.html" "WebLegal/dist/support.html" "WebLegal/dist/privacy-policy.html" "WebLegal/dist/terms-of-use.html" \
  "SUPPORT.md" "PRIVACY_POLICY.md" "TERMS_OF_USE.md" "APP_REVIEW_NOTES.md"

check_no_matches \
  "公开法务与支持页占位域名/邮箱" \
  "support@yourdomain\\.com|https://yourdomain\\.com|yourdomain\\.com" \
  "WebLegal/support.html" "WebLegal/privacy-policy.html" "WebLegal/terms-of-use.html" \
  "WebLegal/dist/support.html" "WebLegal/dist/privacy-policy.html" "WebLegal/dist/terms-of-use.html" \
  "SUPPORT.md" "PRIVACY_POLICY.md" "TERMS_OF_USE.md"

check_no_matches \
  "公开法务与支持文档仍处于上线前占位状态" \
  "Before launch, replace placeholder|正式上线前建议补充|正式上线前配置的支持邮箱或支持页面|建议在正式上线前补充真实支持邮箱与支持页面地址" \
  "WebLegal/support.html" "WebLegal/privacy-policy.html" "WebLegal/terms-of-use.html" \
  "WebLegal/dist/support.html" "WebLegal/dist/privacy-policy.html" "WebLegal/dist/terms-of-use.html" \
  "SUPPORT.md" "PRIVACY_POLICY.md" "TERMS_OF_USE.md"

check_no_matches \
  "应用内 reviewer 可见页面仍含上线前占位文案" \
  "正式上线前|support@yourdomain|yourdomain.com|Before launch|placeholder|补充真实支持邮箱" \
  "TAMEGeomancy/Views/SettingsView.swift" "TAMEGeomancy/Views/PolicyCenterView.swift"

if /usr/bin/ruby -rjson -e 'JSON.parse(File.read("TAMEGeomancy.storekit"))' >/dev/null 2>&1; then
  echo "[OK] StoreKit 配置 JSON 有效"
else
  echo "[FAIL] StoreKit 配置 JSON 无效"
  failures=$((failures + 1))
fi

check_required_match \
  "StoreKit 终身解锁 Product ID 已配置" \
  "com.tame.geomancy.premium.lifetime" \
  "TAMEGeomancy.storekit"

check_required_match \
  "StoreKit 终身解锁价格基准已配置" \
  '\$12\.99' \
  "TAMEGeomancy.storekit"

check_required_match \
  "StoreKit 终身解锁类型为非消耗型" \
  '"type" : "NonConsumable"' \
  "TAMEGeomancy.storekit"

check_no_matches \
  "StoreKit 不应再包含周期扣费项目" \
  "com\\.tame\\.geomancy\\.premium\\.(monthly|yearly)|RecurringSubscription|subscriptionPeriod|freeTrial|PremiumSubscription" \
  "TAMEGeomancy.storekit"

check_no_matches \
  "解锁与商店文案仍承诺未来高级能力" \
  "后续高级|future advanced|future.*advanced|later advanced" \
  "TAMEGeomancy.storekit" \
  "TAMEGeomancy/ViewModels/PremiumAccessStore.swift" \
  "TAMEGeomancy/Views/OverviewDashboardView.swift" \
  "APPSTORE_METADATA.md" \
  "APP_REVIEW_NOTES.md" \
  "APPSTORE_REVIEW_AUDIT.md" \
  "SubmissionKit/03_ASC_IAP_Setup.md"

if rg -n "最终执行总表与核销主入口" "README.md" >/dev/null 2>&1; then
  echo "[OK] README 已引用主执行总表"
else
  echo "[FAIL] README 未引用主执行总表"
  failures=$((failures + 1))
fi

check_directory_has_real_assets "AppStoreAssets/zh-Hans" "zh-Hans 截图目录"
check_directory_has_real_assets "AppStoreAssets/en-US" "en-US 截图目录"
check_directory_has_real_assets "AppStoreAssets/review-only" "review-only 素材目录"

if zsh "scripts/validate_appstore_screenshots.sh"; then
  echo "[OK] 截图校验通过"
else
  echo "[FAIL] 截图校验未通过"
  failures=$((failures + 1))
fi

if zsh "scripts/generate_screenshot_manifest.sh" >/dev/null 2>&1; then
  echo "[OK] 截图 manifest 已生成"
else
  echo "[FAIL] 截图 manifest 生成失败"
  failures=$((failures + 1))
fi

if swiftc -frontend -parse TAMEGeomancy/**/*.swift TAMEGeomancyTests/**/*.swift >/dev/null 2>&1; then
  echo "[OK] Swift 源码 parse 级体检通过"
else
  echo "[FAIL] Swift 源码 parse 级体检未通过"
  failures=$((failures + 1))
fi

echo
if [[ "$failures" -gt 0 ]]; then
  echo "Readiness Check: FAIL ($failures)"
  exit 1
else
  echo "Readiness Check: PASS"
fi
