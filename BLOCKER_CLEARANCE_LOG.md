# TAMEGeomancy Blocker Clearance Log

> Deprecated monetization note: this log preserves historical monthly/yearly submission evidence. Future TAMEGeomancy submissions must use the lifetime non-consumable IAP `com.tame.geomancy.premium.lifetime`.

更新时间：2026-06-05 01:12 +0800

统一执行入口见 [FINAL_EXECUTION_BOARD.md](FINAL_EXECUTION_BOARD.md)。

## 当前 blocker 列表

| Blocker | 当前状态 | 核销方式 | 备注 |
| --- | --- | --- | --- |
| Release gate 总控 | 已核销 / 已提交等待审核 | `readiness_check.sh`、截图校验、MCP/ASC API 回读与 reviewSubmission 提交成功 | 2026-06-05 版本状态为 `WAITING_FOR_REVIEW` |
| 本机构建 / 模拟器环境异常 | 已核销 | `xcodebuild` Debug / Release 与 Simulator diagnostics 均已通过 | 2026-05-23 已恢复，本项不再作为当前 blocker |
| Fresh install / smoke test 未完成 | 历史核销 / 当前 ASC 已提交 | iPhone 17 Pro Max iOS 26.5 fresh install 后成功启动首页 | 当前会话未重新上机；ASC 已进入审核队列 |
| App Store Connect 当前版本状态未核对 | 已核销 | ASC API 与 MCP 回读版本状态、build 绑定情况 | build `6`，版本 `WAITING_FOR_REVIEW` |
| Support / Privacy / Terms 链接未最终上线 | 已核销 | 公开 URL 与 ASC 字段核对 | Support/Privacy/Marketing URL 已写入；EULA 使用 Apple 标准 EULA |
| 最终截图 ASC 上传预览未核对 | 已核销 | ASC API 回读 zh-Hans/en-US 截图状态 | mature-commerce-r3 每个 locale 6 张，均 `COMPLETE` |

## 清零原则

每完成一个 blocker，都应补充：

- 完成时间
- 执行人
- 核销证据
- 是否仍存在残余风险

## 清零记录

### 2026-06-05 mature-commerce-r3 截图上传并重新进入审核队列

- 时间：2026-06-05 01:12 +0800
- 执行人：Codex
- 已完成核销：
  - 将 `mature-commerce-r3` 中英文截图替换到正式上传目录。
  - 上传 zh-Hans / en-US 两套 App Store 截图到 ASC，两个 locale 各 6 张，全部回读 `COMPLETE`。
  - 通过 ASC API 回读版本 `1.0` 绑定 build `6`，`processingState=VALID`，`usesNonExemptEncryption=false`。
  - 通过 ASC API 回读 IAP `com.tame.geomancy.premium.lifetime`，状态为 `WAITING_FOR_REVIEW`。
  - 通过 App Store Connect MCP 与本地 ASC API 双通道确认版本状态为 `WAITING_FOR_REVIEW`。
- 最终状态：
  - App Store version `1.0`：`WAITING_FOR_REVIEW`
  - reviewSubmission：`905bf4ff-d287-404f-8326-2407735d0ea8`
  - Apple submittedDate：`2026-06-04T17:10:19.061Z`
- 证据：
  - `.build-cache/asc-live-audit/resubmit-905-current-after-r3-20260605.json`
  - `.build-cache/asc-live-audit/final-r3-waiting-review-readback-20260605.json`
  - `marketing/appstore/screenshots/zh-Hans/iphone-6.9/`
  - `marketing/appstore/screenshots/en-US/iphone-6.9/`

### 2026-05-25 撤回后先回复再重新提交

- 时间：2026-05-25 08:32 +0800
- 执行人：Codex
- 用户纠正：App Review / Resolution Center 回复应在提交审核前完成；本轮已按该顺序执行。
- 已完成核销：
  - ASC API 回读版本 `1.0` 为 `DEVELOPER_REJECTED`，build `4` 已绑定且 `processingState=VALID`。
  - 将针对 Guideline 4.3(b) 的正式英文回复写入 `APP_REVIEW_NOTES.md` 与 `marketing/appstore/review-notes.md` 的当前提交审核备注。
  - 通过 ASC API PATCH `appStoreReviewDetails/b1ca0f05-ac5a-4218-be2b-d6d6e1f68224`。
  - 再次通过 ASC API 读回确认 Review Notes 包含 `Guideline 4.3(b)`、`spatial-reference`、`US$1.99`、`US$12.99`、`Settings > Premium Access` 与 `No login is required`。
  - 创建并提交新的 reviewSubmission：`defb3a95-bc82-4752-87ce-78dff5684a2d`。
- 最终状态：
  - App Store version `1.0`：`WAITING_FOR_REVIEW`
  - reviewSubmission：`WAITING_FOR_REVIEW`
  - Apple submittedDate：`2026-05-25T00:32:31.094Z`
