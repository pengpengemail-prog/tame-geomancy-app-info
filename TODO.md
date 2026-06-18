# TAMEGeomancy 任务清单

更新时间：2026-05-08

## 核销入口

- 主核销面板：[FINAL_EXECUTION_BOARD.md](FINAL_EXECUTION_BOARD.md)
- blocker 清零记录：[BLOCKER_CLEARANCE_LOG.md](BLOCKER_CLEARANCE_LOG.md)
- fresh install 执行单：[SMOKE_TEST_RUNBOOK.md](SMOKE_TEST_RUNBOOK.md)

## 官方问题点 vs 已修复 / 待修复项目

| 官方问题点 | 已修复 / 待修复项目 |
| --- | --- |
| 双盘罗盘未真正启用 | 已修复：`CompassDiskView` 与 `CompassView` 已切换为地盘 + 纳气盘双盘主界面 |
| 八宅模块是占位页 | 已修复：`BazhaiView` / `BazhaiViewModel` 已实现宅卦、东四西四宅、命卦匹配与房间建议 |
| 分析页入口不完整 | 已修复：主导航已接入坐向纳气、三元九运、飞星、流年、户型、八宅、形煞参考 |
| 历史记录只能查看，不能导出 | 已修复：记录详情已支持备注保存、报告卡生成与系统分享 |
| 户型分析缺少热力图和结构化保存 | 已修复：已支持热力图开关、方位强弱叠加、立极点/朝向/房间标记完整保存 |
| 项目文档仍显示 60% 完成 | 已修复：`README.md`、`DEVELOPMENT_STATUS.md`、`HANDOVER_TO_CODEX.md`、`PROJECT_STATUS.md` 已同步当前状态 |
| 自动化测试覆盖不足 | 处理中：已补户型分析与分享文本测试，仍缺真实交互级测试 |
| 模拟器测试环境不完整 | 已定位 blocker：已补只读诊断脚本；当前构建复核与测试均受 `CoreSimulatorService` 失联、Simulator runtime 无法发现影响 |

## 核心功能清单

- [x] 双盘罗盘：地盘 + 纳气盘 7.5° 固定偏移
- [x] 坐向与纳气分析
- [x] 三元九运总览与自动识别
- [x] 玄空飞星排盘
- [x] 流年运势页面
- [x] 户型图导入、立极点、房间标记、九宫分析
- [x] 八宅风水与命卦匹配
- [x] 形煞知识参考
- [x] 历史记录保存、编辑、详情查看
- [x] 报告卡导出与系统分享
- [x] 设置页基础开关、数据清理与本地备份恢复

## 本轮新增核销

