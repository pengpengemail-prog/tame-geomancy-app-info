# TAME Space Compass Preflight Report

更新时间：2026-06-05 01:16:46 +0800

## 总结论

- 总状态：`PASS`
- 当前显示名：`探觅·空间罗盘`
- 当前提交判断：`需补充验证后再提交`
- 当前提交判断仍应结合 `FINAL_EXECUTION_BOARD.md`

## 子项结果

| 项目 | 状态 | 说明 |
| --- | --- | --- |
| XcodeGen | PASS | 已按 `project.yml` 重新同步工程 |
| Xcode build | PASS | 详见 `.build-cache/preflight_build.log` |
| Readiness check | PASS | 详见下方摘录 |
| Screenshot manifest | PASS | 已生成 `AppStoreAssets/MANIFEST.md` |
| WebLegal dist | PASS | 已生成 `WebLegal/dist/` |
| Xcode / Simulator diagnostics | PASS | 详见 `.build-cache/xcode_simulator_diagnostics.md` |

## Xcode Build 摘录

### Error Lines

```text

```

### Tail

```text
Command line invocation:
    /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -project TAMEGeomancy.xcodeproj -scheme TAMEGeomancy -derivedDataPath /Users/pengpeng/Desktop/codex工作区/TAMEGeomancy/.DerivedData -destination "generic/platform=iOS Simulator" build

2026-06-05 01:16:41.065 xcodebuild[6598:4431474] [MT] IDERunDestination: Supported platforms for the buildables in the current scheme is empty.
ComputePackagePrebuildTargetDependencyGraph

Prepare packages

CreateBuildRequest

SendProjectDescription

CreateBuildOperation

ComputeTargetDependencyGraph
note: Building targets in dependency order
note: Target dependency graph (1 target)
    Target 'TAMEGeomancy' in project 'TAMEGeomancy' (no dependencies)

GatherProvisioningInputs

CreateBuildDescription

ClangStatCache /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang-stat-cache /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator26.5.sdk /Users/pengpeng/Desktop/codex工作区/TAMEGeomancy/.DerivedData/SDKStatCaches.noindex/iphonesimulator26.5-23F73-6cfe768891a92b912361537c460fe42b.sdkstatcache
    cd /Users/pengpeng/Desktop/codex工作区/TAMEGeomancy/TAMEGeomancy.xcodeproj
    /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang-stat-cache /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator26.5.sdk -o /Users/pengpeng/Desktop/codex工作区/TAMEGeomancy/.DerivedData/SDKStatCaches.noindex/iphonesimulator26.5-23F73-6cfe768891a92b912361537c460fe42b.sdkstatcache

** BUILD SUCCEEDED **
```

## Simulator 只读诊断

完整诊断报告：`.build-cache/xcode_simulator_diagnostics.md`

### Diagnostics Summary

```text
## Summary

| 命令 | 状态 |
| --- | --- |
| `xcodebuild -version` | PASS |
| `xcode-select -p` | PASS |
| `xcrun --find simctl` | PASS |
| `xcrun simctl list runtimes` | PASS |
| `xcrun simctl list devices available` | PASS |
| `xcrun simctl list devicetypes` | PASS |
| `xcrun simctl list pairs` | PASS |
```

### Runtimes

```text
== Runtimes ==
iOS 26.0 (26.0 - 23A343) - com.apple.CoreSimulator.SimRuntime.iOS-26-0
iOS 26.1 (26.1 - 23B86) - com.apple.CoreSimulator.SimRuntime.iOS-26-1
iOS 26.2 (26.2 - 23C54) - com.apple.CoreSimulator.SimRuntime.iOS-26-2
iOS 26.4 (26.4 - 23E244) - com.apple.CoreSimulator.SimRuntime.iOS-26-4
iOS 26.4 (26.4.1 - 23E254a) - com.apple.CoreSimulator.SimRuntime.iOS-26-4
iOS 26.5 (26.5 - 23F77) - com.apple.CoreSimulator.SimRuntime.iOS-26-5
```