- 证据：
  - `.build-cache/asc-live-audit/live-status-after-user-cancel.json`
  - `.build-cache/asc-live-audit/sync-review-notes-before-resubmit.json`
  - `.build-cache/asc-live-audit/review-notes-readback-before-resubmit.json`
  - `.build-cache/asc-live-audit/resubmit-direct-after-review-notes.json`

### 2026-05-25 罗盘 ASC API 提交成功

- 时间：2026-05-25 08:03 +0800
- 执行人：Codex
- 已完成核销：
  - 使用本地 ASC API 脚本与个人 key 模式 `sub=user` 读取 App Store Connect；MCP 当前仍因 issuer 模式返回 401，不作为本轮提交通道。
  - 将旧 submission item PATCH 为 `removed=true`，ASC 回读旧 item 进入 `REMOVED`。
  - 在 reviewSubmission `528c5e5d-c298-40cc-8a11-d921b294d238` 中重新创建版本提交项。
  - PATCH `reviewSubmissions/{id}` 设置 `submitted=true` 成功。
  - ASC API 回读版本 `1.0` 状态：`WAITING_FOR_REVIEW`。
  - ASC API 回读 build：build `4`，`processingState=VALID`，`usesNonExemptEncryption=false`。
  - ASC API 回读 zh-Hans/en-US App Store 元数据：副标题、关键词、宣传文本已是优化后版本。
  - ASC API 回读中英截图：各 6 张均 `COMPLETE`。
  - 历史 recurring-plan 回读证据已归档，不再作为未来提交目标。
  - 价格计划改为只核对 lifetime non-consumable IAP。
- 当前证据：
  - `.build-cache/asc-live-audit/submit-after-remove-attempt.json`
  - `.build-cache/asc-live-audit/sync-optimized-metadata.json`
  - `.build-cache/asc-live-audit/archived-recurring-price-readback.json`
  - `.build-cache/asc-live-audit/readiness-summary.json`
- 当前结论：
  - 罗盘版本已经提交，当前状态为 `WAITING_FOR_REVIEW`。
  - 不再需要人工点击 App Store Connect 来完成本轮提交。
  - 后续只需等待审核结果；若被拒，再按 `appstore-review-audit-guard` 读取实时拒审点做定向修复。

### 2026-05-25 官方留言回复准备

- 时间：2026-05-25 08:11 +0800
- 执行人：Codex
- 已完成核销：
  - 按 `appstore-rejection-response` 技能整理 Guideline 4.3(b) 回复。
  - 用 ASC API 探测当前 reviewSubmission 与可能的消息资源。
  - 确认当前 reviewSubmission `528c5e5d-c298-40cc-8a11-d921b294d238` 仍为 `WAITING_FOR_REVIEW`。
  - 探测 `messages`、`reviewSubmissionMessages`、`appReviewMessages`、`resolutionCenterMessages` 等公开路径均返回 404，公共 ASC API 未暴露 Resolution Center 直接回复资源。
  - 已生成官方回复稿：`marketing/appstore/app-review-reply-4.3b-2026-05-25.md`。
- 当前结论：
  - 版本提交与 Review Notes 已通过 API 完成。
  - Resolution Center 单独对话回复无法通过当前公开 ASC API 自动发送；若 Apple 要求单独消息，只能在 App Store Connect 官方消息界面发送同一份回复稿，或后续接入可用的私有/专用消息 API。

### 2026-05-25 App Store Connect live 401 复核

- 时间：2026-05-25 00:31 +0800
- 执行人：Codex
- 已完成本地核销：
  - 确认 `/Users/pengpeng/Desktop/ApiKey_L6Y9VYEJFJYS.p8` 文件存在
  - 确认 `~/.codex/config.toml` 中已配置 `ASC_KEY_ID` / `ASC_ISSUER_ID` / `ASC_PRIVATE_KEY_PATH`
  - 直接运行 `TAMEGeomancy/scripts/asc_tame_ops.py` 使用同一组 key/issuer 读取 App Store Connect，结果仍返回 HTTP 401 `NOT_AUTHORIZED`
  - 分别验证带 `iss` / 不带 `iss` 的 JWT，结果一致为 HTTP 401
  - `asc-mcp` 资源层握手失败，未能建立当前会话的 live ASC 读取通道
- 当前判断：
  - 不是简单的参数漏传问题
  - 更像 Apple 侧不接受当前 key/issuer 组合，或该 key 在当前 App Store Connect 侧没有有效 API 权限
  - 继续以 `ASC live 状态、build、lifetime IAP 挂载、在线截图预览未核对` 作为外部 blocker

### 2026-05-23 杨公页视觉与本地门禁复核

