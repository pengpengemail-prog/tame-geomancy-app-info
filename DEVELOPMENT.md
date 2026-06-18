# 开发指南

> TAMEGeomancy 项目开发流程与规范

## 🚀 开发环境设置

### 必需工具

```bash
# 1. 安装 XcodeGen
brew install xcodegen

# 2. 验证安装
xcodegen --version  # 应显示 2.38+
```

### 项目初始化

```bash
# 进入项目目录
cd ~/Desktop/codex工作区/TAMEGeomancy

# 生成 Xcode 项目
xcodegen generate

# 打开项目
open TAMEGeomancy.xcodeproj
```

## 📁 项目结构说明

### Models（数据模型层）

**职责**: 定义数据结构和业务实体

```
Models/
├── Direction.swift          # 方位枚举（东南西北等）
└── FengShuiModels.swift     # 风水核心模型
    ├── Bagua               # 八卦
    ├── Palace              # 九宫
    ├── FlyingStar          # 飞星
    ├── Period              # 三元九运
    └── StarStatus          # 星曜状态
```

**规范**:
- 使用 `struct` 定义值类型
- 使用 `enum` 定义枚举类型
- 实现 `Codable` 支持序列化
- 添加中文名称属性

### Services（服务层）

**职责**: 实现业务逻辑和算法

```
Services/
├── FlyingStarCalculator.swift  # 玄空飞星排盘算法
└── NaqiAnalyzer.swift          # 纳气口吉凶分析
```

**规范**:
- 纯函数式设计，无副作用
- 输入输出明确
- 添加详细注释说明算法原理
- 编写单元测试

### ViewModels（视图模型层）

**职责**: 连接视图和业务逻辑，管理状态

```
ViewModels/
├── CompassViewModel.swift              # 罗盘逻辑
├── FloorPlanAnalysisViewModel.swift    # 户型图分析
├── AnnualFortuneViewModel.swift        # 流年运势
└── BazhaiViewModel.swift               # 八宅风水
```

**规范**:
- 继承 `ObservableObject`
- 使用 `@Published` 标记状态属性
- 业务逻辑调用 Services 层
- 不直接操作 UI

### Views（视图层）

**职责**: UI 展示和用户交互

```
Views/
├── ContentView.swift               # 主界面（TabView）
├── CompassView.swift               # 罗盘视图
├── CompassDiskView.swift           # 罗盘双盘（地盘+纳气盘）
├── FloorPlanAnalysisView.swift     # 户型图分析
├── AnnualFortuneView.swift         # 流年运势
├── BazhaiView.swift                # 八宅风水
├── RecordsView.swift               # 记录
└── SettingsView.swift              # 设置
```

**规范**:
- 使用 SwiftUI 声明式语法
- 拆分子视图，保持单一职责
- 使用 `@StateObject` 持有 ViewModel
- 遵循极简高端设计风格

## 🎨 设计规范

### TAME·Geomancy VI 总则

- 全站默认风格统一为 `暖白底 + 深墨黑 + 哑光香槟金`
- 视觉关键词：`极简`、`精密`、`克制`、`留白`、`高级工具感`
- 主视觉隐喻统一为：`罗盘 / 轴心 / 细环 / 五行短弧`
- 页面避免“功能面板堆叠感”，优先目录卡、仪器卡、摘要卡
- 金色只用于少量强调，不做大面积渐变或装饰块
- 线条优先细、轻、少，卡片边框优先低对比
- 标题使用轻量编号 + 低噪音排版，避免厚重大字标题堆叠
- 底部导航、徽章、入口卡、摘要块必须保持同一套圆角与阴影语言
- App Store 副标题、关键词、宣传文案、商店页面、截图标题、审核备注与外部支持页文案，必须统一服从最新总规则，不允许脱离当前 VI 与合规口径单独编写
- 上架文案执行关键词：`白底极简`、`专业工具感`、`民俗文化参考`、`克制表达`、`不夸张承诺`
- 元数据与商店页面不得出现与应用内风格冲突的强营销语气、夸张承诺、恐吓式表达、廉价促销感或与当前产品定位不一致的色彩/文案方向

### 色彩系统

```swift
// 主色调
Color.white              // 背景主色
Color(red: 13/255, green: 17/255, blue: 23/255)  // 主文字
Color(red: 189/255, green: 160/255, blue: 106/255) // 香槟金强调

// 辅助色（柔和、低噪音）
Color(red: 253/255, green: 252/255, blue: 251/255) // 暖白底
Color(red: 13/255, green: 17/255, blue: 23/255).opacity(0.04) // 幽灵辅助线
Color(red: 13/255, green: 17/255, blue: 23/255).opacity(0.68) // 次级文字

// 功能色
Color(red: 190/255, green: 108/255, blue: 86/255) // 注意/提醒
```

### 字体系统

```swift
// 标题
.font(.system(size: 26, weight: .medium, design: .rounded))
.font(.system(size: 22, weight: .medium, design: .rounded))

// 正文
.font(.system(size: 15, weight: .regular, design: .rounded))
.font(.system(size: 13, weight: .regular, design: .rounded))

// 辅助
.font(.system(size: 12, weight: .regular, design: .rounded))
.font(.system(size: 11, weight: .medium, design: .rounded))
```

### 布局原则

1. **大量留白**: 首屏与区块间距保持 20pt 以上
2. **轻边框卡片**: 优先使用极细描边 + 轻阴影，不做厚重面板
3. **少而稳**: 每屏只保留 1 个主视觉焦点 + 2 到 4 个次级块
4. **目录化**: 尽量把功能入口做成目录卡，而不是仪表盘堆格
5. **统一圆角**: 卡片圆角偏大且一致，避免每屏不同风格
6. **低噪音图标**: 图标保持线性、克制、比例统一

