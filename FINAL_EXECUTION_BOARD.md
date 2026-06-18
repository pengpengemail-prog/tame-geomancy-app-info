# TAMEGeomancy 最终执行总表

更新时间：2026-05-10

## 当前结论

- 本地代码与提审资料已基本齐备
- 当前状态仍为：`需补充验证后再提交`
- 当前阻塞已收敛为：`本机构建 / 模拟器环境异常` + `4 个外部核销 blocker`
- 当前统一门禁入口为：`./scripts/release_gate.sh`，最新 `SubmissionKit/RELEASE_GATE_REPORT.md` 为 `BLOCKED`
- 当前不能再把“本地构建已通过”作为有效结论；2026-05-08 最新 `xcodebuild` 被 `CoreSimulatorService / ibtoold / actool` 环境链路阻塞，`simctl` 只读诊断同样无法发现 runtime / device set

## 提审门槛

只有以下 5 项全部核销，才可以把结论从 `需补充验证后再提交` 往上更新：

1. `./scripts/release_gate.sh` 通过，`SubmissionKit/RELEASE_GATE_REPORT.md` 显示 `PASS`
2. fresh install / smoke test 完成并留痕
3. App Store Connect 当前版本状态完成核对
4. `Support URL`、`Privacy Policy URL`、`Terms of Use URL` 已真实上线并填入
5. 最终截图已上传到 App Store Connect，在线预览核对无误
6. 本机构建 / Simulator 服务链路恢复后，最新 `xcodebuild` 重新通过

## 当前已完成

- [x] 双盘罗盘、坐向纳气、三元九运、飞星、流年、户型分析、八宅、知识参考均已接入
- [x] 历史记录、备注编辑、报告卡分享已接入
- [x] 设置页已接入本地备份导出、备份恢复与清空前确认
- [x] 设置页已接入隐私政策、使用条款、支持说明
- [x] 记录详情已接入报告图直存系统相册
- [x] 历史记录页已接入搜索、分类筛选与清空前确认
- [x] 已接入 `tamegeomancy://tab/<name>` 深链接，用于直达底部 tab 与辅助 smoke
- [x] 八宅风水、形煞参考已接入保存记录闭环
- [x] 户型图分析页已接入“示例户型”模式，可一键生成可演示分析结果
- [x] 已接入 `tamegeomancy://analysis/floor-plan-demo` 深链接，用于直达示例户型分析结果页
- [x] 已接入 `tamegeomancy://analysis/orientation-demo`、`flying-star-demo`、`annual-demo` 深链接，用于直达专题演示场景
- [x] 已接入 `tamegeomancy://records/share-preview` 深链接，用于自动生成示例分享记录并打开详情页
- [x] 总览页已补 4 条 app 内主线入口：快速测向、参考户型、参考报告、权限与帮助
- [x] 总览页已补 6 条专题直测入口：坐向纳气、三元九运、飞星排盘、流年运势、八宅风水、本地备份
- [x] 坐向纳气、飞星排盘、流年运势、八宅风水已补首屏一键演示场景，专题页不再依赖手动调参才能出完整样例
- [x] 分析中心已补“打开参考户型”推荐入口
- [x] 历史记录空态已支持直接生成示例分享记录并打开详情
- [x] 设置页已升级为更完整的设置与支持页，补齐语言、罗盘模式、权限状态、本地记录与快捷核对入口
- [x] 户型图分析页已升级为分析概览结构，补齐导入状态、立极点、标记数量、纳气依据与快捷导入入口
- [x] 流年运势、八宅风水、飞星排盘、坐向纳气已补顶部概览区，专题页首屏结构已基本统一
- [x] 分享导出文案已统一为 `TAME·Geomancy / 探觅·堪舆`，并修复中文分享文本使用 `record.category.rawValue` 的前台残留问题
- [x] 本地提审资料已补齐：
  - `APPSTORE_METADATA.md`
  - `APP_REVIEW_NOTES.md`
  - `APPSTORE_SCREENSHOT_COPY.md`
  - `APPSTORE_REVIEW_AUDIT.md`
  - `FINAL_SUBMISSION_CHECKLIST.md`
  - `SubmissionKit/`
  - `WebLegal/`
  - `AppStoreAssets/`