- [x] app target 部署版本已从错误的 `iOS 26.0` 回归到开发文档要求的 `iOS 15.0`
- [x] `AnalysisHub` / `Records` / `onChange` 相关兼容层已补齐，当前工程不再建立在高版本 API 假设上
- [x] 白底品牌收口继续推进：罗盘、八宅、三元九运页面已统一到白底品牌规范
- [x] 功能交付矩阵已补：新增 `FEATURE_DELIVERY_MATRIX.md`，用于区分“代码实现”和“真实核销”
- [x] 总览页专题直测入口已补：坐向纳气、三元九运、飞星、流年、八宅、本地备份可从首页直达
- [x] 专题页演示态增强：坐向纳气、飞星排盘、流年运势、八宅风水均已补一键带入场景，首屏可直接看到稳定样例
- [x] 记录详情分享：新增 `RecordShareSupport.swift`，支持报告图 + 文本分享
- [x] 户型热力图：支持按九宫得分叠加旺位/吉位/平位/注意位
- [x] 户型记录增强：保存立极点、朝向、吉位、注意位、房间标记、建议
- [x] 任务单补建：补充可核销的真实任务清单
- [x] 状态文档同步：清理旧的 60% 完成表述
- [x] 上架资料：新增文案、截图方案、审核备注、审核规避、算法说明
- [x] 分享文本测试：补充 `RecordReportComposer` 文本导出测试
- [x] 法务/支持草稿：补充隐私政策、条款、支持页
- [x] 提审模板：补充截图交付清单与最终检查清单
- [x] App 内政策页：设置页可进入隐私政策、使用条款、支持说明
- [x] SubmissionKit：补充本地提审执行目录与顺序说明
- [x] WebLegal：补充可托管的支持/隐私/条款网页模板
- [x] 导出测试增强：补充报告图渲染与分享项测试
- [x] AppStoreAssets：补充截图目录骨架与中英清单
- [x] Smoke Test 执行单：补充 fresh install 核销模板
- [x] Blocker 日志：补充最终人工 blocker 清零记录表
- [x] `xcodegen` 已重跑，工程与 `project.yml` 配置重新同步
- [x] `readiness_check.sh` 已补充显示名、审核备注、`WebLegal/dist` 校验
- [x] `preflight_audit.sh` 已输出显示名与当前提交判断
- [x] `diagnose_xcode_simulator.sh` 已补齐并接入 preflight，用于留存 Xcode / Simulator 只读诊断报告
- [x] `release_gate.sh` 已补齐并接入 SubmissionKit，用于统一输出自动门禁、环境门禁与人工门禁状态
- [x] 公开法务模板与审核备注已统一去除 reviewer 可见的内部工程名 `TAMEGeomancy`
- [x] 最新本地预检已确认命名一致性通过，剩余失败集中在占位法务信息和缺失截图
- [x] 本地备份闭环：设置页已支持历史记录 JSON 导出、备份恢复与清空前确认
- [x] 备份测试补齐：新增历史记录备份 round-trip、去重导入与坏文件校验测试
- [x] 报告保存到相册：记录详情已支持直接保存报告图到系统相册
- [x] 历史记录体验增强：已支持分类筛选、关键词搜索与清空前确认
- [x] Smoke 辅助导航：已支持 `tamegeomancy://tab/<name>` 深链接直达底部 tab
- [x] 历史记录覆盖补齐：八宅风水、形煞参考已支持保存到历史记录
- [x] 户型示例模式：户型图分析页已支持一键加载示例户型，自动带入立极点、房间标记与分析结果
- [x] 分析页 smoke 深链接增强：已支持 `tamegeomancy://analysis/floor-plan-demo` 直达示例户型分析结果页
- [x] 分析页 smoke 深链接扩展：已支持 `tamegeomancy://analysis/orientation-demo`、`flying-star-demo`、`annual-demo` 直达专题演示场景
- [x] 记录页 smoke 深链接增强：已支持 `tamegeomancy://records/share-preview` 自动生成示例分享记录并打开详情预览
- [x] App 内实测主线：总览页已补快速测向、参考户型、参考报告、权限与帮助 4 条稳定入口
- [x] 分析页推荐入口：分析中心已补“打开参考户型”快捷入口
- [x] 记录页示例生成：空记录与空筛选状态下可直接生成演示记录并打开详情
- [x] iPhone 构建收口：工程已显式收口到 iPhone 设备族，减少方向校验噪音
- [ ] generic iOS 构建需重新核销：最近一次复核受 `CoreSimulatorService` / runtime 发现失败影响，当前不能记为已通过
- [x] 首页首启体验修复：罗盘传感器仅在真正进入罗盘 tab 时启动，避免总览页首启被定位弹窗遮挡
- [x] 设置页权限速览：总览页“权限与支持”现可直接进入定位/方向/相机/相册状态面板
- [x] 最新运行态证据已补：首页、罗盘演示、权限速览三张关键截图已重新抓取
- [x] 历史记录交互补核销：备注保存与系统分享面板调起已通过 app 内主线验证
- [x] 户型分析交互补核销：示例户型分析已通过 app 内主线验证，可看到纳气口、热力图与房间标记
- [x] 罗盘设置回流补核销：关闭纳气盘后，盘面与数据卡会同步显示“已隐藏”，恢复开启后重新显示双盘
- [x] 户型导入权限链路补核销：相册可拉起系统照片选取器，选图后能回流分析页并自动生成九宫结果
- [x] 保存到相册权限链路补核销：记录详情页会触发系统“添加到照片”授权，允许后可保存成功并回写状态
- [x] 权限说明收口：户型页导入提示与设置页权限速览文案已按真实系统行为修正
- [x] 英文界面残留继续压缩：`BazhaiView`、`AnnualFortuneView`、`FloorPlanAnalysisViewModel`、`OrientationAnalysisView`、`CompassView`、`FlyingStarChartView` 已统一前台与记录文案中的方向 / 卦位显示口径，减少英文模式混入中文标签
- [x] 纳气生成文案继续收口：`NaqiAnalyzer` 已统一分析文本、综合摘要与建议文案中的方向 / 五行 / 等级口径，减少底层生成文本回流前台时的中英混用
- [x] 本轮语法体检已补：`NaqiAnalyzer` 与本轮改动的 7 个主页面 / ViewModel 已通过 `swiftc -frontend -parse` 级检查
- [x] readiness 复核已补：当前主失败面已重新确认集中在 `en-US` 公开截图链路，不是本轮代码回退
- [x] 模拟器产物状态已复核：`Debug-iphonesimulator/TAMEGeomancy.app` 仍存在，`Info.plist` 中 `com.tame.geomancy`、`探觅·堪舆`、`MinimumOSVersion 15.0` 正常，当前问题集中在 Simulator 服务稳定性而非产物缺失
- [x] 截图目录进一步整理：`zh-Hans` 公开目录已清干净并再次通过校验，`review-only` 未再混入公开文件名，当前截图失败面已收敛为 `en-US` 公开截图链路
- [x] manifest / preflight 已重生成：旧的 `_tmp` 截图残留已从报告中移除，当前最新报告只保留真实失败项
- [x] `en-US/01-dual-compass.png` 已重出：现已替换为 1206x2622、无 alpha 的英文罗盘正式图，截图失败项已从 6 个降到 5 个
- [x] 最新 readiness 已通过：截图、StoreKit、WebLegal、公开文案与 Swift parse 均为 PASS
- [x] 最新 preflight 已重生成：当前失败项集中在 `Xcode build` 与 `Xcode / Simulator diagnostics`
- [x] 最新 release gate 已生成：当前为 `BLOCKED`，阻塞项为 preflight、Simulator diagnostics、ASC 在线核对与最终提交清单

