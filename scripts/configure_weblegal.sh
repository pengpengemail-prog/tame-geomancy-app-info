#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

SITE_ROOT=""
SUPPORT_EMAIL=""
URL_STYLE="html"
APPLY_MODE="dry-run"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/configure_weblegal.sh --site-root https://example.com/tame-geomancy --support-email support@example.com [--url-style html|pretty] [--apply]

Examples:
  ./scripts/configure_weblegal.sh --site-root https://example.com/tame-geomancy --support-email support@example.com
  ./scripts/configure_weblegal.sh --site-root https://example.com/tame-geomancy --support-email support@example.com --url-style pretty --apply
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --site-root)
      SITE_ROOT="${2:-}"
      shift 2
      ;;
    --support-email)
      SUPPORT_EMAIL="${2:-}"
      shift 2
      ;;
    --url-style)
      URL_STYLE="${2:-}"
      shift 2
      ;;
    --apply)
      APPLY_MODE="apply"
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "$SITE_ROOT" || -z "$SUPPORT_EMAIL" ]]; then
  echo "Both --site-root and --support-email are required." >&2
  usage >&2
  exit 1
fi

SITE_ROOT="${SITE_ROOT%/}"

case "$URL_STYLE" in
  html)
    SUPPORT_URL="${SITE_ROOT}/support.html"
    PRIVACY_URL="${SITE_ROOT}/privacy-policy.html"
    TERMS_URL="${SITE_ROOT}/terms-of-use.html"
    ;;
  pretty)
    SUPPORT_URL="${SITE_ROOT}/support"
    PRIVACY_URL="${SITE_ROOT}/privacy-policy"
    TERMS_URL="${SITE_ROOT}/terms-of-use"
    ;;
  *)
    echo "Unsupported --url-style: $URL_STYLE" >&2
    exit 1
    ;;
esac

FILES=(
  "WebLegal/support.html"
  "WebLegal/privacy-policy.html"
  "WebLegal/terms-of-use.html"
  "SUPPORT.md"
  "PRIVACY_POLICY.md"
  "TERMS_OF_USE.md"
  "SubmissionKit/01_Copy_Paste_Fields.md"
)

terms_links_block=$'- 隐私政策链接：`'"$PRIVACY_URL"$'`\n- 使用条款链接：`'"$TERMS_URL"$'`'
copy_fields_before=$'## 仍需人工补充\n\n- Support URL\n- Privacy Policy URL\n- Terms of Use URL\n- 最终截图上传状态\n- 当前 build 选择情况'
copy_fields_after=$'## 已生成链接\n\n- Support URL: `'"$SUPPORT_URL"$'`\n- Privacy Policy URL: `'"$PRIVACY_URL"$'`\n- Terms of Use URL: `'"$TERMS_URL"$'`\n\n## 仍需人工补充\n\n- 最终截图上传状态\n- 当前 build 选择情况'

replace_literal() {
  local file="$1"
  local before="$2"
  local after="$3"

  if [[ "$APPLY_MODE" == "apply" ]]; then
    BEFORE="$before" AFTER="$after" perl -0pi -e 's/\Q$ENV{BEFORE}\E/$ENV{AFTER}/g' "$file"
  fi
}

echo "== TAME Space Compass WebLegal Config =="
echo "Mode: $APPLY_MODE"
echo "Site root: $SITE_ROOT"
echo "Support email: $SUPPORT_EMAIL"
echo "Support URL: $SUPPORT_URL"
echo "Privacy URL: $PRIVACY_URL"
echo "Terms URL: $TERMS_URL"
echo
echo "Target files:"
printf ' - %s\n' "${FILES[@]}"
echo

if [[ "$APPLY_MODE" != "apply" ]]; then
  echo "Dry run only. Re-run with --apply to write changes."
  exit 0
fi

replace_literal "WebLegal/support.html" "以下为待替换的支持信息占位示例，公开部署时请改为真实内容。" "如需协助，可通过以下方式联系支持："
replace_literal "WebLegal/support.html" "support@yourdomain.com" "$SUPPORT_EMAIL"
replace_literal "WebLegal/support.html" "https://yourdomain.com" "$SITE_ROOT"

replace_literal "WebLegal/privacy-policy.html" "Current template uses placeholder contact details. Replace them with your real public support contact before publishing." "Support contact: $SUPPORT_EMAIL. Public support page: $SUPPORT_URL."
replace_literal "WebLegal/terms-of-use.html" "Current template uses placeholder support details. Replace them with your real public contact address and support page before publishing." "Support contact: $SUPPORT_EMAIL. Public support page: $SUPPORT_URL."

replace_literal "SUPPORT.md" "如果你在使用 \`探觅·空间罗盘\`（TAME Space Compass）时遇到问题，可通过以下占位支持信息示例准备后续公开联系渠道。" "如果你在使用 \`探觅·空间罗盘\`（TAME Space Compass）时遇到问题，可通过以下方式联系支持。"
replace_literal "SUPPORT.md" "- 支持邮箱：\`support@yourdomain.com\`" "- 支持邮箱：\`$SUPPORT_EMAIL\`"
replace_literal "SUPPORT.md" "- 官方页面：\`https://yourdomain.com/tame-geomancy/support\`" "- 官方页面：\`$SUPPORT_URL\`"

replace_literal "PRIVACY_POLICY.md" "当前文档仍使用占位联系方式，公开部署时请替换为真实支持信息：" "如需联系支持，请使用以下信息："
replace_literal "PRIVACY_POLICY.md" "- 支持邮箱：\`support@yourdomain.com\`" "- 支持邮箱：\`$SUPPORT_EMAIL\`"
replace_literal "PRIVACY_POLICY.md" "- 支持页面：\`https://yourdomain.com/tame-geomancy/support\`" "- 支持页面：\`$SUPPORT_URL\`"

replace_literal "TERMS_OF_USE.md" "当前文档仍使用占位联系方式，公开部署时请替换为真实支持信息：" "联系方式如下："
replace_literal "TERMS_OF_USE.md" "- 支持邮箱" "- 支持邮箱：\`$SUPPORT_EMAIL\`"
replace_literal "TERMS_OF_USE.md" "- 官方支持页" "- 官方支持页：\`$SUPPORT_URL\`"
replace_literal "TERMS_OF_USE.md" "- 隐私政策链接" "$terms_links_block"

replace_literal "SubmissionKit/01_Copy_Paste_Fields.md" "$copy_fields_before" "$copy_fields_after"

echo "Applied WebLegal and legal-doc replacements."