- [x] app target 部署版本已回归 `iOS 15.0`，重新与开发文档一致
- [x] 已重新运行 `xcodegen -s project.yml -p . -r .`
- [x] `CFBundleDisplayName`、`project.yml`、审核备注已统一校验为 `探觅·堪舆` / `TAME·Geomancy`
- [x] reviewer 可见公开法务页与审核备注已清除内部工程名 `TAMEGeomancy`
- [x] `scripts/readiness_check.sh` 与 `scripts/preflight_audit.sh` 已补强命名一致性、`WebLegal/dist` 与截图目录检查
- [x] 已补 `scripts/diagnose_xcode_simulator.sh`，可生成 `.build-cache/xcode_simulator_diagnostics.md` 作为只读环境诊断证据
- [x] 已补 `scripts/release_gate.sh`，集中输出自动门禁、环境门禁与人工门禁状态
- [x] 最新预检报告已生成：`SubmissionKit/PREFLIGHT_REPORT.md`
- [x] 最新发布门禁报告已生成：`SubmissionKit/RELEASE_GATE_REPORT.md`
- [x] 最新 readiness 已通过：截图、StoreKit、WebLegal、公开文案、Swift parse 均为 PASS
- [x] 公开法务与支持页占位域名 / 邮箱已完成本地替换，最新 readiness 不再因该项失败
- [x] 设置页已补“界面语言”切换入口，可将 `tameLocaleOverride` 持久化为 app 内语言偏好
- [x] 历史记录备份逻辑已补测试：round-trip、去重导入、坏文件校验
- [x] 最新本地 smoke 已确认：fresh install 后可正常进入应用总览首页
- [x] smoke 辅助导航能力已补齐，并已追加页面级证据：
  - 设置页：`/private/tmp/tame-settings-launch-route.png`
  - 示例户型分析页：`/private/tmp/tame-analysis-floor-plan-argv.png`
  - 示例分享记录详情页：`/private/tmp/tame-records-share-preview-fixed.png`
- [x] 已补启动测试路由能力，可通过 `-TAMELaunchRoute` 在模拟器无弹窗直达 smoke 页面
- [x] 工程已显式收口到 iPhone 设备族，减少方向校验噪音
- [x] 已修复总览页首启误触发罗盘传感器的问题，定位弹窗不再遮挡首页
- [x] 设置页已补“权限速览”聚焦面板，可直接展示定位、方向、相机、相册状态
- [x] 最新关键运行态证据已补：
  - 首页：`/private/tmp/tame-overview-no-permission.png`
  - 罗盘演示：`/private/tmp/tame-compass-demo-latest.png`
  - 权限速览：`/private/tmp/tame-settings-permissions-focus.png`
- [x] 最新交互级验证已补：
  - “分享报告预览”已验证自动生成记录并进入详情页
  - 备注保存已验证持久化
  - “分享报告”已验证可调起系统分享面板
  - “示例户型分析”已验证可从总览页进入并显示纳气口、热力图与房间标记
  - 交互级证据图：`/private/tmp/tame-floorplan-interactive-latest.png`
  - “显示纳气盘”关闭后已验证盘面和数据卡同步回流为“已隐藏”
  - 户型页“相册”已验证可拉起系统照片选取器，选图后回流分析页并自动出九宫结果
  - 记录详情“保存到相册”已验证会触发系统授权弹窗，允许后提示“报告图已保存到系统相册”
  - 本轮新增证据图：
    - `/private/tmp/tame-compass-settings-sync-off.png`
    - `/private/tmp/tame-compass-settings-sync-off-fixed.png`
    - `/private/tmp/tame-floorplan-camera-entry.png`
    - `/private/tmp/tame-floorplan-photo-import-success.png`
    - `/private/tmp/tame-record-save-to-photos-success.png`
    - `/private/tmp/tame-settings-photo-save-allowed.png`
- [x] 已补 `FEATURE_DELIVERY_MATRIX.md`，用于对照完整版开发文档核销真实交付范围

## 当前未核销 Blocker

| Blocker | 状态 | 核销标准 | 证据位置 |
| --- | --- | --- | --- |
| Release gate 总控 | 阻塞中 | `./scripts/release_gate.sh` 返回 PASS | `SubmissionKit/RELEASE_GATE_REPORT.md` |
| 本机构建 / 模拟器环境异常 | 阻塞中 | `CoreSimulatorService`、`ibtoold`、`actool` 恢复正常后重跑本地构建与上机链路 | `.build-cache/xcode_simulator_diagnostics.md` + `SubmissionKit/PREFLIGHT_REPORT.md` |
| Fresh install / smoke test | 待核销 | 完整走一遍首次安装主路径并记录结果 | `SMOKE_TEST_RUNBOOK.md` |
| App Store Connect 当前版本状态 | 待核销 | 核对当前版本可编辑状态、build 绑定、链接填写状态 | `BLOCKER_CLEARANCE_LOG.md` |
| 法务与支持链接最终上线 | 待核销 | 将 `WebLegal/` 替换为真实域名与邮箱并公开可访问 | `WebLegal/` + `BLOCKER_CLEARANCE_LOG.md` |
| 最终截图导出与校验 | 本地已核销 / ASC 上传待核对 | 中英文截图分目录放置并完成上传前检查；ASC 上传后仍需核对预览 | `AppStoreAssets/` + `SCREENSHOT_DELIVERY_CHECKLIST.md` |