## 待继续事项

- [ ] 恢复所有门禁后，重跑 `./scripts/release_gate.sh` 并确认 `SubmissionKit/RELEASE_GATE_REPORT.md` 显示 `PASS`
- [ ] 用真实域名和支持邮箱执行 `./scripts/configure_weblegal.sh --apply`
- [ ] 部署 `WebLegal/dist/` 并拿到真实 Support / Privacy / Terms URL
- [x] 导出 / 补齐 `zh-Hans` 与 `en-US` 最终截图并运行 `./scripts/validate_appstore_screenshots.sh`
- [ ] 在真机或可重置权限的模拟器环境补完剩余交互级 smoke：坐向纳气实时计算、三元九运切年、飞星/流年/八宅逐页点测、本地备份导出恢复
- [ ] 在 App Store Connect 核对版本状态、链接与最终截图上传结果
- [x] 补齐并修正 `en-US` 公开截图：`02`、`04`、`05`、`06` 已用本地生成脚本修复，`05` 不再误用系统主屏图，`02` 不再混入中文界面标题
- [ ] 恢复 `CoreSimulatorService` / `simdiskimaged` / runtime 可见性后，重跑 `./scripts/diagnose_xcode_simulator.sh` 与 `./scripts/preflight_audit.sh`

## 当前总判断

