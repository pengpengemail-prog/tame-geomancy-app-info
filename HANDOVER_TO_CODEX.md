# TAMEGeomancy 交接文档

## 项目位置

- 工作目录：`~/Desktop/codex工作区/TAMEGeomancy/`
- 品牌规则：`~/Desktop/codex工作区/TAME_APP_BRAND_RULES.md`

## 品牌约束

- 本项目正式名称为 `TAME·Geomancy`（中文：`探觅·堪舆`）
- 桌面显示名使用 `探觅·堪舆`
- 应用内 logo / 字标使用正式锁定组 `TAME·Geomancy / 探觅·堪舆`
- 如后续整理 App Store 名称、截图、审核备注，需要保持上述三者一致

## 当前状态

- 已具备完整主流程
- 历史记录已支持详情、备注、报告卡、系统分享
- 户型图分析已支持立极点、标记、热力图、完整保存
- 当前环境下不能把“本地构建已通过”或“可上机实测”记为已核销

## 已完成重点

### 1. 双盘罗盘

- `CompassDiskView.swift`
- `CompassView.swift`

完成内容：
- 地盘 + 纳气盘双盘
- 纳气盘 7.5° 固定偏移
- 二十四山 / 八卦 / 刻度 / 水平仪 / 干扰提示

### 2. 八宅风水

- `BazhaiView.swift`
- `BazhaiViewModel.swift`

完成内容：
- 宅卦
- 东四宅 / 西四宅
- 八方位分配
- 命卦匹配与房间建议

### 3. 户型图分析

- `FloorPlanAnalysisView.swift`
- `FloorPlanAnalysisViewModel.swift`

完成内容：
- 图片导入
- 立极点调整
- 房间标记
- 九宫分析
- 热力图叠加
- 记录保存

### 4. 记录模块

- `HistoryStore.swift`
- `RecordsView.swift`
- `RecordDetailView.swift`
- `RecordShareSupport.swift`

完成内容：
- 本地历史记录
- 备注编辑
- 详情查看
- TAME·Geomancy 风格报告分享

## 当前剩余事项

### 高优先级

1. 补更多单元测试
2. 在可用模拟器环境做交互 smoke test
3. 整理 App Store 文案、截图、审核说明

### 中优先级

1. 清理剩余旧状态文档与说明文本
2. 进一步优化部分页面的视觉统一性

## 构建命令

```bash
cd ~/Desktop/codex工作区/TAMEGeomancy
xcodegen -s project.yml -p . -r .

CLANG_MODULE_CACHE_PATH=$PWD/.build-cache/module-cache \
SWIFT_MODULE_CACHE_PATH=$PWD/.build-cache/module-cache \
xcodebuild -project TAMEGeomancy.xcodeproj \
  -scheme TAMEGeomancy \
  -derivedDataPath $PWD/.DerivedData \
  -destination "generic/platform=iOS Simulator" build
```

## 已知限制

- 当前环境中 `xcodebuild build` 与 `xcodebuild test` 都可能因 `CoreSimulatorService / ibtoold / actool` 链路异常失败
- 这说明本机构建与模拟器环境仍有 blocker，不能把命令行构建结果记为通过

## 推荐继续入口

- 先看 [TODO.md](TODO.md) 做核销
- 再看 [DEVELOPMENT_STATUS.md](DEVELOPMENT_STATUS.md) 了解当前剩余工作