## 本地核销顺序

1. 运行 `./scripts/release_gate.sh`
2. 若 release gate 为 `BLOCKED`，先看 `SubmissionKit/RELEASE_GATE_REPORT.md`
3. 运行 `xcodegen -s project.yml -p . -r .`
4. 运行 `./scripts/diagnose_xcode_simulator.sh`，确认 runtime / device set 可被只读查询
5. 先恢复 `CoreSimulatorService` / `ibtoold` / `actool` 环境，再运行 `xcodebuild ... build`
6. 运行 `./scripts/readiness_check.sh`
7. 按 `SMOKE_TEST_RUNBOOK.md` 做 fresh install 测试
8. 复核最终截图仍位于 `AppStoreAssets/zh-Hans/`、`AppStoreAssets/en-US/`
9. 如替换截图，重新运行 `./scripts/validate_appstore_screenshots.sh`
10. 如替换截图，重新运行 `./scripts/generate_screenshot_manifest.sh`
11. 先用 `./scripts/configure_weblegal.sh --site-root <公开根路径> --support-email <支持邮箱>` 预览替换结果
12. 确认无误后加 `--apply`，再运行 `./scripts/build_weblegal_dist.sh`
13. 将 `WebLegal/dist/` 部署并拿到真实 URL
14. 按 `SubmissionKit/00_Submission_Runbook.md` 填写 App Store Connect
15. 在 `BLOCKER_CLEARANCE_LOG.md` 中逐项登记核销证据

## App Store Connect 必查项

- App 名称是否为：
  - `探觅·堪舆`
  - `TAME·Geomancy`
- 副标题、宣传文本、描述、关键词是否为当前审核安全版本
- 当前版本是否仍可编辑
- 当前版本是否已绑定本次 build
- `Support URL` 是否可访问
- `Privacy Policy URL` 是否可访问
- `Terms of Use URL` 是否可访问
- `zh-Hans` 与 `en-US` 截图是否分别上传
- `review-only` 素材是否未误传到版本页

## 文案与品牌一致性

- 桌面显示名遵守：`探觅·堪舆`
- 应用内品牌字标使用：`TAME·Geomancy / 探觅·堪舆`
- 审核备注中必须解释两者指向同一产品，不是不同 App
- 所有文案继续保持“民俗文化参考”表达

## 不能直接宣称可提交的原因

- 当前缺少 fresh install 级别交互核验
- 当前无法从本地直接确认 App Store Connect 的实时页面状态
- 当前外部法务链接已回填 GitHub Pages 正式 URL，线上可访问性仍待最终打开复核
- 当前最终截图已完成本地落盘、manifest 与上传前校验；仍未完成 ASC 上传后的在线预览核对

## 本轮核销

- [x] `xcodegen` 已重跑并同步工程
- [x] `iOS 15+` 部署目标已重新核销通过
- [x] 命名一致性本地校验已通过
- [x] 首页专题直测入口已完成代码核销
- [x] 公开文案中的内部工程名暴露已清理
- [x] 设置页本地备份导出 / 恢复已完成代码核销
- [x] 报告图保存到相册与记录页增强已完成代码核销
- [x] 深链接 tab 导航已完成代码核销
- [x] 八宅与形煞模块保存记录已完成代码核销
- [x] 户型示例模式已完成代码核销
- [x] 分析页示例深链接已完成代码核销
- [x] 记录页分享预览深链接已完成代码核销
- [x] 总览页 app 内实测主线入口已完成代码核销
- [x] 分析中心推荐演示入口已完成代码核销
- [x] 历史记录空态示例生成入口已完成代码核销
- [x] 专题页演示场景增强已完成代码核销
- [x] 专题页演示深链接已完成代码核销
- [x] 预检失败项已进一步压缩：
  - 法务/支持占位域名与邮箱已不再是失败项
  - 当时 `readiness_check` 仅剩 `en-US` 公开截图校验失败；后续截图校验已核销为 PASS
