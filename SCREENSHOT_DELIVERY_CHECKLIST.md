# TAMEGeomancy 截图交付清单

更新时间：2026-05-08

## 目标

为 App Store 版本页准备一套可执行的截图生产与核对清单，减少导出后才发现尺寸、文案或 locale 混乱的问题。

## 文件夹建议

```text
AppStoreAssets/
  zh-Hans/
    01-dual-compass.png
    02-naqi-analysis.png
    03-flying-star.png
    04-floor-plan-heatmap.png
    05-bazhai.png
    06-record-share.png
  en-US/
    01-dual-compass.png
    02-naqi-analysis.png
    03-flying-star.png
    04-floor-plan-heatmap.png
    05-bazhai.png
    06-record-share.png
  review-only/
    permission-flow.png
    floor-plan-import.png
```

## 推荐主图顺序

### zh-Hans

1. 双盘罗盘
2. 纳气分析
3. 飞星排盘
4. 户型热力图
5. 八宅匹配
6. 记录与分享

### en-US

1. Dual Compass
2. Naqi Reference
3. Flying Star Charts
4. Floor Plan Overlay
5. Bazhai Matching
6. Save and Share

## 每张图必须核对

- 标题语言与 locale 一致
- 顶部字标使用 `TAME·Geomancy / 探觅·堪舆`
- 不出现 `改运`、`旺财`、`精准预测`
- 不展示应用里没有的按钮或流程
- PNG 无 alpha
- 导出尺寸符合 App Store 要求

## 审核专用图

以下内容建议单独放入 `review-only/`，不要混进公开截图：

- 权限触发路径
- 相机导入户型流程
- 记录详情分享图
- 品牌说明图

## 上传前最终检查

1. 中文标题是否全中文
2. 英文标题是否全英文
3. 各 locale 文件夹是否独立
4. 是否误放了 review-only 素材
5. 是否遗漏了 `TAME·Geomancy / 探觅·堪舆` 品牌一致性说明
6. 是否与 [APPSTORE_SCREENSHOT_COPY.md](APPSTORE_SCREENSHOT_COPY.md) 保持一致
7. 是否已运行 `./scripts/validate_appstore_screenshots.sh`

## 当前素材状态

- `zh-Hans`：6/6 已落盘，均为 `1206x2622`、`alpha=no`
- `en-US`：6/6 已落盘，均为 `1206x2622`、`alpha=no`
  - `02-naqi-analysis.png`、`04-floor-plan-heatmap.png`、`05-bazhai.png`、`06-record-share.png` 已用 `scripts/generate_missing_en_screenshots.swift` 生成 / 修正，避免英文目录继续混入缺图、中文界面或系统主屏素材
- `review-only`：当前未放公开截图文件名，仍无正式审核辅助素材

当前上传前截图校验已通过：`./scripts/validate_appstore_screenshots.sh`。后续仍需在 App Store Connect 上传后核对预览与实际文件一致。