- 本地开发工作已基本完成
- 当前不能直接核销为“可提交”
- 统一结论以 [FINAL_EXECUTION_BOARD.md](FINAL_EXECUTION_BOARD.md) 为准

## 本轮核销

- [x] `iOS 15+` 交付底座已回归
- [x] 白底品牌主线已继续覆盖罗盘 / 八宅 / 三元九运页面
- [x] 功能交付矩阵已补建，可按 `FEATURE_DELIVERY_MATRIX.md` 继续逐项核销
- [x] 总览页专题直测入口已完成代码核销，可降低逐页实测成本
- [x] 本地工程同步已完成
- [x] 命名一致性与 reviewer 可见品牌暴露问题已完成本地核销
- [x] 预检失败项已收敛
- [x] 历史记录本地备份与恢复已完成代码核销
- [x] 报告图直存相册与记录页增强已完成代码核销
- [x] 模拟器 smoke 辅助深链接已完成代码核销
- [x] 八宅与形煞模块历史记录闭环已完成代码核销
- [x] 户型示例模式已完成代码核销
- [x] 分析页示例深链接已完成代码核销
- [x] 记录页分享预览深链接已完成代码核销
- [x] 启动测试路由已完成代码核销，可用 `-TAMELaunchRoute` 在模拟器无弹窗直达 smoke 页面
- [x] 页面级 smoke 证据已补：设置页、示例户型分析页、示例分享记录详情页
- [x] App 内稳定演示入口已完成代码核销，不再只依赖外部启动路由
- [ ] iPhone generic build 需等待当前构建 blocker 清除后重新核销
- [x] 专题页首屏演示强化已完成代码核销，可降低逐页手动调参成本
- [x] 专题页专用 smoke 路由已完成代码核销，可直接拉起纳气 / 飞星 / 流年演示页
- [x] 最新模拟器 smoke 证据已补：
  - `/private/tmp/tame-overview-no-permission.png`
  - `/private/tmp/tame-compass-demo-latest.png`
  - `/private/tmp/tame-settings-permissions-focus.png`
- [x] 最新交互级 smoke 证据已补：
  - `/private/tmp/tame-floorplan-interactive-latest.png`
- [x] 本轮新增交互级 smoke 证据已补：
  - `/private/tmp/tame-compass-settings-sync-off.png`
  - `/private/tmp/tame-compass-settings-sync-off-fixed.png`
  - `/private/tmp/tame-floorplan-camera-entry.png`
  - `/private/tmp/tame-floorplan-photo-import-success.png`
  - `/private/tmp/tame-record-save-to-photos-success.png`
  - `/private/tmp/tame-settings-photo-save-allowed.png`
- [x] 本轮新增专题前台证据已补：
  - `/private/tmp/tame-orientation-demo-20260505-v3.png`
  - `/private/tmp/tame-flying-star-demo-20260505-v2.png`
  - `/private/tmp/tame-annual-demo-20260505.png`
  - `/private/tmp/tame-bazhai-smoke-20260505-v3.png`