- 时间：2026-05-23 01:57 +0800
- 执行人：Codex
- 已完成本地核销：
  - 修复 `YangGongFenjinView.swift` 中二十四向线罗盘中心白色读数块遮挡问题
  - 中心改为小型轴心，坐向 / 角度 / 细分线 / 边界读数移到罗盘右侧与下方摘要卡
  - `swiftc -frontend -parse TAMEGeomancy/**/*.swift TAMEGeomancyTests/**/*.swift` 通过
  - `./.codex/skills/ui-ux-pro-max/scripts/ios-validate .../YangGongFenjinView.swift` 通过
  - Debug 模拟器构建通过，并在 iPhone 17 Pro Max iOS 26.5 前台确认新版页面
  - Release iOS 构建通过：`xcodebuild ... -configuration Release -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO build`
  - `scripts/preflight_audit.sh`：PASS
  - `scripts/readiness_check.sh`：PASS
  - fresh install：`uninstall -> install -> launch` 成功，首页无白屏 / 崩溃 / 卡死
  - 公开链接 `Support / Privacy / Marketing / Apple EULA` 均返回 HTTP 200
- 当前证据：
  - `VerificationShots/yanggong_compass_fixed_20260523_0153.png`
  - `SubmissionKit/PREFLIGHT_REPORT.md`
  - `SubmissionKit/RELEASE_GATE_REPORT.md`
- 当前结论：
  - 本地自动门禁已通过
  - 仍不能直接判定“可提交”，因为 App Store Connect API 当前返回 401，线上版本状态、build 绑定、lifetime IAP 挂载与截图在线预览无法在本会话确认

### 2026-05-08 发布门禁总控

- 时间：2026-05-08 22:26 +0800
- 执行人：Codex
- 已完成本地核销：
  - 新增 `scripts/release_gate.sh`
  - `SubmissionKit/RELEASE_GATE_REPORT.md` 已生成
  - `SubmissionKit/00_Submission_Runbook.md`、`03_Execution_Commands.md`、`README.md`、`FINAL_SUBMISSION_CHECKLIST.md` 已接入 release gate
  - `scripts/readiness_check.sh` 已确认 release gate 脚本存在
- 最新执行结果：
  - `./scripts/readiness_check.sh`：PASS
  - `./scripts/release_gate.sh`：BLOCKED / exit 1
  - 自动门禁：Readiness PASS，Preflight FAIL，Xcode / Simulator diagnostics FAIL
  - 人工 / 外部门禁：ASC 在线核对与最终提交清单仍为 PENDING
- 当前证据：
  - `SubmissionKit/RELEASE_GATE_REPORT.md`
  - `SubmissionKit/PREFLIGHT_REPORT.md`
  - `.build-cache/xcode_simulator_diagnostics.md`
- 当前结论：
  - release gate 已成为后续提审判断统一入口
  - 当前仍不能核销为可提交

### 2026-05-08 只读诊断补强

- 时间：2026-05-08 22:08 +0800
- 执行人：Codex
- 已完成本地核销：
  - 新增 `scripts/diagnose_xcode_simulator.sh`
  - `scripts/readiness_check.sh` 已检查该诊断脚本存在
  - `scripts/preflight_audit.sh` 已自动生成 `.build-cache/xcode_simulator_diagnostics.md`
  - `SubmissionKit/PREFLIGHT_REPORT.md` 已追加 build 错误行摘录与诊断摘要
  - `SubmissionKit/03_Execution_Commands.md` 与 `SubmissionKit/README.md` 已补诊断命令
- 最新执行结果：
  - `./scripts/readiness_check.sh`：PASS
  - `./scripts/preflight_audit.sh`：FAIL，失败项为 `Xcode build` 与 `Xcode / Simulator diagnostics`
  - `xcrun simctl list runtimes`、`xcrun simctl list devices available`、`xcrun simctl list devicetypes`、`xcrun simctl list pairs`：均 FAIL
- 当前证据：
  - `.build-cache/xcode_simulator_diagnostics.md`
  - `.build-cache/preflight_build.log`
  - `SubmissionKit/PREFLIGHT_REPORT.md`
- 当前结论：
  - 截图、StoreKit、WebLegal、公开文案与 Swift parse 已通过 readiness
  - 最新 build 失败关键错误仍是：`No available simulator runtimes for platform iphonesimulator. SimServiceContext supportedRuntimes=[]`
  - 当前不能核销本机构建 / smoke blocker，也不能宣称可提交

## 本轮核销

- 时间：2026-05-04
- 执行人：Codex
- 已完成本地核销：
  - 重跑 `xcodegen -s project.yml -p . -r .`
  - 重跑 `xcodebuild build`
  - 重跑 `./scripts/readiness_check.sh`
  - 重跑 `./scripts/preflight_audit.sh`
  - 校验 `CFBundleDisplayName = 探觅·堪舆`
  - 清理 reviewer 可见公开文案中的内部工程名 `TAMEGeomancy`
- 本轮结论：
  - 本地开发与提审资料框架继续可用
  - 当前仍是 `需补充验证后再提交`
  - 本地预检剩余真实失败源为：
    - 占位法务链接信息未替换
    - 最终截图素材未导出
- 未完成人工 blocker：
  - Fresh install / smoke test
  - App Store Connect 当前版本状态核对
  - 真实法务链接上线并回填
  - 最终截图导出、校验与上传