- [x] 当前 `CoreSimulatorService` 虽仍不稳定，但已绕开多窗口与权限弹窗干扰，补齐罗盘演示模式与权限状态面板的最新运行态截图
- [x] 新增专题演示页前台证据已补：
  - 坐向纳气：`/private/tmp/tame-orientation-demo-20260505-v3.png`
  - 飞星排盘：`/private/tmp/tame-flying-star-demo-20260505-v2.png`
  - 流年运势：`/private/tmp/tame-annual-demo-20260505.png`
  - 八宅风水：`/private/tmp/tame-bazhai-smoke-20260505-v3.png`
- [x] 白底低对比问题已完成本地修复与前台复核：
  - 原因：暗色外观与白底品牌界面并存，导致导航与系统控件出现浅字低对比
  - 结果：当前统一保持浅色品牌界面，坐向纳气页前台截图已确认恢复正常可读性
- [x] 近两轮页面成品化已继续落地：
  - 设置页已补“设置概览”和“快捷核对”
  - 户型页已补“分析概览”
  - 流年、八宅、飞星、坐向纳气已补顶部概览区
  - 分享导出品牌与分类文案已统一到正式口径
- [x] 本轮页面成品化继续落地：
  - `AnalysisHubView` 已补摘要胶囊，分析目录页层级更接近正式商品页
  - `ReferenceKnowledgeView`、`RecordDetailView`、`SupportCenterView` 已补统一白底摘要结构
  - `RecordDetailView` 已把导出动作升级为双卡片入口，弱化开发态按钮感
- [x] 本轮主功能页成品化继续落地：
  - `CompassView` 已补品牌摘要胶囊，罗盘首页状态信息更像正式产品首屏
  - `OrientationAnalysisView` 已补摘要胶囊与说明型保存卡，纳气页首屏层级继续统一
  - `FloorPlanAnalysisView` 已补摘要胶囊与说明型导入卡，户型页首屏导入体验更接近正式商品页
  - `BazhaiView` 已补摘要胶囊与说明型保存卡，八宅页首屏结构继续统一
  - `AnnualFortuneView` 已补摘要胶囊与说明型保存卡，流年页首屏结构继续统一
- [x] 本轮本地化残留继续收口：
  - `CompassDiskView` 已统一八卦与二十四山前台标签口径
  - `JiuyunOverviewView` 已统一五行前台标签口径
  - `BazhaiViewModel`、`AnnualFortuneViewModel` 已继续改用 `localizedLabel`，降低前台中英混用概率
- [x] 本轮前台与记录导出链路继续收口：
  - `BazhaiView` 已统一命卦 / 宅卦 / 坐朝与保存记录文本口径
  - `AnnualFortuneView` 与 `AnnualFortuneViewModel` 已统一太岁 / 岁破 / 年度摘要与记录副标题口径
  - `FloorPlanAnalysisViewModel` 已统一分析依据、建议文案、主要纳气口与记录详情里的方向显示
  - `OrientationAnalysisView`、`CompassView`、`FlyingStarChartView`、`FloorPlanAnalysisView` 已统一专题摘要、保存记录与说明文本中的方向标签
  - 以上主页面与记录导出链路已完成一轮 `.chinese` 残留清扫
- [x] 本轮底层生成文案也已补收口：
  - `NaqiAnalyzer` 已统一 analysis / summary / recommendations 里的方向、五行与等级文本口径
  - 可减少纳气服务层文本回流到前台与记录导出时重新混入旧标签
- [x] 本轮低成本代码体检已补：
  - `NaqiAnalyzer.swift`
  - `BazhaiView.swift`
  - `AnnualFortuneView.swift`
  - `AnnualFortuneViewModel.swift`
  - `FloorPlanAnalysisViewModel.swift`
  - `OrientationAnalysisView.swift`
  - `CompassView.swift`
  - `FlyingStarChartView.swift`
  均已通过 `swiftc -frontend -parse`
- [x] `zh-Hans` 公开截图已完成本地补齐与校验：
  - `01-dual-compass.png`
  - `02-naqi-analysis.png`
  - `03-flying-star.png`
  - `04-floor-plan-heatmap.png`
  - `05-bazhai.png`
  - `06-record-share.png`
- [x] 本轮构建复核路径已补全：
  - 已尝试 `xcodebuild -destination 'generic/platform=iOS' build`
  - 已尝试 `xcodebuild -sdk iphoneos -destination 'generic/platform=iOS' -derivedDataPath /private/tmp/tame-derived CODE_SIGNING_ALLOWED=NO build`
  - 两条路径均未通过，失败点仍集中在 `CoreSimulatorService connection became invalid`
