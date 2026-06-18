# 探觅·空间罗盘 / TAME Space Compass 审核备注与规避说明

更新时间：2026-05-25 08:11 +0800

## 当前提交用审核备注（API 同步版）

Hello App Review Team,

Thank you for the Guideline 4.3(b) feedback. We have updated this submission before resubmitting: the app metadata and localized screenshots now use a practical spatial-reference framing, and the one-time unlock product is attached for review.

TAME Space Compass / 探觅·空间罗盘 is an offline spatial-reference utility. It is not a personal prediction, fortune, star-sign, medical, financial, wealth, destiny, or guaranteed-outcome app.

Core workflow:
- Compass: dual-ring compass for orientation reference.
- Analysis: opening direction, period and nine-grid layout, floor-plan overlay, and room-position notes.
- Records: local saved reports and shareable report cards.
- Settings > Premium Access: purchase flow and Restore Purchases.

Premium unlocks report sharing and save-to-Photos only:
- One-time purchase: US$12.99
- China storefront: CNY 88 one-time purchase

Permissions:
- Location is optional and used only for true-north correction.
- Motion/orientation is used only for compass direction sensing.
- Camera/Photos are used only for floor-plan import and local share image export.

All user data stays on device. No login is required.

Terms of Use: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/

Thank you.

## 推荐审核备注

### 中文版

您好，感谢审核本应用。

`探觅·空间罗盘` 是一款离线运行的空间参考工具，用于查看罗盘坐向、开口参考、九宫布局、户型分析与空间方向建议。应用不提供个人结果预测、改变结果承诺、医疗建议、金融建议或财富承诺，也不包含用户生成内容或社交互动。当前版本包含一次性解锁，用于解锁报告分享与保存到相册能力。

关于名称与品牌说明：

- 桌面显示名使用 `探觅·空间罗盘`
- 应用内正式字标使用 `TAME Space Compass / 探觅·空间罗盘`
- 二者指向同一产品，并非不同 App 或不同品牌

审核体验路径建议：

1. 打开 App 后进入“罗盘”页，可查看双盘罗盘
2. 切换到“分析”页，可进入坐向参考、周期布局、九宫布局、户型图分析与空间建议
3. 进入“记录”页，可查看已保存的本地分析记录与报告分享卡
4. 进入“设置”页，可查看使用说明与免责声明
5. 如需验证解锁，可进入“设置 > 高级解锁”或“记录详情 > 报告导出”

权限说明：

- 定位：仅用于真北校正
- 运动与方向：仅用于罗盘测向
- 相机/相册：仅用于导入户型图和保存分享图
- 解锁：用于解锁报告分享与保存到相册能力，恢复购买入口位于“设置 > 高级解锁”

本应用所有数据均本地处理，不需要登录账号，也不会上传用户内容。

使用条款（EULA）：https://www.apple.com/legal/internet-services/itunes/dev/stdeula/

### English Version

Hello App Review Team,

Thank you for reviewing this app.

TAME Space Compass is an offline spatial-reference tool for orientation review, opening reference, period layouts, floor plan analysis, and spatial direction suggestions. The app does not offer personal-outcome predictions, medical advice, financial advice, or guaranteed outcomes. This version includes a one-time unlock for report sharing and save-to-Photos features, and does not include social features or user-generated content.

Current pricing baseline:
- One-time purchase: US$12.99
- China storefront: CNY ¥88 one-time purchase

Brand clarification:

- The SpringBoard label uses `探觅·空间罗盘`
- The in-app lockup shows `TAME Space Compass / 探觅·空间罗盘`
- Both refer to the same product and not different apps

Suggested review path:

1. Open the Compass tab to view the dual-ring compass
2. Open the Analysis tab for orientation, period layout, floor plan, and spatial suggestion pages
3. Open the Records tab to view saved local reports and shareable report cards
4. Open the Settings tab for usage notes and disclaimer
5. Open Settings > Premium Access or any record detail > Report Export area to review the purchase flow

Permissions:

- Location: only for optional true-north correction
- Motion/orientation: only for compass direction sensing
- Camera/Photos: only for floor plan import and local share image export
- Purchase: unlocks report sharing and save-to-Photos, with Restore Purchases visible inside Settings > Premium Access

All user data stays on device and no login is required.

Terms of Use (EULA): https://www.apple.com/legal/internet-services/itunes/dev/stdeula/

## 针对 4.3(b) 的英文回复模板

Hello App Review Team,

Thank you for the review and feedback.

We have resubmitted the app together with its one-time unlock product for review.

We would also like to clarify the product scope for Guideline 4.3(b):

TAME Space Compass is not positioned as a personal prediction or star-sign entertainment app. Its core workflow is a practical spatial-reference tool centered on:

- compass-based orientation measurement
- opening reference
- period layout reference
- floor plan overlay and analysis
- spatial direction reference

The app is designed for traditional-culture enthusiasts, interior layout reference, and floor-plan study workflows. It does not promise life outcomes, wealth outcomes, medical outcomes, or guaranteed predictions.

To review the main product flow:

1. Open the Compass tab for dual-ring compass orientation.
2. Open the Analysis tab for orientation, period layout, floor-plan, and spatial-reference pages.
3. Open the Records tab for saved local reports and report-sharing output.
4. Open Settings > Premium Access to verify the purchase flow and Restore Purchases entry.

All app data is processed locally on device. No login is required.

Thank you for your time and consideration.

## 审核规避要点

- 所有对外文案统一用“空间参考”或“民俗文化参考”
- 避免出现：
- `个人结果预测`
  - `改运`
  - `消灾`
  - `治病`
  - `保证旺财`
  - `精准预测命运`
- 截图、描述、审核备注都不要把功能包装成科学结论
- 若桌面显示名与应用内锁定组存在中英排版差异，审核备注必须按真实前台效果说明

## 提审前必须人工确认

- `Support URL`
- `Privacy Policy URL`
- `Terms of Use URL`
- 截图文件夹是否已分 locale，并在 ASC 上传后核对在线预览
- App Store Connect 中当前版本是否仍可编辑
- 一次性高级解锁项目是否真正挂到待提交版本中
