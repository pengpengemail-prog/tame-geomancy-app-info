# TAMEGeomancy · 探觅·堪舆

> 正式产品名为 `TAME·Geomancy / 探觅·堪舆`，桌面显示名为 `探觅·堪舆`
>
> 全局视觉基线：`暖白底 + 深墨黑 + 香槟金`，极简、精密、克制、留白。
>
> App Store 副标题、关键词、宣传文案、商店页面、截图标题与审核资料，统一按最新项目总规则执行，不单独走偏营销口径。

## 项目概览

`TAMEGeomancy` 是一款离线运行的 iOS 堪舆工具，围绕双盘罗盘、纳气分析、三元九运、玄空飞星、流年运势、户型九宫与八宅匹配展开，面向风水爱好者、设计师与业主使用。

当前版本已经具备完整主流程代码与本地资料基础，支持保存记录与生成 TAME·Geomancy 风格的参考报告卡进行系统分享；但当前环境下仍不能把“本地构建已通过”或“可直接上机实测”记为已核销。

## 当前能力

- 双盘罗盘：地盘正针 + 纳气盘，固定 7.5° 偏移
- 坐向与纳气分析：支持大门、阳台、窗户等纳气口判断
- 三元九运：七运、八运、九运自动识别与手动分析
- 玄空飞星：运盘、山盘、向盘、流年盘展示
- 流年运势：逐年参考与九宫变化
- 户型图分析：图片导入、立极点、房间标记、热力图叠加、九宫总结
- 八宅风水：宅卦、东四西四宅、命卦匹配、房间建议
- 历史记录：保存、备注编辑、详情查看、报告分享

## 运行要求

- macOS 13.0+
- Xcode 15.0+
- iOS 15.0+
- XcodeGen 2.38+

## 快速开始

```bash
cd ~/Desktop/codex工作区/TAMEGeomancy
xcodegen -s project.yml -p . -r .
open TAMEGeomancy.xcodeproj
```

命令行可使用以下方式验证构建：

```bash
CLANG_MODULE_CACHE_PATH=$PWD/.build-cache/module-cache \
SWIFT_MODULE_CACHE_PATH=$PWD/.build-cache/module-cache \
xcodebuild -project TAMEGeomancy.xcodeproj \
  -scheme TAMEGeomancy \
  -derivedDataPath $PWD/.DerivedData \
  -destination "generic/platform=iOS Simulator" build
```

## 文档入口

- [FINAL_EXECUTION_BOARD.md](FINAL_EXECUTION_BOARD.md)：最终执行总表与核销主入口
- [TODO.md](TODO.md)：任务清单与核销基线
- [DEVELOPMENT.md](DEVELOPMENT.md)：开发流程与代码规范
- [DEVELOPMENT_STATUS.md](DEVELOPMENT_STATUS.md)：当前开发状态
- [YANGGONG_FENJIN_2_0_PRODUCT_PLAN.md](YANGGONG_FENJIN_2_0_PRODUCT_PLAN.md)：2.0 杨公分金立向产品方案
- [HANDOVER_TO_CODEX.md](HANDOVER_TO_CODEX.md)：交接说明与已知限制
- [ALGORITHM_SPEC.md](ALGORITHM_SPEC.md)：算法说明文档
- [APPSTORE_METADATA.md](APPSTORE_METADATA.md)：App Store 文案
- [APPSTORE_SCREENSHOT_COPY.md](APPSTORE_SCREENSHOT_COPY.md)：截图标题方案
- [APP_REVIEW_NOTES.md](APP_REVIEW_NOTES.md)：审核备注
- [APPSTORE_REVIEW_AUDIT.md](APPSTORE_REVIEW_AUDIT.md)：本地审核结论
- [REVIEW_AVOIDANCE_GUIDE.md](REVIEW_AVOIDANCE_GUIDE.md)：审核规避指南
- [PRIVACY_POLICY.md](PRIVACY_POLICY.md)：隐私政策草稿
- [TERMS_OF_USE.md](TERMS_OF_USE.md)：使用条款草稿
- [SUPPORT.md](SUPPORT.md)：支持页草稿
- [SCREENSHOT_DELIVERY_CHECKLIST.md](SCREENSHOT_DELIVERY_CHECKLIST.md)：截图交付清单
- [FINAL_SUBMISSION_CHECKLIST.md](FINAL_SUBMISSION_CHECKLIST.md)：提审前最终检查清单
- [SubmissionKit/README.md](SubmissionKit/README.md)：本地提交包目录
- [WebLegal/README.md](WebLegal/README.md)：可托管的外部支持/隐私/条款网页模板
- [AppStoreAssets/README.md](AppStoreAssets/README.md)：截图素材目录骨架
- [SMOKE_TEST_RUNBOOK.md](SMOKE_TEST_RUNBOOK.md)：fresh install / smoke test 执行单
- [BLOCKER_CLEARANCE_LOG.md](BLOCKER_CLEARANCE_LOG.md)：最终 blocker 清零日志

## 辅助脚本

- `./scripts/readiness_check.sh`：本地总自检
- `./scripts/validate_appstore_screenshots.sh`：截图目录、文件名、格式、alpha、尺寸校验
- `./scripts/configure_weblegal.sh`：批量替换 `WebLegal` 与法务文档中的真实域名、邮箱与公开链接

## 当前状态

- 构建状态：最新一轮 `xcodebuild` 受 `CoreSimulatorService / ibtoold / actool` 环境链路阻塞，当前不能核销为通过
- 核心流程：已打通
- 测试状态：已有基础算法测试与部分户型分析测试
- 已知限制：当前环境下 `xcodebuild test` 仍可能受 `CoreSimulatorService` 限制
- 提审结论：`需补充验证后再提交`

提审前请优先查看 [FINAL_EXECUTION_BOARD.md](FINAL_EXECUTION_BOARD.md)，其余文档均围绕该总表执行。

## 合规说明

- 本 App 仅为民俗文化参考工具，非科学依据
- 不涉及算命、改运、治病、财富承诺等违规表达
- 所有数据本地处理，不上传用户内容