- [x] 白底可读性问题已修复：统一外观策略回到浅色品牌界面，避免白底页面叠加深色系统字色导致低对比
- [x] `zh-Hans` 公开截图 6 张已补齐并通过本地尺寸 / alpha 校验
- [x] 本轮构建 blocker 复核已补：即使切到 `/private/tmp` 派生目录并关闭签名，`generic/platform=iOS` 仍受 `CoreSimulatorService` 失联影响失败
- [x] 页面成品感继续收口：八宅、流年、飞星摘要区已补轻量信息胶囊，白底结构与信息层级进一步统一
- [x] 首页体系继续统一：总览、设置、记录页也已补同风格摘要信息块，白底品牌系统进一步贯通
- [x] 分析中心继续成品化：`AnalysisHubView` 已补白底摘要胶囊与目录层级，分析页不再只是功能列表
- [x] 知识/记录/支持页继续收口：`ReferenceKnowledgeView`、`RecordDetailView`、`SupportCenterView` 已补统一摘要胶囊与导出动作卡
- [x] 英文残留继续清理：`CompassDiskView`、`JiuyunOverviewView` 已改用 `localizedLabel`，降低切英文后仍冒中文的概率
- [x] 罗盘主页继续成品化：`CompassView` 已补品牌摘要胶囊，北向模式 / 盘面风格 / 锁定状态 / 双盘状态前台层级更清晰
- [x] 纳气主页继续成品化：`OrientationAnalysisView` 已补元运 / 主纳气 / 综合评分 / 联动飞星摘要胶囊，并把保存动作升级为说明型操作卡
- [x] 户型主页继续成品化：`FloorPlanAnalysisView` 已补导入状态 / 热力图 / 当前朝向 / 标记模式摘要胶囊，导入入口升级为说明型操作卡
- [x] 八宅主页继续成品化：`BazhaiView` 已补命卦联动 / 当前状态 / 房屋坐山 / 命卦输入摘要胶囊，并把保存动作升级为说明型操作卡
- [x] 流年主页继续成品化：`AnnualFortuneView` 已补房屋联动 / 年度重点摘要胶囊，并把保存动作升级为说明型操作卡
- [x] 八宅与流年口径继续统一：`BazhaiViewModel`、`AnnualFortuneViewModel` 已继续改用 `localizedLabel`，减少前台中英混用残留
- [x] 本轮前台与记录口径继续收口：`BazhaiView`、`AnnualFortuneView`、`FloorPlanAnalysisViewModel`、`OrientationAnalysisView`、`CompassView`、`FlyingStarChartView`、`FloorPlanAnalysisView` 已继续改用 `localizedLabel`，当前这批主页面与记录导出链路已无 `.chinese` 残留
- [x] 本轮底层生成文案继续收口：`NaqiAnalyzer` 已统一分析 / 摘要 / 建议里的方向、五行与等级文本口径
- [x] 本轮 parse 级检查已通过：`swiftc -frontend -parse` 已覆盖 `NaqiAnalyzer` 与本轮修改的主页面 / ViewModel 文件
- [x] 本轮 readiness 失败面已重新确认：当时仍集中在 `en-US` 公开截图剩余 4 张缺失，以及模拟器截图链路不稳定；后续截图已补齐并通过校验
- [x] 本轮模拟器产物与链路状态已继续写实：
  - `.DerivedData/Build/Products/Debug-iphonesimulator/TAMEGeomancy.app` 仍存在
  - app `Info.plist` 仍显示 `com.tame.geomancy`、`探觅·堪舆`、`MinimumOSVersion 15.0`
  - 当前不是“没有可装包”，而是 Simulator 服务与桌面控制不稳定，导致英文截图链路无法稳定继续
- [x] 本轮截图目录状态已再次核销：
  - `zh-Hans` 公开截图 6 张继续通过尺寸 / alpha 校验
  - `review-only` 当前未混入公开截图文件名
  - 当时截图校验失败已收敛为：
    - `en-US/03-flying-star.png`
    - `en-US/04-floor-plan-heatmap.png`
    - `en-US/05-bazhai.png`
    - `en-US/06-record-share.png`
- [x] 本轮报告状态已重新对齐：
  - `AppStoreAssets/MANIFEST.md` 已按当前目录重生成
  - `SubmissionKit/PREFLIGHT_REPORT.md` 已按最新 readiness 重生成
  - 旧的 `_tmp-01-dual-compass.png` 等历史残留已不再污染最新报告
- [x] 本轮英文公开截图已开始实补：
  - `en-US/01-dual-compass.png` 已替换为英文前台有效图
  - 当前尺寸：`1206x2622`
  - 当前 alpha：`no`
  - 当时截图校验失败数：`5`