- 时间：2026-05-05
- 执行人：Codex
- 已完成本地核销：
  - app target 部署版本已从 `iOS 26.0` 修正回 `iOS 15.0`
  - `AnalysisHub` / `Records` / `onChange` 兼容层已补齐，可继续按 `iOS 15+` 交付
  - 白底品牌主线已继续覆盖罗盘、八宅、三元九运页面
  - 新增 `FEATURE_DELIVERY_MATRIX.md`，用于后续逐项对照完整版开发文档
  - 总览页已补 6 条专题直测入口，降低后续逐页 smoke 的人工跳转成本
  - 补总览页 4 条 app 内实测主线入口
  - 补分析中心“打开示例户型”推荐演示入口
  - 补历史记录空态“生成示例分享记录”入口
  - 重跑 `xcodebuild -project TAMEGeomancy.xcodeproj -scheme TAMEGeomancy -destination 'generic/platform=iOS' -derivedDataPath /private/tmp/TAMEGeomancyGenericBuild CODE_SIGNING_ALLOWED=NO build`
  - 清理 `FlyingStarCalculator.swift` 编译警告
  - 工程显式收口到 `TARGETED_DEVICE_FAMILY = 1`
  - 修复总览页首启误触发罗盘传感器，避免定位弹窗盖住首页
  - 补设置页“权限速览”聚焦面板，支持 app 内主线直达权限状态
  - 补最新 smoke 证据图：
    - `/private/tmp/tame-overview-no-permission.png`
    - `/private/tmp/tame-compass-demo-latest.png`
    - `/private/tmp/tame-settings-permissions-focus.png`
  - 补交互级验证：
    - 备注保存后再次进入详情，已确认内容持久化
    - “分享报告”已确认可调起系统分享面板
    - “示例户型分析”已确认可从总览页主线进入并显示完整分析结果
    - 交互级证据图：`/private/tmp/tame-floorplan-interactive-latest.png`
  - 补设置回流与权限链路验证：
    - 关闭“显示纳气盘”后，罗盘盘面与数据卡会同步显示“已隐藏”
    - 户型页“相册”已确认可拉起系统照片选取器，选图后回流分析页并自动生成九宫结果
    - 户型页“拍摄”已确认当前模拟器可拉起系统测试相机界面
    - 记录详情“保存到相册”已确认会触发系统授权弹窗，允许后保存成功
    - 设置页权限速览已确认会把“相册 / 保存报告图”更新为“已允许”
    - 本轮证据图：
      - `/private/tmp/tame-compass-settings-sync-off.png`
      - `/private/tmp/tame-compass-settings-sync-off-fixed.png`
      - `/private/tmp/tame-floorplan-camera-entry.png`
      - `/private/tmp/tame-floorplan-photo-import-success.png`
      - `/private/tmp/tame-record-save-to-photos-success.png`
      - `/private/tmp/tame-settings-photo-save-allowed.png`
- 本轮结论：
  - 即使外部启动路由或模拟器服务抖动，app 内也已有稳定可达的演示主线
  - 当前仍是 `需补充验证后再提交`
  - 当前剩余本地阻塞已收敛到专题页逐页点测与外部提审条件，而非首页/罗盘/设置/相册保存主线缺失
- 本轮追加核销：
  - 已通过主设备 LCD 截图确认新版白底专题页真实前台运行：
    - `/private/tmp/tame-orientation-demo-20260505-v3.png`
    - `/private/tmp/tame-flying-star-demo-20260505-v2.png`
    - `/private/tmp/tame-annual-demo-20260505.png`
    - `/private/tmp/tame-bazhai-smoke-20260505-v3.png`
  - 已发现并修复白底可读性问题：
    - 问题：暗色外观与白底品牌界面并存，导致标题和系统控件出现浅字低对比
    - 修复：统一外观策略回到浅色品牌界面
    - 复核：`/private/tmp/tame-orientation-demo-20260505-v3.png`
  - 已补齐 `AppStoreAssets/zh-Hans/` 公开截图 6 张，并通过本地尺寸 / alpha 校验
  - 当时截图校验剩余失败已收敛为：
    - `AppStoreAssets/en-US/` 6 张英文公开截图缺失；后续已补齐并通过本地 validator
- 未完成 blocker：
  - Fresh install / smoke test 的剩余交互级点测：坐向纳气实时计算、三元九运切年、飞星/流年/八宅逐页验证、本地备份导出恢复
  - App Store Connect 当前版本状态核对
  - 真实法务链接上线并回填
  - 最终截图导出、校验与上传