### 示例代码

```swift
VStack(spacing: 24) {  // 大间距
    Text("标题")
        .font(.system(size: 22, weight: .medium, design: .rounded))
        .foregroundColor(Color(red: 13/255, green: 17/255, blue: 23/255))
    
    VStack(spacing: 12) {
        // 内容
    }
    .padding()
    .background(Color.white)
    .overlay {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .stroke(Color(red: 13/255, green: 17/255, blue: 23/255).opacity(0.08), lineWidth: 1)
    }
    .cornerRadius(18)
}
.padding()
```

## 🔧 开发工作流

### 1. 开始新功能

```bash
# 1. 查看任务清单
cat TODO.md

# 2. 创建功能分支（可选）
git checkout -b feature/功能名称

# 3. 开始开发
```

### 2. 编码规范

**Swift 代码风格**:
```swift
// ✅ 好的命名
func calculateFlyingStars(period: Int, direction: Direction) -> [Palace: FlyingStar]

// ❌ 不好的命名
func calc(p: Int, d: Direction) -> [Palace: FlyingStar]

// ✅ 清晰的注释
/// 计算指定运期和坐向的玄空飞星盘
/// - Parameters:
///   - period: 三元九运的运期（1-9）
///   - direction: 房屋坐向
/// - Returns: 九宫飞星分布字典
func calculateFlyingStars(period: Int, direction: Direction) -> [Palace: FlyingStar]
```

**SwiftUI 视图拆分**:
```swift
// ✅ 拆分子视图
struct MainView: View {
    var body: some View {
        VStack {
            headerSection
            contentSection
            footerSection
        }
    }
    
    private var headerSection: some View {
        // ...
    }
}

// ❌ 单一巨大视图
struct MainView: View {
    var body: some View {
        VStack {
            // 200 行代码...
        }
    }
}
```

### 3. 测试

```bash
# 运行单元测试
xcodebuild test -scheme TAMEGeomancy -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# 或在 Xcode 中
# Product -> Test (Cmd+U)
```

### 4. 构建验证

```bash
# 清理构建
xcodegen generate
rm -rf ~/Library/Developer/Xcode/DerivedData/TAMEGeomancy-*

# 重新构建
xcodebuild -scheme TAMEGeomancy -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

### 5. 提交代码

```bash
git add .
git commit -m "feat: 添加XXX功能

- 实现了XXX
- 修复了XXX
- 优化了XXX"
```

## 🐛 调试技巧

### 1. 打印调试

```swift
// 使用 print 查看数据
print("当前方位: \(heading)")

// 使用 dump 查看完整结构
dump(flyingStars)
```

### 2. 断点调试

- 在 Xcode 中点击行号设置断点
- 运行时会在断点处暂停
- 使用 `po` 命令查看变量值

### 3. SwiftUI 预览

```swift
#Preview {
    CompassView()
}
```

### 4. 常见问题

**问题**: ForEach 编译错误
```swift
// ❌ 错误
ForEach(0..<24) { index in
    Text("\(index)")
}

// ✅ 正确
ForEach(0..<24, id: \.self) { index in
    Text("\(index)")
}
```

**问题**: ViewModel 不更新视图
```swift
// ❌ 错误
class MyViewModel {
    var data: String = ""
}

// ✅ 正确
class MyViewModel: ObservableObject {
    @Published var data: String = ""
}
```

## 📦 依赖管理

本项目**不使用外部依赖**，完全基于 iOS 原生框架：

- SwiftUI - UI 框架
- CoreLocation - 定位
- CoreMotion - 传感器
- Foundation - 基础库

## 🔄 XcodeGen 使用

### project.yml 结构

```yaml
name: TAMEGeomancy
options:
  bundleIdPrefix: com.pengpeng
targets:
  TAMEGeomancy:
    type: application
    platform: iOS
    deploymentTarget: "17.0"
    sources:
      - TAMEGeomancy
    settings:
      PRODUCT_BUNDLE_IDENTIFIER: com.pengpeng.TAMEGeomancy
```

### 常用命令

```bash
# 生成项目
xcodegen generate

# 指定配置文件
xcodegen generate --spec project.yml

# 查看帮助
xcodegen --help
```

## 📝 提交规范

### Commit Message 格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type 类型**:
- `feat`: 新功能
- `fix`: 修复 bug
- `docs`: 文档更新
- `style`: 代码格式（不影响功能）
- `refactor`: 重构
- `test`: 测试相关
- `chore`: 构建/工具相关

**示例**:
```
feat(compass): 添加罗盘双盘视图

- 实现地盘24山显示
- 实现纳气盘8卦方位
- 添加指南针指针动画
- 修复 ForEach id 参数问题

Closes #123
```

## 🎯 下一步开发建议

1. **启用罗盘双盘视图**（30分钟）
   - 文件: `CompassDiskView.swift`
   - 操作: 删除占位代码，取消注释

2. **修复八宅风水模块**（2-3小时）
   - 文件: `BazhaiView.swift`, `BazhaiViewModel.swift`
   - 操作: 重构数据模型，实现算法

3. **UI 优化**（4-6小时）
   - 应用极简高端设计风格
   - 统一色彩和字体

4. **补充测试**（2-3小时）
   - 为新模块编写单元测试
   - 提高测试覆盖率

详见 [TODO.md](TODO.md) 和 [HANDOVER_TO_CODEX.md](HANDOVER_TO_CODEX.md)

---

**有问题？** 查看 [DEVELOPMENT_STATUS.md](DEVELOPMENT_STATUS.md) 了解当前状态和已知问题。