- [x] 本轮英文前台口径继续收口：首页、分析中心、坐向纳气、飞星排盘、八宅风水、记录页、设置页、政策页已把 `Naqi / Bazhai / Period Cycles` 等高频英文改为更直观的用户向表达
- [x] 本轮前台英文残留继续清理：`desk` 一类后台口吻已继续收口为更自然的页面说明，记录分类与政策说明页英文口径已同步统一
- [x] 本轮 parse 级检查已继续通过：`OverviewDashboardView`、`AnalysisHubView`、`OrientationAnalysisView`、`FlyingStarChartView`、`BazhaiView`、`JiuyunOverviewView`、`RecordsView`、`AnnualFortuneView`、`PolicyCenterView`、`SettingsView`、`HistoryStore` 已通过 `swiftc -frontend -parse`
- [x] 本轮前台口径继续收口：首页、分析中心、户型分析、设置页、纳气/飞星/流年/八宅页已继续去掉“演示 / 模拟器 / 审核 / 工作台”等开发态表达
- [x] 本轮英文样例文本继续收口：设置页本地备份参考记录、历史记录参考条目、户型参考户型文案已改为更直观的中英口径
- [x] 本轮前台文案 parse 级检查已通过：`OverviewDashboardView`、`AnalysisHubView`、`FloorPlanAnalysisView`、`SettingsView`、`CompassViewModel`、`OrientationAnalysisView`、`FlyingStarChartView`、`AnnualFortuneView`、`BazhaiView`、`TAMETheme` 已通过 `swiftc -frontend -parse`
- [x] 本轮英文生成文案继续收口：`NaqiAnalyzer` 与 `FloorPlanAnalysisViewModel` 已修正若干生硬的英文拼接句式，减少截图与英文前台中的“机翻感”
- [x] 本轮英文长文案继续收口：`FlyingStarCalculator`、`BazhaiViewModel`、`AnnualFortuneViewModel` 已继续优化英文摘要与说明文本的自然度
- [x] 本轮启动路由首屏直达已补强：
  - `ContentView` 已为 `analysis / records / settings` 注入初始目的地
  - `AnalysisHubView`、`RecordsView`、`SettingsView` 已支持冷启动首屏消费初始 deep link
  - 相关改动已通过 `swiftc -frontend -parse`
  - 当时仍待 `CoreSimulatorService` 稳定后补英文专题页前台实证
- [x] 本轮英文专题路由已有前台实证：
  - `tamegeomancy://analysis/orientation-demo` 在 `-TAMELocale en-US` 下已可冷启动直达分析页
  - 证据图：`/private/tmp/tame-en-orientation-demo-routefix-v2-20260506.png`
  - 当时仍存在页面内局部中英混排，且 `03` 至 `06` 的英文正式图尚未补齐；后续已修正英文公开素材
- [x] 本轮英文公开截图继续实补：
  - `AppStoreAssets/en-US/02-naqi-analysis.png` 已由英文前台证据图正式落盘
  - 当前尺寸：`1206x2622`
  - 当前 alpha：`no`
  - 当时截图校验失败数：`4`
- [x] 本轮 asset 编译 blocker 已进一步写实：
  - `actool` 单独按 `xcodebuild` 日志中的完整参数可成功执行
  - `xcodebuild generic iOS Simulator` 仍会在 `CompileAssetCatalogVariant` 阶段失败
  - 当前更接近 `CoreSimulatorService / ibtoold` 链路波动，而非 `Assets.xcassets` 内容本身必然损坏
- [ ] 外部链接上线、fresh install、ASC 在线核对与 ASC 截图上传预览仍未核销

## 2026-05-08 当前快照