- 时间：2026-05-06
- 执行人：Codex
- 已完成本地核销：
  - 设置页已补“设置工作台”和“快捷核对”
  - 户型分析页已补“分析工作台”
  - 流年、八宅、飞星、坐向纳气已补顶部工作台概览
  - 分享导出品牌与分类文案已统一为 `TAME·Geomancy / 探觅·堪舆`
  - 继续统一品牌残留口径，补齐 `SHOT_LIST`、`APPSTORE_METADATA`、`SCREENSHOT_DELIVERY_CHECKLIST`、`ALGORITHM_SPEC`、`SubmissionKit/02_ASC_Live_Checklist.md`
  - `WebLegal/support.html`、`privacy-policy.html`、`terms-of-use.html` 已统一为 `TAME·Geomancy / 探觅·堪舆` 正式品牌口径
  - `SUPPORT.md`、`PRIVACY_POLICY.md`、`TERMS_OF_USE.md` 已替换掉 `yourdomain.com` / `support@yourdomain.com` 占位内容
  - 已重建 `WebLegal/dist/`
  - 设置页已补“界面语言”入口，并接入 `tameLocaleOverride`
  - 已重跑 `xcodebuild -project TAMEGeomancy.xcodeproj -scheme TAMEGeomancy -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO -derivedDataPath /private/tmp/TAMEGeomancyDerivedData build`
- 本轮结论：
  - 本地法务/支持页占位域名与邮箱已不再是预检失败项
  - 最新主线页面继续成品化，但不能据此替代构建与上机核销
  - 最新 `xcodebuild` 真实失败源为：
    - `CoreSimulatorService connection became invalid`
    - `Unable to discover any Simulator runtimes`
    - `CompileAssetCatalogVariant` 被 `ibtoold` / `actool` 环境链路牵连
  - 因此当前不能再沿用“BUILD SUCCEEDED”的旧口径
- 未完成人工 / 外部 blocker：
  - 本机构建 / 模拟器环境恢复
  - Fresh install / smoke test
  - App Store Connect 当前版本状态核对
  - 真实法务链接上线并回填
  - 最终英文截图导出、校验与上传

### Blocker 0

- 阻塞项：本机构建 / 模拟器环境异常
- 执行基线：
  - `xcodebuild -project TAMEGeomancy.xcodeproj -scheme TAMEGeomancy -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath /private/tmp/TAMEGeomancyDerivedData build`
- 完成时间：2026-05-07
- 执行人：Codex
- 核销证据：
  - 已定位并修复 `TAMEGeomancy.xcodeproj/project.pbxproj` 中旧 premium view 文件被错误写入 `PBXSourcesBuildPhase` 的工程损坏问题
  - 已通过：
    - `swiftc -typecheck`
    - `xcodebuild ... -derivedDataPath /private/tmp/TAMEGeomancyDerivedData build`
  - 最新构建结果：`** BUILD SUCCEEDED **`
- 残余风险：
  - `CoreSimulatorService` 仍输出连接异常噪音日志，说明本机模拟器环境并不干净
  - 但当前已经不能再把“工程损坏 / 无法构建”作为 blocker 保留

### Blocker 1

- 阻塞项：Fresh install / smoke test 未完成
- 执行基线：`SMOKE_TEST_RUNBOOK.md`
- 完成时间：2026-05-05 01:26
- 执行人：Codex
- 核销证据：
  - 已串行执行 `uninstall -> install -> launch`
  - 已确认 `xcrun simctl get_app_container booted com.tame.geomancy app` 成功返回 app container
  - 已确认 `xcrun simctl launch booted com.tame.geomancy` 成功返回 pid
  - 已生成应用内首页截图：`/private/tmp/tame-app-home.png`
- 残余风险：
  - 当前只完成了 fresh install 与首页级 smoke，分析页、记录详情、设置页等仍待完整交互点测
  - 已新增页面级 smoke 证据：
    - 设置页：`/private/tmp/tame-settings-launch-route.png`
    - 示例户型分析页：`/private/tmp/tame-analysis-floor-plan-argv.png`
    - 示例分享记录详情页：`/private/tmp/tame-records-share-preview-fixed.png`
  - 已补启动测试路由辅助能力，用于绕开 iOS 深链接确认弹窗并稳定抓取页面级证据
  - 已补 app 内稳定演示入口，可从总览页直接进入罗盘演示、示例户型、分享预览与权限支持
  - 当前仍未核销的交互点集中在实时罗盘传感器、相册/相机权限、记录编辑与系统分享调起
  - 2026-05-05 本地 `CoreSimulatorService` 持续异常，但已通过 app 内主线与最小修复补到关键运行态证据：
    - `/private/tmp/tame-overview-no-permission.png`
    - `/private/tmp/tame-compass-demo-latest.png`
    - `/private/tmp/tame-settings-permissions-focus.png`
  - 本轮已补完：
    - 备注编辑保存
    - 系统分享弹窗
    - 相册导入真实回流路径
    - 保存到相册真实授权路径
    - 罗盘“显示纳气盘”设置回流
  - 当前仍待补的是坐向纳气实时计算、三元九运切年、飞星/流年/八宅逐页结果检查、本地备份导出恢复

### Blocker 2

- 阻塞项：App Store Connect 当前版本状态未核对
- 执行基线：`SubmissionKit/02_ASC_Live_Checklist.md`
- 建议补充记录：
  - 当前版本号：
  - 当前 build 号：
  - 当前页面状态：
- 完成时间：
- 执行人：
- 核销证据：
- 残余风险：

### Blocker 3

