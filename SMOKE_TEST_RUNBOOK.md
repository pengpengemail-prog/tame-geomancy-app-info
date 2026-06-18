# 探觅·堪舆 Smoke Test 执行单

更新时间：2026-05-08

## 测试环境

- 设备/模拟器：`iPhone 17 Pro` 模拟器（UDID：`762DCCF1-FA81-4C21-8E81-384F3A6458A0`）
- iOS 版本：`iOS 26.2`
- 测试时间：`2026-05-05 03:42 - 04:24`
- 执行人：Codex
- 最新状态：2026-05-08 无法基于最新代码重跑 fresh install，`xcodebuild` 当前仍被 `CoreSimulatorService / ibtoold / actool` 环境链路阻塞。以下勾选项为 2026-05-05 旧构建/旧环境证据，不能替代最新二进制核销。

## Fresh Install

- [x] 删除旧版本
- [x] 重新安装最新 build
- [x] 桌面图标标签为 `探觅·堪舆`
- [x] 首次启动正常进入首页
- [x] 无崩溃、无白屏、无卡死

## 主路径

### 1. 罗盘页

- [x] 双盘正常显示
- [x] 刻度与方位正常
- [x] 设置页 `显示纳气盘` 开关返回罗盘页后能立即生效
- [ ] 其余罗盘参数回流仍待补测：样式、大小、透明度

### 2. 分析页

- [ ] 坐向与纳气页能正常计算
- [ ] 三元九运页能正常切换年份
- [ ] 飞星排盘页能正常展示九宫
- [ ] 流年运势页能正常展示结果
- [ ] 八宅风水页能正常出结果
- [x] 示例户型分析页可通过 app 内主线进入，并显示热力图、标记与分析结果

### 3. 户型图分析

- [x] 相册导入成功
- [x] 相机入口可正常拉起系统拍摄界面
- [ ] 立极点可移动
- [ ] 房间标记可新增和删除
- [x] 热力图可显示/隐藏
- [ ] 保存记录成功

### 4. 历史记录

- [ ] 记录列表显示正常
- [x] 详情页可打开
- [x] 备注可保存
- [x] 分享报告成功调起系统分享
- [x] 保存到相册成功，且系统授权后可落盘
- [x] 示例分享记录可自动生成并直达详情页

### 5. 设置页

- [ ] 可查看隐私政策
- [ ] 可查看使用条款
- [ ] 可查看支持说明
- [ ] 可导出本地备份
- [ ] 可恢复历史记录备份
- [x] 设置页基础参数可正常显示
- [x] 权限速览可通过 app 内主线直达并显示定位/方向/相机/相册状态

## 权限检查

- [x] 定位权限文案正常
- [x] 运动与方向权限文案正常
- [x] 相机权限文案正常
- [x] 相册权限文案正常

## 结果记录

- 是否通过：部分通过
- 发现问题：
  - 已确认 fresh install 后可正常进入总览首页
  - 已确认底部 5 个主入口存在，不再是单功能壳页面
  - 已补 smoke 辅助直达入口：
    - `tamegeomancy://tab/settings`
    - `tamegeomancy://analysis/floor-plan-demo`
    - `tamegeomancy://records/share-preview`
    - `tamegeomancy://settings/permissions`
  - 已补到 5 张最新页面级证据图：
    - `/private/tmp/tame-overview-no-permission.png`
    - `/private/tmp/tame-compass-demo-latest.png`
    - `/private/tmp/tame-settings-permissions-focus.png`
    - `/private/tmp/tame-analysis-floor-plan-argv.png`
    - `/private/tmp/tame-records-share-preview-fixed.png`
  - 已补到 1 张最新交互级证据图：
    - `/private/tmp/tame-floorplan-interactive-latest.png`
  - 本轮又补到 6 张交互级证据图：
    - `/private/tmp/tame-compass-settings-sync-off.png`
    - `/private/tmp/tame-compass-settings-sync-off-fixed.png`
    - `/private/tmp/tame-floorplan-camera-entry.png`
    - `/private/tmp/tame-floorplan-photo-import-success.png`
    - `/private/tmp/tame-record-save-to-photos-success.png`
    - `/private/tmp/tame-settings-photo-save-allowed.png`
  - 启动测试路由已验证：
    - `-TAMELaunchRoute tamegeomancy://analysis/floor-plan-demo`
    - `-TAMELaunchRoute tamegeomancy://records/share-preview`
  - App 内“权限与支持”主线已验证可进入设置页权限速览，不再依赖表单滚动去找权限区块
  - 已修复首页首启误触发罗盘传感器导致的定位弹窗遮挡问题；罗盘现在只会在真正切到罗盘 tab 时启动传感器
  - 已通过 app 内主线验证：
    - “分享报告预览”会自动生成演示记录并进入详情页
    - 备注修改后可再次进入详情并看到已保存内容
    - “分享报告”可正常调起系统分享面板
    - “示例户型分析”可从总览页直接进入并显示纳气口、热力图与房间标记
    - “显示纳气盘”关闭后，罗盘数据卡会同步变成“已隐藏”
    - “相册”可拉起系统照片选取器，选图后会回流分析页并自动生成九宫结果
    - “拍摄”可拉起系统测试相机界面
    - “保存到相册”会触发系统授权，允许后提示“报告图已保存到系统相册”
  - 当前仍缺坐向纳气实时计算、三元九运切年、飞星/流年/八宅逐页结果、本地备份导出恢复等完整交互点测
- 是否阻塞提审：暂不单独阻塞，但仍需继续补齐完整主路径点测

## 2026-05-08 最新复核结论

- 2026-05-08 22:54 已通过 Xcode GUI 把当前工程重新安装到 `iPhone 17 Pro (26.4.1)`，并确认模拟器不再运行旧包
- 最新 app container：
  - `/Users/pengpeng/Library/Developer/CoreSimulator/Devices/D943A272-7E86-4A7A-B6CA-6E3E9B8DB6D0/data/Containers/Bundle/Application/F49BF059-8FDB-4D5A-8603-3D641555A213/TAMEGeomancy.app`
- 最新包内信息：
  - `CFBundleDisplayName = 探觅·堪舆`
  - `CFBundleIdentifier = com.tame.geomancy`
  - `CFBundleShortVersionString = 1.0.0`
  - `CFBundleVersion = 1`
- 最新图标已替换为无水印原创白金罗盘几何图标，并已在 SpringBoard 显示
- 最新运行证据：
  - `/private/tmp/tamegeomancy-after-icon-run.png`
  - `/private/tmp/tamegeomancy-springboard-icon.png`
- 当前不能把本执行单标记为完整通过，因为最新 `release_gate` 仍未通过，且主路径逐页交互尚未全部重测
- 旧证据仍可作为功能路径参考，但提交前必须基于最新 build 重跑：
  - 首次安装与首页
  - 坐向纳气、三元九运、飞星、流年、八宅逐页结果
  - 户型立极点移动、房间标记新增/删除、保存记录
  - 记录列表、政策页、使用条款、支持页、本地备份导出/恢复
- 当前结论保持：`部分通过 / 需补齐完整主路径点测与 release gate`
