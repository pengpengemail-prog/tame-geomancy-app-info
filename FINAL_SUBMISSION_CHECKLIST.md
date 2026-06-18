# TAME Space Compass 提审前最终检查清单

> Monetization note: current TAMEGeomancy submissions must use the lifetime non-consumable IAP `com.tame.geomancy.premium.lifetime`.

更新时间：2026-06-05 01:12 +0800

当前结论：`已提交，等待审核`

## 一、构建与安装

- [x] `./scripts/release_gate.sh` 自动门禁通过；最终状态以 ASC/MCP `WAITING_FOR_REVIEW` 回读为准
- [x] 本地最新代码已重新 `xcodegen`（见 `SubmissionKit/PREFLIGHT_REPORT.md`）
- [x] 本地 `xcodebuild build` 成功（见 `SubmissionKit/PREFLIGHT_REPORT.md`）
- [x] 当前 App Store Connect 已绑定上传 build `6`
- [x] 既有 fresh install 证据保留；当前会话未重新上机
- [x] 当前会话未发现会阻止已提交版本排队的运行态 blocker

当前证据：
- 2026-05-24 `readiness_check.sh`：PASS
- 2026-05-24 `preflight_audit.sh`：PASS
- 2026-05-24 `cc-director-v3` 中英营销截图已生成、替换正式上传目录，并通过图片校验
- 2026-05-24 Release archive 尝试卡在 `codesign` 超过 2 分钟后中断，需解锁本机签名/钥匙串链路后重跑
- 2026-05-25 `readiness_check.sh`：PASS
- 2026-05-25 `ios-validate PremiumUnlockView.swift`：PASS，剩余 2 个非阻塞 warning
- 2026-05-25 ASC API 回读当前审核版本绑定 build `4`，`processingState=VALID`，`usesNonExemptEncryption=false`
- 2026-05-25 用户撤回后，先通过 ASC API 将 Guideline 4.3(b) 官方回复写入 Review Notes 并读回确认，再重新提交审核
- 2026-05-25 08:54 +0800 live API 二次回读确认：版本 `1.0` 仍为 `WAITING_FOR_REVIEW`，build `4` 仍为 `VALID`
- 2026-06-05 01:10 +0800 ASC API / MCP 回读确认：版本 `1.0` 为 `WAITING_FOR_REVIEW`，build `6` 为 `VALID`，`usesNonExemptEncryption=false`
- 2026-06-05 新版 `mature-commerce-r3` 中英截图已上传到 ASC，zh-Hans / en-US 各 6 张均 `COMPLETE`

## 二、关键功能路径

- [x] 罗盘页可正常显示双盘（历史 smoke / 当前提交未阻断）
- [x] 坐向与开口参考页可正常计算（历史 smoke / 当前提交未阻断）
- [x] 九宫布局页可正常切换年份与坐向（历史 smoke / 当前提交未阻断）
- [x] 户型图分析可导入图片（历史 smoke / 当前提交未阻断）
- [x] 户型分析可设置立极点与房间标记（历史 smoke / 当前提交未阻断）
- [x] 历史记录可保存、查看、分享（历史 smoke / 当前提交未阻断）
- [x] 设置页可看到说明、隐私与支持信息（历史 smoke / 当前提交未阻断）
- [x] 高级解锁页可看到 Restore Purchases（审核备注与 StoreKit / IAP 回读一致）

## 三、权限路径

- [x] 定位权限说明与实际用途一致（历史 smoke / 当前提交未阻断）
- [x] 运动与方向权限说明与实际用途一致（历史 smoke / 当前提交未阻断）
- [x] 相机权限说明与实际用途一致（历史 smoke / 当前提交未阻断）
- [x] 相册读取权限说明与实际用途一致（历史 smoke / 当前提交未阻断）
- [x] 相册添加权限说明与实际用途一致（历史 smoke / 当前提交未阻断）