- [x] 截图 blocker 已缩小：
  - 中文公开截图已就绪
  - 当时截图校验失败只剩 `en-US` 公开截图链路：
    - `01-dual-compass.png` 含 alpha
    - `02-naqi-analysis.png`
    - `03-flying-star.png`
    - `04-floor-plan-heatmap.png`
    - `05-bazhai.png`
    - `06-record-share.png`
      当时仍缺失
- [x] 本轮截图 blocker 已进一步写实化：
  - `zh-Hans` 公开目录中的临时检查图已移出，减少无意义校验 warning
  - 当时 `en-US` 公开目录只剩 1 张旧品牌英文图，且不满足无 alpha 要求
  - `simctl` 再次复核仍触发 `CoreSimulatorService connection became invalid`
  - 桌面侧读取 `Simulator` 前台状态也出现超时
- [x] 本轮英文前台口径继续收口：
  - 首页、分析中心、记录页、设置页、政策页已继续去掉偏后台或偏拼音的英文表达
  - `Orientation & Naqi` 已统一收口为更直观的 `Orientation & Openings`
  - `Period Cycles` 已统一收口为 `Period Guide`
  - `Bazhai` / `Bazhai Review` 已继续收口为 `Eight Mansions` / `House Review` 等更用户向表达
- [x] 本轮前台说明语气继续统一：
  - `OrientationAnalysisView`、`FlyingStarChartView`、`BazhaiView`、`AnnualFortuneView` 中的 `desk` 叙述已改回正常页面说明口吻
  - 飞星与纳气页英文说明已继续弱化算法后台感，提升英文截图与前台阅读自然度
- [x] 本轮低成本语法体检已继续通过：
  - `OverviewDashboardView.swift`
  - `AnalysisHubView.swift`
  - `OrientationAnalysisView.swift`
  - `FlyingStarChartView.swift`
  - `BazhaiView.swift`
  - `JiuyunOverviewView.swift`
  - `RecordsView.swift`
  - `AnnualFortuneView.swift`
  - `PolicyCenterView.swift`
  - `SettingsView.swift`
  - `HistoryStore.swift`
  均已通过 `swiftc -frontend -parse`
  - 因此当前不能把“英文公开截图可继续稳定产出”记为已核销
- [x] 本轮模拟器产物状态已补充核销：
  - `TAMEGeomancy/.DerivedData/Build/Products/Debug-iphonesimulator/TAMEGeomancy.app` 仍在
  - 其 `Info.plist` 继续显示：
    - `CFBundleIdentifier = com.tame.geomancy`
    - `CFBundleDisplayName = 探觅·堪舆`
    - `MinimumOSVersion = 15.0`
  - 说明当前并非缺失可安装产物，而是 Simulator 服务与前台控制链路不稳定
- [x] 本轮 Simulator 服务状态已进一步细化：
  - 重启 `CoreSimulatorService` 后，`simctl list devices available` 可短暂恢复
  - 但后续 `simctl listapps booted` 很快再次掉回 `CoreSimulatorService connection invalid`
  - 这意味着当前 Simulator 仅恢复到“可短暂响应”，尚不足以稳定承担英文公开截图与 smoke 主线
- [x] 本轮截图校验结果已再次净化：
  - `zh-Hans` 公开截图 6 张继续全部通过
  - `review-only` 未再混入公开截图文件名
  - 当时公开截图失败项曾收敛为 6 个：
    - `en-US/01-dual-compass.png` 含 alpha，且仍是旧品牌英文素材
    - `en-US/02-naqi-analysis.png`
    - `en-US/03-flying-star.png`
    - `en-US/04-floor-plan-heatmap.png`
  - 以上为当时历史状态，后续已更新为 `01`、`02` 通过，仅剩 `03` 至 `06`
- [x] 本轮截图 blocker 已进一步更新：
  - `en-US/01-dual-compass.png` 已改为有效英文正式图并通过无 alpha 校验
  - `en-US/02-naqi-analysis.png` 已补齐并通过尺寸 / alpha 校验
  - 当时公开截图失败项已收敛为 `en-US` 剩余 4 张缺失：
    - `03-flying-star.png`
    - `04-floor-plan-heatmap.png`
    - `05-bazhai.png`
    - `06-record-share.png`
- [x] 本轮启动测试路由已补强为“首屏直达”结构：
  - `ContentView` 已为分析 / 记录 / 设置 tab 注入初始 deep link 目的地
  - `AnalysisHubView`、`RecordsView`、`SettingsView` 已支持冷启动直接消费首屏路由
  - 当前仍受 `CoreSimulatorService` 波动影响，尚未完成英文专题页截图实证核销
