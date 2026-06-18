# TAMEGeomancy 项目状态报告

更新时间：2026-05-06

## 当前状态

- 本地构建状态：`最近两轮 xcodebuild 复核均失败；generic iOS 与 iphoneos + /private/tmp 派生目录路径都受 CoreSimulatorService / ibtoold / actool 环境异常影响`
- 当前阶段：核心功能完成，进入资料补齐与提审准备阶段
- 品牌归类：`TAME·Geomancy / 探觅·堪舆`
- 应用内字标：使用正式锁定组 `TAME·Geomancy / 探觅·堪舆`
- 全局 VI：统一采用 `暖白底 + 深墨黑 + 香槟金` 的极简精密风格
- App Store 元数据与商店页面规则：副标题、关键词、宣传文案、截图标题、审核备注与外部公开页统一服从最新项目总规则
- 当前提审结论：`需补充验证后再提交`

## 已完成模块

- 双盘罗盘
- 坐向与纳气分析
- 三元九运总览
- 玄空飞星排盘
- 流年运势
- 户型图分析
- 八宅风水
- 形煞知识参考
- 历史记录与备注
- 报告卡分享
- 设置与免责声明

## 本地已交付资料

- [TODO.md](TODO.md)
- [ALGORITHM_SPEC.md](ALGORITHM_SPEC.md)
- [APPSTORE_METADATA.md](APPSTORE_METADATA.md)
- [APPSTORE_SCREENSHOT_COPY.md](APPSTORE_SCREENSHOT_COPY.md)
- [APP_REVIEW_NOTES.md](APP_REVIEW_NOTES.md)
- [APPSTORE_REVIEW_AUDIT.md](APPSTORE_REVIEW_AUDIT.md)
- [REVIEW_AVOIDANCE_GUIDE.md](REVIEW_AVOIDANCE_GUIDE.md)

## 仍待核实的提审前事项

- App Store Connect 当前版本状态
- Support URL
- Privacy Policy URL
- Terms of Use URL
- 最终截图文件导出与上传前校验
- fresh install 级别 smoke test

以上事项的统一核销入口见 [FINAL_EXECUTION_BOARD.md](FINAL_EXECUTION_BOARD.md)。

## 当前判断

从本地代码和资料完整度看，项目已具备继续整理提审材料的基础，但还不能直接下结论为“可提交”。当前还需要同时清掉模拟器 / 构建环境异常和外部提审 blocker。更稳妥的结论见 [APPSTORE_REVIEW_AUDIT.md](APPSTORE_REVIEW_AUDIT.md)。
