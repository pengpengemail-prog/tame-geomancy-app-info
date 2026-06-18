# TAME Space Compass 提审执行顺序

更新时间：2026-05-08

## 第 1 步：锁定本次提审基础信息

1. 确认对外名称
2. 确认当前选择的 build
3. 确认桌面显示名为 `探觅·空间罗盘`，应用内字标为 `TAME Space Compass / 探觅·空间罗盘`
4. 确认副标题、描述、关键词使用最新版本
5. 确认 App Store 副标题、关键词、宣传文案、商店页面、截图标题、审核备注与外部公开页统一服从最新项目总规则

## 第 2 步：完成本地技术核销

1. 运行 `./scripts/release_gate.sh`
2. 若 release gate 失败，先按 `SubmissionKit/RELEASE_GATE_REPORT.md` 修复阻塞项
3. 运行 `xcodegen -s project.yml -p . -r .`
4. 运行 `xcodebuild ... build`
5. 运行 `./scripts/readiness_check.sh`
6. 在可用模拟器或真机完成 fresh install smoke test
7. 重点走：
   - 罗盘页
   - 分析页
   - 户型导入
   - 历史记录分享
   - 设置页政策说明

## 第 3 步：整理截图与文案

1. 根据 `APPSTORE_SCREENSHOT_COPY.md` 确认每张标题
2. 复核 `SCREENSHOT_DELIVERY_CHECKLIST.md`
3. 确保 zh-Hans 和 en-US 素材分开
4. 确保 review-only 素材未混入版本页截图
5. 确保截图视觉遵循 `暖白底 + 深墨黑 + 哑光香槟金` 与白底极简工具感
6. 运行 `./scripts/validate_appstore_screenshots.sh`
7. 当前本地截图已通过上传前校验；如替换素材，重新生成 manifest 并重跑预检

## 第 3.5 步：生成真实法务链接

1. 运行 `./scripts/configure_weblegal.sh --site-root <公开根路径> --support-email <支持邮箱>`
2. 先确认 dry-run 输出正确
3. 再加 `--apply` 写入真实链接
4. 将 `WebLegal/` 部署到公开可访问地址
5. 用部署后的真实 URL 回填 App Store Connect
## 第 4 步：填写 App Store Connect

1. 填名称
2. 填副标题
3. 填宣传文本
4. 填描述
5. 填关键词
6. 填审核备注
7. 填 Support URL / Privacy Policy URL / Terms of Use URL
8. 确认上述字段与最新总规则及应用内实际视觉口径一致
9. 上传 zh-Hans / en-US 截图，并核对 ASC 在线预览
10. 核对一次性高级解锁项目是否已挂到当前待提交版本
11. 对照 `SubmissionKit/02_ASC_Live_Checklist.md` 逐项核对

## 第 5 步：提交前复核

1. 对照 `FINAL_SUBMISSION_CHECKLIST.md`
2. 对照 `APPSTORE_REVIEW_AUDIT.md`
3. 确认仍不存在 blocker

## 第 6 步：最终提交

只有以下条件全部满足时，才建议进入提交：

- 最新 build 已选中
- 截图与 metadata 已同步，且 ASC 在线预览已核对
- 法务与支持链接已填写
- fresh install 核验已完成
- 一次性高级解锁已挂到当前提审版本
- 本地结论从“需补充验证后再提交”提升到更积极判断