- [x] 本轮英文专题页已有新增实证：
  - `analysis/orientation-demo` 已确认可在英文冷启动下进入分析专题页，而不再回落到罗盘首页
  - 证据：`/private/tmp/tame-en-orientation-demo-routefix-v2-20260506.png`
  - 这说明首屏 deep link 补强已生效，后续英文公开截图可继续沿同一机制推进
- [x] 本轮构建 blocker 已进一步拆解：
  - `xcodebuild -sdk iphonesimulator -destination 'generic/platform=iOS Simulator'` 现已能走到后段
  - 单独执行 `actool` 时可成功产出 asset symbols 与 partial plist
  - 当前 `CompileAssetCatalogVariant` 失败更接近 `CoreSimulatorService / ibtoold` 环境链路波动，而不是明确的 asset 内容报错
- [x] 本轮英文截图主线的真实剩余项已继续收敛：
  - `en-US/02-naqi-analysis.png` 已补齐并通过尺寸 / alpha 校验
  - 当时公开截图失败项已进一步收敛为 4 个：
    - `en-US/03-flying-star.png`
    - `en-US/04-floor-plan-heatmap.png`
    - `en-US/05-bazhai.png`
    - `en-US/06-record-share.png`
  - 当时以上 4 张仍受延时截图窗口内 `CoreSimulatorService` 断联影响，尚无稳定正式图
    - `en-US/05-bazhai.png`
    - `en-US/06-record-share.png`
      当时仍缺失
- [x] 本轮 manifest / preflight 已重新同步：
  - `AppStoreAssets/MANIFEST.md` 已重生成，当前目录状态与清单一致
  - `SubmissionKit/PREFLIGHT_REPORT.md` 已重生成，旧 `_tmp` 截图残留已从最新报告移除
  - 当时最新报告失败面为：
    - `Xcode build`
    - `Readiness check`
    - 其中 `Readiness check` 的真实失败点继续集中在 `en-US` 公开截图链路
- [x] 本轮 `en-US` 公开截图已打开缺口：
  - `en-US/01-dual-compass.png` 已重新生成并替换为有效英文图
  - 当前已通过校验：`1206x2622`、`alpha=no`
- [x] 本轮前台成品化继续收口：
  - 首页、分析中心、户型分析、设置页、纳气/飞星/流年/八宅页已继续去掉开发态表达
  - “快速测向 / 参考户型 / 参考报告 / 权限与帮助”等用户向入口名称已替换旧的演示口径
  - 设置页与历史记录中的英文样例文本已改为更直观的 `North / South / South-facing` 口径
- [x] 当前 `en-US` 剩余失败项已更新为：
  - `04-floor-plan-heatmap.png`
  - `06-record-share.png`
    当时仍缺失；`03-flying-star.png` 与 `05-bazhai.png` 已落盘并通过尺寸 / alpha 校验
- [ ] 最新 `xcodebuild -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build` 仍未核销通过
  - 当前真实失败点：`CoreSimulatorService connection became invalid`
  - 资源编译链同时被 `ibtoold` / `actool` 牵连
  - 因此当前不能宣称“本地构建已通过”
- [x] 本轮 Simulator 环境异常已进一步坐实为服务未注册：
  - `launchctl print gui/$(id -u)/com.apple.CoreSimulator.CoreSimulatorService` 返回 `Could not find service`
  - `launchctl print system/com.apple.CoreSimulator.CoreSimulatorService` 同样返回 `Could not find service`
  - `open -a Xcode`、`open -a Simulator` 后再复测，`simctl` 仍立即掉回 `CoreSimulatorService connection became invalid`
  - `Computer Use` 读取 `Simulator` 前台窗口继续超时
  - 因此当时英文公开截图剩余 2 张无法继续稳定导出，真实 blocker 仍是系统 Simulator 服务链路，而不是页面功能再次缺失；后续已用本地生成脚本补齐上传前截图素材
- [ ] fresh install / smoke test 仍待完全核销
- [ ] App Store Connect 当前版本状态仍待人工核销

## 2026-05-08 当前快照

- [x] `records/share-preview` 已修成确定性 smoke 路由：每次触发都会生成一条参考报告记录并直接打开详情页，避免空记录状态回落到飞星页，也避免旧历史记录污染截图
- [x] `HistoryStore.save(...)` 已返回保存后的 `AnalysisRecord`，并新增 `save(_ record:)`，用于保存后立即导航到详情
- [x] 已补 `RecordReportComposerTests.testSharePreviewRecordContainsExportReadyContent`
- [x] 本轮语法检查已通过：
  - `HistoryStore.swift`
  - `RecordsView.swift`
  - `TAMEGeomancyTests.swift`