### Available Devices

```text
== Devices ==
-- iOS 26.0 --
    iPhone 17 Pro (08DD03E6-C21C-4E6D-9902-F8A182DB32B1) (Shutdown) 
    iPhone 17 Pro Max (7D16284E-C57C-4E6A-B43D-FF450CF5501E) (Shutdown) 
    iPhone Air (CB13FF21-5F61-431C-8548-F89BE84BEED9) (Shutdown) 
    iPhone 17 (32AEA722-6992-4934-9CB3-F29F9A9152A6) (Shutdown) 
    iPhone 16e (DE3F5A03-613B-4881-89CF-D3C3EF271C9C) (Shutdown) 
    iPad Pro 13-inch (M5) (6EBF47E1-C648-4B99-820A-58965AF88359) (Shutdown) 
    iPad Pro 11-inch (M5) (D6957D95-D34D-4787-BAF4-E0F266F9AF0D) (Shutdown) 
    iPad mini (A17 Pro) (B0604545-FA9A-470B-9266-ACC923269ADB) (Shutdown) 
    iPad (A16) (8D29E655-969A-413C-9507-4CF30A83B423) (Shutdown) 
    iPad Air 13-inch (M3) (EE120DF2-6D26-4C27-9DD5-8FAA52A6659B) (Shutdown) 
    iPad Air 11-inch (M3) (C0E19621-AADA-4310-A23B-AF398E4EC9DD) (Shutdown) 
-- iOS 26.1 --
    iPhone 17 Pro (34DAE67E-CAF2-4D68-BAB2-5B7404AE1B6C) (Shutdown) 
    iPhone 17 Pro Max (4C444341-A3CC-4499-968F-106EF22004DC) (Shutdown) 
    iPhone Air (7E4A79FE-36AA-44B9-888A-B6587293D7EB) (Shutdown) 
    iPhone 17 (A16A7204-2C1B-47B0-9697-34367D872ADA) (Shutdown) 
    iPhone 16e (34DE2512-B363-4E1B-9D3F-F90FE2F14D3F) (Shutdown) 
    iPad Pro 13-inch (M5) (94E42F53-34AA-471C-BEE7-88354F8CE44E) (Shutdown) 
    iPad Pro 11-inch (M5) (3B60E5FC-2451-428C-8751-E537D29CF1B8) (Shutdown) 
    iPad mini (A17 Pro) (4D09F943-F4F6-41D0-B3EE-CABBE9BB07D7) (Shutdown) 
    iPad (A16) (8FB59093-075B-48F9-9C3E-37BE269FB4F8) (Shutdown) 
    iPad Air 13-inch (M3) (B4B42413-34AC-4FA6-B9EB-28CB56EFDE8E) (Shutdown) 
    iPad Air 11-inch (M3) (5880082F-110C-4EF1-AF9D-817E074936F3) (Shutdown) 
-- iOS 26.2 --
    iPhone 17 Pro (762DCCF1-FA81-4C21-8E81-384F3A6458A0) (Shutdown) 
    iPhone 17 Pro Max (B006E861-64C2-4C0C-9DA6-C6A876502B2B) (Booted) 
    SnapSweep QA iPhone 17 Pro Max Clean 20260604 (D61D95CA-E2C6-463C-8850-14C57EC3B35E) (Booted) 
    iPhone Air (9C2BD22B-D5D8-492C-BEC5-6F070B5ABE34) (Shutdown) 
    iPhone 17 (D81353D8-96D1-436B-A8E2-E1258BC8DABC) (Shutdown) 
    iPhone 16e (2555C413-5C05-44F2-AF0E-7655E856D901) (Shutdown) 
    iPad Pro 13-inch (M5) (7AEF464B-463B-4052-8429-DB9A6DD2DF6D) (Shutdown) 
    iPad Pro 11-inch (M5) (870D8EF3-6D2F-4252-8501-BAF16B12C9A9) (Shutdown) 
    iPad mini (A17 Pro) (A0F941F0-A680-4D82-B996-F52B4D58CF67) (Shutdown) 
    iPad (A16) (D479A7B7-490E-440D-9366-9C778657824D) (Shutdown) 
    iPad Air 13-inch (M3) (700F2E70-9308-46F8-B75F-D4F15B849C35) (Shutdown) 
    iPad Air 11-inch (M3) (8CBCD7F8-CD1B-458A-A847-ECAD6F4FF5AE) (Booted) 
    SnapSweep QA iPad Air 11 Clean Universal 20260604 (86D4AA7D-CD0F-485C-9572-6F5DA1E2DC53) (Shutdown) 
-- iOS 26.4 --
-- iOS 26.4 --
    iPhone 17 Pro (D943A272-7E86-4A7A-B6CA-6E3E9B8DB6D0) (Shutdown) 
    iPhone 17 Pro Max (AF128287-53BF-4496-BB2D-E95FE7DDEA55) (Shutdown) 
    iPhone 17e (E4D984F5-991A-4C6C-ABF1-1CE8CEC17ECB) (Shutdown) 
    iPhone Air (827D2C60-DDB8-4B88-AF5A-48EBC1DD28CB) (Shutdown) 
    iPhone 17 (39FF3514-CA15-4B63-884E-DC26A3860C24) (Shutdown) 
    iPad Pro 13-inch (M5) (E8DB21BD-8ED8-497D-9DE9-C48D2E5CE2C6) (Shutdown) 
    iPad Pro 11-inch (M5) (C0959C91-B47E-4F61-8652-E224690BC95B) (Shutdown) 
    iPad mini (A17 Pro) (97EF0E25-B2F2-44F0-84EE-DE5089E0EF6D) (Shutdown) 
    iPad Air 13-inch (M4) (9683CA9E-8398-4CC9-928E-0C4163852449) (Shutdown) 
    iPad Air 11-inch (M4) (29D8011A-74AB-4375-A973-DF13EEA6217F) (Shutdown) 
    iPad (A16) (277DC448-9301-4216-AD7A-CA30D5C8104B) (Shutdown) 
-- iOS 26.5 --
    iPhone 17 Pro (5C503B9B-D8D9-4400-AF39-B11A79C1091F) (Booted) 
    iPhone 17 Pro Max (83A17141-D24B-4F08-87D0-E432D647BA5E) (Shutdown) 
    LumaBazi Fresh iPhone 17 Pro Max 20260605 (AABFB598-BA0C-433C-ADF3-1001D0B4C353) (Booted) 
    iPhone 17e (363957E4-A152-4AF4-8F89-3054E85ADD6D) (Shutdown) 
    iPhone Air (218D2E8C-1747-4023-9C48-152E9D60E7FA) (Shutdown) 
    iPhone 17 (B49E341F-EBEB-4236-A3FA-AADF61BA44A0) (Shutdown) 
    iPad Pro 13-inch (M5) (D4A41A7C-AB68-49E0-BCAA-ADB16DA4A7E0) (Shutdown) 
    iPad Pro 11-inch (M5) (CA3726FF-2AF6-46FC-B248-95F6897E1F21) (Shutdown) 
    iPad mini (A17 Pro) (D1752C8A-A82F-4E8C-B872-F5407EE1528D) (Shutdown) 
    iPad Air 13-inch (M4) (386D1E68-B911-45A8-A8CA-CC0C19536A64) (Shutdown) 
    iPad Air 11-inch (M4) (A5F61CD8-4685-49CA-851E-8A77A0C3B37E) (Shutdown) 
    iPad (A16) (D4E76ED3-4CD5-4674-AEF2-164EBB193CC9) (Shutdown) 
```