## 四、合规检查

- [x] 所有页面仍保留“空间参考 / 文化参考”表达
- [x] 本地营销材料风险词扫描通过
- [x] 无专业建议、个人结果判断或结果承诺的对外定位
- [x] 品牌说明保持一致：桌面显示名是 `探觅·空间罗盘`，应用内正式字标是 `TAME Space Compass / 探觅·空间罗盘`

## 五、App Store Connect

- [x] 当前版本状态已核对：`WAITING_FOR_REVIEW`
- [x] 正确选择最新构建：build `6`
- [x] 当前付费模型已切换为 lifetime non-consumable IAP：`com.tame.geomancy.premium.lifetime`
- [x] 历史 recurring-plan 证据仅作为旧审核背景，不再作为未来提交目标
- [x] 当前价格计划以一次性解锁商品为准，不再排程 recurring billing 价格变更
- [x] `Support URL` 已填写到 ASC 并在线预览可访问
- [x] `Privacy Policy URL` 已填写到 ASC 并在线预览可访问
- [x] `Terms of Use URL` / Apple Standard EULA 已在线验证可访问
- [x] 审核备注已填入品牌说明与体验路径

当前阻断：
- 无当前 API 阻断。MCP 仍因 issuer 模式返回 401，但本地 ASC API 脚本使用个人 key `sub=user` 已完成状态读取、截图/文案核验与提交。
- 已提交的 reviewSubmission：`905bf4ff-d287-404f-8326-2407735d0ea8`
- Apple submittedDate：`2026-06-04T17:10:19.061Z`（北京时间 2026-06-05 01:10:19）
- Review Notes 读回证据：`.build-cache/asc-live-audit/review-notes-readback-before-resubmit.json`
- 最终提交证据：`.build-cache/asc-live-audit/resubmit-905-current-after-r3-20260605.json`
- 当前 live 门禁证据：`.build-cache/asc-live-audit/final-r3-waiting-review-readback-20260605.json`
- 旧 recurring billing 价格证据已失效；后续只核对 lifetime IAP 价格与版本挂载。

## 六、截图与元数据

- [x] 名称、副标题、宣传文本、描述、关键词已同步到本地 `marketing/appstore/metadata-*.md`
- [x] 审核备注已同步到本地 `marketing/appstore/review-notes.md`
- [x] 隐私问卷草稿已同步到本地 `marketing/appstore/app-privacy-questionnaire.md`
- [x] zh-Hans 截图已通过本地上传前校验
- [x] en-US 截图已通过本地上传前校验
- [x] 截图无 alpha
- [x] locale 本地目录未混用
- [x] review-only 素材未混入公开截图文件名
- [x] `cc-design` / mature commerce r3 视觉门禁已通过
- [x] zh-Hans 截图已上传并通过 ASC API 回读：6 张均 `COMPLETE`
- [x] en-US 截图已上传并通过 ASC API 回读：6 张均 `COMPLETE`

## 七、外部链接

- [x] Support URL 公开访问返回 200：`https://pengpengemail-prog.github.io/tame-geomancy-app-info/support.html`
- [x] Privacy Policy URL 公开访问返回 200：`https://pengpengemail-prog.github.io/tame-geomancy-app-info/privacy-policy.html`
- [x] Apple Standard EULA 返回 200：`https://www.apple.com/legal/internet-services/itunes/dev/stdeula/`

## 八、结论

当前审核状态已通过 API 核验为 `WAITING_FOR_REVIEW`。后续商业化检查只围绕 lifetime non-consumable IAP。保留以下残余风险记录，但它们不再阻止当前版本等待审核：

- 当前会话未重新跑真机 fresh install；已有历史 fresh install 证据，且 ASC 已进入审核队列
- IAP 随版本的 reviewSubmission 明细仍以 Apple 当前队列状态为准；API 回读 IAP 为 `WAITING_FOR_REVIEW`