- [x] 当前公开截图真实状态：
  - `zh-Hans` 6/6 已通过尺寸 / alpha 校验
  - `en-US` 6/6 已通过尺寸 / alpha 校验
  - 已新增 `scripts/generate_missing_en_screenshots.swift`，用于复跑生成 / 修正英文 `02`、`04`、`05`、`06`
  - 已视觉抽检修正 `en-US/05-bazhai.png` 误用系统主屏图、`en-US/02-naqi-analysis.png` 混入中文界面标题的问题
- [x] 本轮截图校验已通过：`./scripts/validate_appstore_screenshots.sh`
- [x] 本轮报告已重生成：`AppStoreAssets/MANIFEST.md`、`SubmissionKit/PREFLIGHT_REPORT.md`
- [ ] 本轮构建复核仍未通过：`xcodebuild ... generic/platform=iOS Simulator` 继续在 `CompileAssetCatalogVariant` 阶段报 `No available simulator runtimes for platform iphonesimulator`
- [ ] 本轮真机 generic 构建也未通过：`xcodebuild ... generic/platform=iOS CODE_SIGNING_ALLOWED=NO` 仍在 `CompileAssetCatalogVariant` 阶段被 `CoreSimulatorService / ibtoold / actool` 链路牵连
- [ ] 沙盒外 `xcodebuild` 复核申请被审批通道拒绝，未继续绕过执行
- [x] 本轮设备族继续收口：`project.yml` 与重生成后的 `TAMEGeomancy.xcodeproj` 已显式设置 `TARGETED_DEVICE_FAMILY = 1`，并关闭 `SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD` / `SUPPORTS_XR_DESIGNED_FOR_IPHONE_IPAD`
- [x] 本轮 Simulator 状态复核已更新：
  - `xcrun simctl list runtimes` 当前可列出 iOS 26.0 / 26.1 / 26.2 / 26.4
  - `xcrun simctl list devices available` 当前可列出可用模拟器
  - 但 `xcodebuild` 仍在 `CompileAssetCatalogVariant` 阶段把 `supportedRuntimes` 读成空，并伴随 `CoreSimulatorService connection became invalid` 与 `simdiskimaged crashed or is not responding`
- [ ] 关闭 Mac / XR 兼容目标后，`generic/platform=iOS` 设备构建仍未核销通过；最新失败仍在 `CompileAssetCatalogVariant`，错误链路为 `ibtoold -> CoreSimulatorService / simdiskimaged -> supportedRuntimes=[]`
- [x] 本轮预检已重跑：`SubmissionKit/PREFLIGHT_REPORT.md` 更新时间为 `2026-05-08 21:04:54 +0800`，当前 `Readiness check` / 截图 manifest / WebLegal dist 为 PASS，`Xcode build` 为 FAIL
- [x] 本轮一次性解锁审核口径已收口：`PremiumAccessStore`、`OverviewDashboardView`、`TAMEGeomancy.storekit`、`APPSTORE_METADATA.md` 与 `SubmissionKit/03_ASC_IAP_Setup.md` 已去掉“后续高级能力 / future advanced analysis”类未来承诺，只保留报告分享与保存到相册两项真实权益
- [x] 本轮解锁项与资料校验通过：
  - `swiftc -frontend -parse TAMEGeomancy/ViewModels/PremiumAccessStore.swift TAMEGeomancy/Views/OverviewDashboardView.swift`
  - `TAMEGeomancy.storekit` JSON parse 通过
  - `./scripts/readiness_check.sh` 通过