- 阻塞项：Support / Privacy / Terms 链接未最终上线
- 执行基线：
  - `./scripts/configure_weblegal.sh --site-root <公开根路径> --support-email <支持邮箱>`
  - `./scripts/configure_weblegal.sh --site-root <公开根路径> --support-email <支持邮箱> --apply`
  - `WebLegal/DEPLOYMENT_GUIDE.md`
- 上线后 URL：
  - Support URL：`https://pengpengemail-prog.github.io/tame-geomancy-app-info/support.html`
  - Privacy Policy URL：`https://pengpengemail-prog.github.io/tame-geomancy-app-info/privacy-policy.html`
  - Terms of Use URL：`https://pengpengemail-prog.github.io/tame-geomancy-app-info/terms-of-use.html`
- 完成时间：
- 执行人：
- 核销证据：
- 残余风险：

### Blocker 4

- 阻塞项：最终截图 ASC 上传预览未核对
- 执行基线：
  - `SCREENSHOT_DELIVERY_CHECKLIST.md`
  - `./scripts/validate_appstore_screenshots.sh`
- 建议补充记录：
  - zh-Hans 素材路径：`AppStoreAssets/zh-Hans/`
  - en-US 素材路径：`AppStoreAssets/en-US/`
  - review-only 素材路径：
- 完成时间：
- 执行人：
- 核销证据：
- 残余风险：
  - 2026-05-08 最新校验结果：
    - `zh-Hans` 6/6 通过，均为 `1206x2622`、`alpha=no`
    - `en-US` 6/6 通过，均为 `1206x2622`、`alpha=no`
    - `AppStoreAssets/MANIFEST.md` 已重生成
  - 本地上传前校验已核销；当前剩余风险只保留 ASC 上传后的在线预览、截图顺序、locale 归属与是否误传临时素材

### 2026-05-08 追加记录

- 执行人：Codex
- 已完成：
  - `records/share-preview` 已修成确定性参考报告入口：触发时生成一条报告预览记录并打开详情页
  - `HistoryStore.save` 返回保存后的记录，支持保存后立即导航
  - 新增参考报告记录测试，覆盖内容非空与导出说明
  - 当时截图校验真实缺口缩小为：
    - `AppStoreAssets/en-US/04-floor-plan-heatmap.png`
    - `AppStoreAssets/en-US/06-record-share.png`
- 验证：
  - `swiftc -frontend -parse TAMEGeomancy/ViewModels/HistoryStore.swift TAMEGeomancy/Views/RecordsView.swift TAMEGeomancyTests/TAMEGeomancyTests.swift` 通过
  - 当时 `./scripts/validate_appstore_screenshots.sh` 仍 FAIL，失败数 2，均为上述英文截图缺失；后续已在下一条截图补齐记录中核销为 PASS
- 未核销：
  - `xcodebuild -project TAMEGeomancy.xcodeproj -scheme TAMEGeomancy -destination 'generic/platform=iOS Simulator' -derivedDataPath .DerivedData build` 仍在 `CompileAssetCatalogVariant` 失败，日志显示 `No available simulator runtimes for platform iphonesimulator`
  - `xcodebuild -project TAMEGeomancy.xcodeproj -scheme TAMEGeomancy -destination 'generic/platform=iOS' -derivedDataPath .DerivedDataDevice CODE_SIGNING_ALLOWED=NO build` 同样在 `CompileAssetCatalogVariant` 失败，日志仍指向 `CoreSimulatorService / ibtoold / actool`
  - 沙盒外构建复核申请被审批通道拒绝，未执行绕过

### 2026-05-08 截图补齐追加记录

- 执行人：Codex
- 已完成：
  - 新增 `scripts/generate_missing_en_screenshots.swift`
  - 生成 / 修正 `AppStoreAssets/en-US/02-naqi-analysis.png`
  - 生成 / 修正 `AppStoreAssets/en-US/04-floor-plan-heatmap.png`
  - 生成 / 修正 `AppStoreAssets/en-US/05-bazhai.png`
  - 生成 / 修正 `AppStoreAssets/en-US/06-record-share.png`
  - 修正 `en-US/05-bazhai.png` 误用系统主屏图的问题
  - 修正 `en-US/02-naqi-analysis.png` 混入中文界面标题的问题
- 验证：
  - 已视觉抽检 `en-US/02`、`04`、`05`、`06`
  - `./scripts/validate_appstore_screenshots.sh` 通过
  - `./scripts/generate_screenshot_manifest.sh` 已重生成 `AppStoreAssets/MANIFEST.md`
  - `./scripts/preflight_audit.sh` 已重生成 `SubmissionKit/PREFLIGHT_REPORT.md`
- 残余风险：
  - preflight 总状态仍为 `FAIL`，原因是 `Xcode build` 仍失败
  - App Store Connect 上传后的在线预览、版本状态、build 绑定和外部链接仍需人工核对

### 2026-05-08 构建与设备族追加复核

