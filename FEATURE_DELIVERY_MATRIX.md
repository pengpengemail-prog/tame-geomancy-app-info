# TAMEGeomancy 功能交付矩阵

更新时间：2026-05-08

说明：本表按最初完整版开发文档拆分，区分 `已实现`、`已实现待实测`、`部分实现`、`外部阻塞` 四类，避免把代码完成和真实核销混为一谈。

| 模块 | 状态 | 当前实现 | 代码入口 / 说明 |
| --- | --- | --- | --- |
| 双盘罗盘 | 已实现待实测 | 地盘 + 纳气盘双盘同屏、7.5° 固定偏移、锁向、磁场干扰、水平仪、样式切换、比例与透明度调节 | `TAMEGeomancy/Views/CompassView.swift` `TAMEGeomancy/Views/CompassDiskView.swift` |
| 真北 / 磁北 | 已实现待实测 | 已接入真北开关与定位校正回流 | `TAMEGeomancy/ViewModels/CompassViewModel.swift` |
| 坐山朝向识别 | 已实现 | 已支持方向识别、坐山朝向、东四西四宅基础判断 | `TAMEGeomancy/Models/Direction.swift` `TAMEGeomancy/Models/FengShuiModels.swift` |
| 纳气分析 | 已实现待实测 | 支持大门 / 阳台 / 窗户纳气点录入、主纳气口对比、旺衰与建议，并补首屏演示场景 | `TAMEGeomancy/Views/OrientationAnalysisView.swift` `TAMEGeomancy/Services/NaqiAnalyzer.swift` |
| 三元九运 | 已实现待实测 | 七运 / 八运 / 九运自动归运与手动年份切换 | `TAMEGeomancy/Views/JiuyunOverviewView.swift` |
| 玄空飞星排盘 | 已实现待实测 | 运盘、山盘、向盘、流年盘基础排盘与九宫展示，并补预置排盘场景 | `TAMEGeomancy/Views/FlyingStarChartView.swift` `TAMEGeomancy/Services/FlyingStarCalculator.swift` |
| 流年运势 | 已实现待实测 | 流年九宫、中宫星、太岁 / 岁破、方位宜忌、房屋联动，并补年度演示场景 | `TAMEGeomancy/Views/AnnualFortuneView.swift` `TAMEGeomancy/ViewModels/AnnualFortuneViewModel.swift` |
| 户型图分析 | 已实现待实测 | 相册 / 相机导入、立极点、朝向旋转、九宫格、热力图、房间标记、示例户型 | `TAMEGeomancy/Views/FloorPlanAnalysisView.swift` `TAMEGeomancy/ViewModels/FloorPlanAnalysisViewModel.swift` |
| 户型纳气联动 | 已实现待实测 | 已把大门 / 阳台 / 窗户标记纳入主纳气口比较，并回流九宫建议 | `TAMEGeomancy/ViewModels/FloorPlanAnalysisViewModel.swift` |
| 八宅风水 | 已实现待实测 | 命卦、宅卦、东四 / 西四命、方位建议、房间建议，并补命宅样例场景 | `TAMEGeomancy/Views/BazhaiView.swift` `TAMEGeomancy/ViewModels/BazhaiViewModel.swift` |
| 形煞知识参考 | 已实现 | 图文知识参考、可保存到记录 | `TAMEGeomancy/Views/ReferenceKnowledgeView.swift` |
| 历史记录 | 已实现待实测 | 分类筛选、搜索、详情页、备注持久化、清空确认、示例记录生成 | `TAMEGeomancy/Views/RecordsView.swift` `TAMEGeomancy/Views/RecordDetailView.swift` |
| 报告导出 / 分享 | 已实现待实测 | 参考报告卡、系统分享、保存到相册 | `TAMEGeomancy/Views/RecordShareSupport.swift` |
| 本地备份 / 恢复 | 已实现待实测 | JSON 导出、导入、清空前确认 | `TAMEGeomancy/Views/SettingsView.swift` `TAMEGeomancy/Views/HistoryBackupSupport.swift` |
| 隐私 / 条款 / 支持页 | 已实现 | App 内政策页已接入 | `TAMEGeomancy/Views/PolicyCenterView.swift` |
| App 内主线导览 | 已实现 | 总览页、分析中心、深链接、示例路径已打通，含专题演示专用路由 | `TAMEGeomancy/Views/OverviewDashboardView.swift` `TAMEGeomancy/Views/ContentView.swift` |
| 白底品牌 VI | 已实现 | 主界面已切换为白底 + 深蓝黑文字 + 星砂金强调 | `TAMEGeomancy/Views/TAMETheme.swift` |
| iOS 15 兼容 | 已实现 | app target 已回归 `iOS 15.0`，关键导航与状态监听已补兼容写法 | `TAMEGeomancy.xcodeproj/project.pbxproj` `TAMEGeomancy/Views/TAMETheme.swift` |
| Fresh install 完整实测 | 外部阻塞 | 已完成首页、罗盘、户型、记录、权限等部分核销，但仍缺逐页点测 | 见 `SMOKE_TEST_RUNBOOK.md` |
| App Store Connect 核销 | 外部阻塞 | 需人工登录 ASC 核对版本状态、链接与截图 | 见 `FINAL_EXECUTION_BOARD.md` |
| Support / Privacy / Terms 真实上线 | 外部阻塞 | 仓库内模板已齐，但还没替换真实域名 / 邮箱并部署 | 见 `WebLegal/` |
| 最终截图导出与上传前校验 | 本地已核销 / ASC 上传待核对 | `zh-Hans` 与 `en-US` 各 6 张公开素材已落盘，尺寸 / alpha / locale 本地校验通过；仍待 App Store Connect 上传后核对在线预览 | 见 `AppStoreAssets/` `SCREENSHOT_DELIVERY_CHECKLIST.md` |

## 当前总判断

- 代码主线已经不是“只有一个功能”的壳，而是完整多模块工程。
- 当前真正没核销完的，主要是 `构建 / Simulator 服务链路`、`逐页实测` 和 `提审外部条件`，不是核心页面或截图素材缺失。
- 后续继续开发时，优先级应为：
  1. 恢复本机 `CoreSimulatorService / ibtoold / actool` 链路并完成最新构建
  2. 补齐 `已实现待实测` 模块的逐页点测
  3. 清零 ASC、法务链接、一次性 IAP 挂载、截图上传预览等外部 blocker
  4. 再做额外包装或小幅视觉迭代