- [x] `records/share-preview` smoke 路由已修成稳定参考报告路径：无论当前是否已有历史记录，都会生成一条本地参考报告并直接打开详情，避免 fresh install 截图回落到飞星页或被旧记录污染
- [x] `HistoryStore.save(...)` 现在返回已保存的 `AnalysisRecord`，并新增 `save(_ record:)`，方便 deep link / smoke 入口保存后立即打开详情
- [x] 新增 `RecordReportComposerTests.testSharePreviewRecordContainsExportReadyContent`，覆盖参考报告记录具备导出说明与非空备注
- [x] 本轮语法检查通过：`swiftc -frontend -parse TAMEGeomancy/ViewModels/HistoryStore.swift TAMEGeomancy/Views/RecordsView.swift TAMEGeomancyTests/TAMEGeomancyTests.swift`
- [x] 当前 `AppStoreAssets/en-US` 已有 6 张通过尺寸 / alpha 校验：
  - `01-dual-compass.png`
  - `02-naqi-analysis.png`
  - `03-flying-star.png`
  - `04-floor-plan-heatmap.png`
  - `05-bazhai.png`
  - `06-record-share.png`
- [x] 新增 `scripts/generate_missing_en_screenshots.swift`，可复跑生成 / 修正英文 `02`、`04`、`05`、`06` 上传图
- [x] 本轮截图校验通过：`./scripts/validate_appstore_screenshots.sh`
- [x] 本轮 manifest / preflight 已重生成：`AppStoreAssets/MANIFEST.md`、`SubmissionKit/PREFLIGHT_REPORT.md`
- [ ] 本轮 `xcodebuild -project TAMEGeomancy.xcodeproj -scheme TAMEGeomancy -destination 'generic/platform=iOS Simulator' -derivedDataPath .DerivedData build` 仍未通过，失败点继续集中在 `CoreSimulatorService / ibtoold / actool`：`No available simulator runtimes for platform iphonesimulator`
- [ ] 本轮 `xcodebuild -project TAMEGeomancy.xcodeproj -scheme TAMEGeomancy -destination 'generic/platform=iOS' -derivedDataPath .DerivedDataDevice CODE_SIGNING_ALLOWED=NO build` 也未通过，失败点同样在 `CompileAssetCatalogVariant`
- [ ] 沙盒外 `xcodebuild` 复核申请被审批通道拒绝，当前未绕过执行；构建与 fresh install 仍需等本机 Simulator 服务稳定后继续
- [x] 本轮设备族已继续收口：`project.yml` / `TAMEGeomancy.xcodeproj` 已显式关闭 Mac / XR 兼容目标，只保留 iPhone 设备族
- [ ] 关闭 Mac / XR 兼容目标后，`generic/platform=iOS` 设备构建仍未通过，失败点依旧是 `ibtoold` 触发的 `CoreSimulatorService / simdiskimaged` 断联与 `supportedRuntimes=[]`
- [x] 本轮一次性解锁审核口径已收口：app 内、StoreKit 本地配置、App Store 文案与解锁配置清单不再承诺“后续高级能力”，仅保留报告分享与保存到相册两项当前真实权益
- [x] 本轮 readiness 已通过：`./scripts/readiness_check.sh`
- [x] 本轮 readiness 规则已加固：现在会自动检查设备族、Mac/XR 兼容开关、StoreKit JSON、终身解锁 product id / 价格，以及未来权益承诺回退
- [x] 本轮 preflight 报告已增强：现在自动写入 Xcode build 日志尾段与 `simctl` runtime/device 只读诊断，最新报告进一步确认当前 blocker 是 CoreSimulatorService / simdiskimaged 链路
- [x] 本轮 Swift parse 级体检已通过并接入 readiness：`swiftc -frontend -parse TAMEGeomancy/**/*.swift TAMEGeomancyTests/**/*.swift`
- [x] 本轮 `.gitignore` 已覆盖 `.DerivedData*/`，避免构建诊断派生目录继续污染工作区状态