## Readiness Check 摘录

```text
[OK] 文件存在: WebLegal/privacy-policy.html
[OK] 文件存在: WebLegal/terms-of-use.html
[OK] 文件存在: TAMEGeomancy.storekit
[OK] WebLegal dist 已同步构建
[OK] 文件存在: WebLegal/dist/index.html
[OK] 文件存在: WebLegal/dist/support.html
[OK] 文件存在: WebLegal/dist/privacy-policy.html
[OK] 文件存在: WebLegal/dist/terms-of-use.html
[OK] Info.plist 显示名为 探觅·空间罗盘
[OK] project.yml 显示名配置为 探觅·空间罗盘
[OK] project.yml 已收口为 iPhone 设备族
[OK] project.yml 已关闭 Mac Designed for iPhone/iPad
[OK] project.yml 已关闭 XR Designed for iPhone/iPad
[OK] project.yml 已绑定 StoreKit 配置
[OK] Xcode 工程已同步关闭 Mac Designed for iPhone/iPad
[OK] Xcode 工程已同步关闭 XR Designed for iPhone/iPad
[OK] 审核备注包含中文对外名称
[OK] 审核备注包含英文对外名称
[OK] 未发现不应出现的内容: 公开法务、支持与审核备注仍暴露内部工程名
[OK] 未发现不应出现的内容: 公开法务与支持页占位域名/邮箱
[OK] 未发现不应出现的内容: 公开法务与支持文档仍处于上线前占位状态
[OK] 未发现不应出现的内容: 应用内 reviewer 可见页面仍含上线前占位文案
[OK] StoreKit 配置 JSON 有效
[OK] StoreKit 终身解锁 Product ID 已配置
[OK] StoreKit 终身解锁价格基准已配置
[OK] StoreKit 终身解锁类型为非消耗型
[OK] 未发现不应出现的内容: StoreKit 不应再包含周期扣费项目
[OK] 未发现不应出现的内容: 解锁与商店文案仍承诺未来高级能力
[OK] README 已引用主执行总表
[OK] zh-Hans 截图目录 已有素材文件: 6
[OK] en-US 截图目录 已有素材文件: 6
[WARN] review-only 素材目录 目录尚无实际截图素材: AppStoreAssets/review-only
== Checking zh-Hans ==
[OK] 01-dual-compass.png -> 1284x2778, alpha=no
[OK] 02-opening-reference.png -> 1284x2778, alpha=no
[OK] 03-flying-star.png -> 1284x2778, alpha=no
[OK] 04-floor-plan-heatmap.png -> 1284x2778, alpha=no
[OK] 05-bazhai.png -> 1284x2778, alpha=no
[OK] 06-record-share.png -> 1284x2778, alpha=no
[OK] zh-Hans 尺寸一致: 1284x2778

== Checking en-US ==
[OK] 01-dual-compass.png -> 1284x2778, alpha=no
[OK] 02-opening-reference.png -> 1284x2778, alpha=no
[OK] 03-flying-star.png -> 1284x2778, alpha=no
[OK] 04-floor-plan-heatmap.png -> 1284x2778, alpha=no
[OK] 05-bazhai.png -> 1284x2778, alpha=no
[OK] 06-record-share.png -> 1284x2778, alpha=no
[OK] en-US 尺寸一致: 1284x2778

== Checking review-only ==
[OK] review-only 未混用公开截图文件名
[WARN] review-only 目录当前无审核辅助素材

Screenshot Validation: PASS
[OK] 截图校验通过
[OK] 截图 manifest 已生成
[OK] Swift 源码 parse 级体检通过

Readiness Check: PASS
```

## 外部 blocker 仍待核销

1. fresh install / smoke test
2. App Store Connect 当前版本状态核对
3. 真实 Support / Privacy / Terms 链接上线并回填
4. App Store Connect 截图上传后的在线预览核对
5. 本机 Xcode build / Simulator 服务链路恢复后重新构建

## 下一步

1. 若 `Xcode build` 为 FAIL，先处理 `.build-cache/preflight_build.log` 中的构建 / Simulator 服务错误
2. 完成 `SMOKE_TEST_RUNBOOK.md`
3. 完成 `SubmissionKit/02_ASC_Live_Checklist.md`
4. 在 App Store Connect 上传截图后核对在线预览
5. 在 `BLOCKER_CLEARANCE_LOG.md` 中逐项核销