- 执行人：Codex
- 已完成：
  - `project.yml` 已显式关闭 Mac / XR 兼容运行目标：
    - `SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD: NO`
    - `SUPPORTS_XR_DESIGNED_FOR_IPHONE_IPAD: NO`
  - 已重跑 `xcodegen -s project.yml -p . -r .`，`TAMEGeomancy.xcodeproj/project.pbxproj` 已同步生成上述设置
  - `xcrun simctl list runtimes` 当前可列出 iOS 26.0 / 26.1 / 26.2 / 26.4 runtimes
  - `xcrun simctl list devices available` 当前可列出多组 iPhone / iPad 模拟器
  - `xcodebuild -showBuildSettings` 可输出 build settings，但启动阶段仍报：
    - `CoreSimulatorService connection became invalid`
    - `simdiskimaged crashed or is not responding`
    - 写入 `~/Library/Logs/CoreSimulator` 与部分 Xcode DerivedData 日志路径 `Operation not permitted`
- 验证：
  - `./scripts/validate_appstore_screenshots.sh` 通过
  - `./scripts/preflight_audit.sh` 已重生成 `SubmissionKit/PREFLIGHT_REPORT.md`
- 最新结论：
  - `simctl` 只读查询已经短暂恢复，不再是完全不可列出 runtime
  - 但 `xcodebuild` 的 `CompileAssetCatalogVariant` 仍失败，错误仍为 `No available simulator runtimes for platform iphonesimulator. SimServiceContext supportedRuntimes=[]`
  - 关闭 Mac / XR 兼容目标后，`xcodebuild -destination 'generic/platform=iOS' -derivedDataPath /private/tmp/tamegeomancy-device-derived CODE_SIGNING_ALLOWED=NO build` 仍未通过；`iphoneos` 构建同样在 `CompileAssetCatalogVariant` 阶段被 `ibtoold` 触发的 `CoreSimulatorService / simdiskimaged` 断联阻断
  - 当前仍不能宣称本机构建通过；更接近 Xcode / Simulator 服务在当前沙盒权限与系统状态下不稳定，而不是截图素材或 Swift 源码新增错误

### 2026-05-08 付费解锁审核口径追加记录

- 执行人：Codex
- 已完成：
  - `PremiumAccessStore`、首页高级解锁入口、`TAMEGeomancy.storekit`、App Store 文案与 IAP 配置清单已移除“后续高级能力 / future advanced analysis”类未来功能承诺
  - 当前一次性解锁权益统一为：
    - 报告分享
    - 保存到相册
    - 恢复购买入口
  - `SMOKE_TEST_RUNBOOK.md`、`APPSTORE_REVIEW_AUDIT.md`、`APP_REVIEW_NOTES.md`、`SubmissionKit` 与 `WebLegal` 入口文档已同步到 2026-05-08 的真实阻塞状态
- 验证：
  - `swiftc -frontend -parse TAMEGeomancy/ViewModels/PremiumAccessStore.swift TAMEGeomancy/Views/OverviewDashboardView.swift` 通过
  - `TAMEGeomancy.storekit` JSON parse 通过
  - `./scripts/readiness_check.sh` 通过
- 残余风险：
  - ASC 中真实 lifetime IAP 挂载、价格与本地化仍需登录后核对

### 2026-05-08 Readiness 规则加固追加记录

- 执行人：Codex
- 已完成：
  - `scripts/readiness_check.sh` 已新增设备族与运行目标检查：
    - `TARGETED_DEVICE_FAMILY: "1"`
    - `SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD: NO`
    - `SUPPORTS_XR_DESIGNED_FOR_IPHONE_IPAD: NO`
    - `STOREKIT_CONFIG_PATH: TAMEGeomancy.storekit`
  - 已新增 StoreKit 检查：
    - JSON 可解析
    - lifetime IAP product id 存在
    - `$0.99` / `$6.99` 价格基准存在
    - 不再配置 recurring trial
  - 已新增 premium unlock 文案回退检查：禁止 `后续高级`、`future advanced`、`later advanced` 等未来权益承诺进入 app / StoreKit / App Store 资料
- 验证：
  - `./scripts/readiness_check.sh` 通过
- 残余风险：
  - 这些检查只能保证本地配置一致；ASC 真实 lifetime IAP 挂载和价格仍需在线核对

### 2026-05-08 Preflight 诊断增强追加记录

- 执行人：Codex
- 已完成：
  - `scripts/preflight_audit.sh` 已新增自动诊断输出：
    - Xcode build 日志尾段：`.build-cache/preflight_build.log`
    - Simulator runtime 只读查询：`.build-cache/preflight_simctl_runtimes.log`
    - Simulator device 只读查询：`.build-cache/preflight_simctl_devices.log`
  - `SubmissionKit/PREFLIGHT_REPORT.md` 已新增 `Xcode Build 摘录` 与 `Simulator 只读诊断` 段落
- 验证：
  - `./scripts/preflight_audit.sh` 已执行并重生成报告
  - 最新报告时间：`2026-05-08 21:41:18 +0800`
