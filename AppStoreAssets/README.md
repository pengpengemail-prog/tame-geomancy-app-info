# TAME Space Compass AppStoreAssets

更新时间：2026-05-06

## 目录用途

本目录用于集中存放最终导出的 App Store 截图与审核专用素材，避免与项目源码、文档混放。

## 建议结构

```text
AppStoreAssets/
  zh-Hans/
  en-US/
  review-only/
```

## 使用规则

- `zh-Hans/`：仅放中文公开截图
- `en-US/`：仅放英文公开截图
- `review-only/`：仅放审核说明或权限路径素材，不上传到版本页
- 公开截图标题、字标、文案与外部商店页面统一服从最新项目总规则

## 导出后必须核对

- 文件名顺序是否正确
- PNG 是否无 alpha
- locale 是否混放
- 标题是否与 `APPSTORE_SCREENSHOT_COPY.md` 一致
- 视觉是否保持 `暖白底 + 深墨黑 + 哑光香槟金` 的统一品牌基线

## 推荐操作顺序

1. 将实际截图放入 `zh-Hans/`、`en-US/`、`review-only/`
2. 运行 `./scripts/validate_appstore_screenshots.sh`
3. 运行 `./scripts/generate_screenshot_manifest.sh`
4. 打开 `AppStoreAssets/MANIFEST.md` 作为上传前核销清单