- [x] 本轮 readiness 已加固：`scripts/readiness_check.sh` 现在会检查 iPhone-only 设备族、Mac/XR 兼容开关关闭、StoreKit JSON、终身解锁 product id、价格，以及禁止“future advanced / 后续高级能力”类未来权益承诺
- [x] 本轮 preflight 报告已增强：`scripts/preflight_audit.sh` 现在会把 `.build-cache/preflight_build.log` 尾段、`simctl list runtimes` 与 `simctl list devices available` 的只读诊断写入 `SubmissionKit/PREFLIGHT_REPORT.md`
- [x] 最新 preflight 复核已记录：`SubmissionKit/PREFLIGHT_REPORT.md` 更新时间为 `2026-05-08 21:41:18 +0800`，当前连只读 `simctl` 也返回 `CoreSimulatorService connection became invalid` / `Failed to initialize simulator device set`，构建 blocker 仍是本机 Simulator 服务链路
- [x] 本轮本地语法体检已补：`swiftc -frontend -parse TAMEGeomancy/**/*.swift TAMEGeomancyTests/**/*.swift` 通过，并已接入 `scripts/readiness_check.sh`
- [x] 本轮工作区噪音已收口：`.gitignore` 已覆盖 `.DerivedData*/`，后续 `.DerivedDataActoolProbe`、`.DerivedDataDevice`、`.DerivedDataGenericSim*`、`.DerivedDataLive`、`.DerivedDataLocal` 不再进入未跟踪列表
- [x] 本轮旧模拟器包问题已核销：
  - 已卸载旧 bundle，并通过 Xcode GUI 重新安装当前工程到 `iPhone 17 Pro (26.4.1)`
  - 最新 app container 为 `/Users/pengpeng/Library/Developer/CoreSimulator/Devices/D943A272-7E86-4A7A-B6CA-6E3E9B8DB6D0/data/Containers/Bundle/Application/F49BF059-8FDB-4D5A-8603-3D641555A213/TAMEGeomancy.app`
  - 已确认不再是旧的 `TAMEGeomancyMerged-20260507.app`
  - 最新包内版本为 `探觅·堪舆 / com.tame.geomancy / 1.0.0 (1)`
- [x] 本轮 App Icon 已修复：
  - 原 `AppIcon-1024.png` 与 `Design/app-icon-selected-23.png` 带 `豆包AI生成` 水印，不可用于提审
  - 已替换为本地原创无水印白金罗盘几何图标
  - 新图标已核对为 `1024x1024`、RGB PNG、`hasAlpha: no`
  - SpringBoard 已显示新版 `探觅·堪舆` 图标
- [x] 本轮最新运行证据：
  - `/private/tmp/tamegeomancy-after-icon-run.png`
  - `/private/tmp/tamegeomancy-springboard-icon.png`
- [x] 本轮 readiness 已重跑通过：`./scripts/readiness_check.sh` PASS
- [ ] 本轮 release gate 仍未通过：`./scripts/release_gate.sh` 仍为 BLOCKED，当前剩余阻塞不是旧包/旧图标，而是 CLI preflight 构建链路、ASC 在线核对、正式打包上传与外部上线项
- [x] 本轮 App Store IPA 已通过 Xcode GUI archive + export 产出：
  - `/Users/pengpeng/Desktop/codex工作区/TAMEGeomancy/exports/TAMEGeomancy-1.0.0-1-export/TAMEGeomancy.ipa`
  - archive：`/Users/pengpeng/Library/Developer/Xcode/Archives/2026-05-08/TAMEGeomancy 2026-5-8, 23.08.xcarchive`
  - 导出签名为 App Store distribution，Team ID `C3SV2L8GV4`
- [ ] Transporter 上传仍未完成：
  - 必须使用 Transporter，不走 Xcode Organizer 上传
  - Transporter GUI 已登录，但加入 IPA 后停在“查询软件 ID”并未出现可交付行
  - 当前需要先确认 / 创建 App Store Connect app 记录：bundle id `com.tame.geomancy`，SKU `com.tame.geomancy`，名称 `探觅·堪舆`，主语言建议 `zh-Hans`
  - ASC app 记录存在后，重新添加同一个 IPA 到 Transporter 并点击“交付”

## 推荐使用入口

- 任务基线：`TODO.md`
- blocker 清零：`BLOCKER_CLEARANCE_LOG.md`
- fresh install 执行单：`SMOKE_TEST_RUNBOOK.md`
- 最终提审检查：`FINAL_SUBMISSION_CHECKLIST.md`
- 提交顺序：`SubmissionKit/00_Submission_Runbook.md`
- 可粘贴字段：`SubmissionKit/01_Copy_Paste_Fields.md`
- ASC 在线核对：`SubmissionKit/02_ASC_Live_Checklist.md`
- 本地预检报告：`SubmissionKit/PREFLIGHT_REPORT.md`
- 本地自检脚本：`scripts/readiness_check.sh`
- 一键预检脚本：`scripts/preflight_audit.sh`
- 截图校验脚本：`scripts/validate_appstore_screenshots.sh`
- 截图 manifest 脚本：`scripts/generate_screenshot_manifest.sh`
- WebLegal 配置脚本：`scripts/configure_weblegal.sh`
- WebLegal dist 构建脚本：`scripts/build_weblegal_dist.sh`
