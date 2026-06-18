# TAMEGeomancy SubmissionKit

更新时间：2026-05-08

## 目录说明

该目录用于集中整理提审阶段会实际用到的执行材料，避免在仓库内到处翻找。

## 当前内容

- [00_Submission_Runbook.md](00_Submission_Runbook.md)
- [01_Copy_Paste_Fields.md](01_Copy_Paste_Fields.md)
- [02_ASC_Live_Checklist.md](02_ASC_Live_Checklist.md)
- [03_Execution_Commands.md](03_Execution_Commands.md)
- [PREFLIGHT_REPORT.md](PREFLIGHT_REPORT.md)
- [RELEASE_GATE_REPORT.md](RELEASE_GATE_REPORT.md)
- [submission_dashboard.html](submission_dashboard.html)

## 配合主文档使用

- [APPSTORE_METADATA.md](../APPSTORE_METADATA.md)
- [APP_REVIEW_NOTES.md](../APP_REVIEW_NOTES.md)
- [FINAL_SUBMISSION_CHECKLIST.md](../FINAL_SUBMISSION_CHECKLIST.md)
- [SCREENSHOT_DELIVERY_CHECKLIST.md](../SCREENSHOT_DELIVERY_CHECKLIST.md)

## 当前定位

本地材料已基本齐备，但在真正提交前仍需补完：

- 本机构建 / Simulator 服务链路恢复并通过最新 `xcodebuild`
- 基于最新 build 的 fresh install 级别 smoke test
- App Store Connect 在线状态核对
- 真实 Support / Privacy / Terms 链接
- App Store Connect 截图上传后的在线预览核对
- 一次性高级解锁挂载、价格与本地化核对

## 本地自检

提审前可先运行：

```bash
./scripts/release_gate.sh
./scripts/preflight_audit.sh
./scripts/readiness_check.sh
./scripts/diagnose_xcode_simulator.sh
./scripts/validate_appstore_screenshots.sh
./scripts/generate_screenshot_manifest.sh
```

该脚本会检查：

- 核销主文档是否齐全
- `WebLegal` 与支持文档中是否仍有占位域名/邮箱
- 自动门禁、环境门禁与人工门禁是否仍阻塞提交
- Xcode / Simulator 只读诊断是否能发现可用 runtime 与设备集
- 截图目录、文件名、PNG 格式、alpha 与尺寸一致性
- 截图 manifest 是否可正常生成

当前 `AppStoreAssets/zh-Hans/` 与 `AppStoreAssets/en-US/` 已通过本地上传前校验；如替换截图，需重新运行截图校验、manifest 与预检。