- 最新结论：
  - 当前 `Readiness check` 仍为 PASS
  - `Xcode build` 仍为 FAIL
  - 最新只读 `simctl list runtimes` 与 `simctl list devices available` 均无法初始化 device set，报 `CoreSimulatorService connection became invalid`、`simdiskimaged crashed or is not responding`、`Operation not permitted`
  - 当前 blocker 已进一步坐实为本机 Xcode / Simulator 服务链路，不是本地截图、StoreKit、WebLegal 或 App Store 资料配置失败

### 2026-05-08 Swift Parse 与工作区噪音追加记录

- 执行人：Codex
- 已完成：
  - `.gitignore` 已从 `.DerivedData/` 扩展为 `.DerivedData*/`，覆盖多轮构建诊断产生的派生目录
  - `scripts/readiness_check.sh` 已接入 Swift parse 级体检
- 验证：
  - `swiftc -frontend -parse TAMEGeomancy/**/*.swift TAMEGeomancyTests/**/*.swift` 通过
  - `git status --short .DerivedData*` 当前不再列出这些派生目录
- 残余风险：
  - parse 级体检只能发现语法/解析层问题，不能替代当前被 Simulator 服务阻塞的完整 `xcodebuild`

### 2026-05-08 新版模拟器包与图标核销

- 时间：2026-05-08 22:54 +0800
- 执行人：Codex
- 已完成：
  - 已确认模拟器此前运行的是旧包，并已卸载旧 bundle
  - Xcode GUI 使用 `iPhone 17 Pro (26.4.1)` 重新 Build / Install / Run 当前工程
  - 新安装包路径已变更为：
    - `/Users/pengpeng/Library/Developer/CoreSimulator/Devices/D943A272-7E86-4A7A-B6CA-6E3E9B8DB6D0/data/Containers/Bundle/Application/F49BF059-8FDB-4D5A-8603-3D641555A213/TAMEGeomancy.app`
  - 已确认不再是旧的 `TAMEGeomancyMerged-20260507.app`
  - 包内 `Info.plist` 已核对：
    - `CFBundleDisplayName = 探觅·堪舆`
    - `CFBundleIdentifier = com.tame.geomancy`
    - `CFBundleShortVersionString = 1.0.0`
    - `CFBundleVersion = 1`
  - 发现旧图标源与候选图均带 `豆包AI生成` 水印，已替换为本地原创无水印图标：
    - `TAMEGeomancy/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png`
    - `Design/app-icon-original-geomancy-1024.png`
  - 新图标规格已核对：`1024x1024`、`hasAlpha: no`、RGB PNG
  - SpringBoard 已显示新版 `探觅·堪舆` 图标，视觉为无水印白金罗盘几何款
  - 最新前台运行截图：
    - `/private/tmp/tamegeomancy-after-icon-run.png`
    - `/private/tmp/tamegeomancy-springboard-icon.png`
- 验证：
  - `./scripts/readiness_check.sh`：PASS
  - `./scripts/release_gate.sh`：仍为 BLOCKED / exit 1
- 当前结论：
  - “模拟器跑旧版 / 旧图标”问题已核销
  - App Store 图标水印风险已修复
  - 仍不能直接提审；剩余阻塞为 CLI preflight 构建链路、ASC 在线核对、正式打包上传与外部链接/截图在线预览

### 2026-05-08 Transporter 上传路径追加记录

- 时间：2026-05-08 23:57 +0800
- 执行人：Codex
- 已确认：
  - 用户明确要求使用 Transporter 上传；本轮不再走 Xcode Organizer 的 Validate / Distribute 上传路径
  - 已导出的 App Store IPA 路径固定为：
    - `/Users/pengpeng/Desktop/codex工作区/TAMEGeomancy/exports/TAMEGeomancy-1.0.0-1-export/TAMEGeomancy.ipa`
  - `DistributionSummary.plist` 已显示 App Store distribution 签名，Team ID 为 `C3SV2L8GV4`
  - Transporter GUI 已登录到 `pengpengemail@gmail.com` / provider `haijian peng|554731487|1`
  - 将 IPA 加入 Transporter 后曾停在“正在制作 ITMSP - 正在查询软件 ID...”，随后返回列表且未出现可交付的 `TAMEGeomancy` 行
  - 这与“App Store Connect 尚未存在 `com.tame.geomancy` app 记录”表现一致；Transporter 不能创建 app 记录，只能交付到已存在的 ASC app
- 本轮受限：
  - ASC API 联网查询被当前沙箱审批通道 503 拒绝，未能实时确认 / 创建 app 记录
  - Transporter GUI 进程仍在，但本轮 Computer Use / 辅助功能读取窗口失败或超时，无法代点“交付”
  - Transporter 自带 `iTMSTransporter` Java CLI 在当前环境启动即 NPE；Xcode ContentDelivery `altool` 可运行，但个人 `ApiKey_*.p8` 缺 issuer，无法直接用于 `altool --upload-package`
- 当前结论：
  - 不是 IPA 重新打包问题
  - 当前上传前第一阻塞为 ASC 中 `com.tame.geomancy` app 记录未核定；记录存在后，重新在 Transporter 添加上述 IPA 并点击“交付”
