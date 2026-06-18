# 探觅·堪舆 / TAME·Geomancy 本地提审审核结论

> Monetization update: this May 8 audit has been superseded by the lifetime non-consumable IAP target `com.tame.geomancy.premium.lifetime`; do not submit old recurring products.

更新时间：2026-05-08

## 结论

需补充验证后再提交

## Blockers

- 未实时核对 App Store Connect 当前版本状态，无法确认版本是否可编辑、是否已有待审版本或旧构建残留
- `Support URL`、`Privacy Policy URL`、`Terms of Use URL` 尚未在本地资料中落实为最终线上地址
- App Store 版本页截图素材已通过本地上传前校验，但尚未在 App Store Connect 上传并核对在线预览
- 当前环境无法完成最新 `xcodebuild` 核销，失败点仍在 `CoreSimulatorService / ibtoold / actool` 链路
- 尚未完成基于最新构建的 fresh install 级别模拟器/真机交互 smoke test

## 主要风险

- 品牌风险：若桌面显示名、商店名称、应用内正式锁定组三者描述不一致，可能引起品牌不一致疑问
- 文案风险：若元数据或截图出现“改运、旺财、精准预测命运”等表述，会提高审核风险
- 素材风险：本地截图 validator 已通过，但 ASC 上传后仍可能出现顺序、locale、预览裁切或误传临时素材问题
- 权限风险：相机/相册/定位权限说明虽然已在工程内配置，但仍需确认首次触发时机与实际流程一致
- 功能风险：记录分享、户型导入、拍照导入等路径仍缺少真实设备或完整模拟器交互核验

## 需要在 App Store Connect 核对的项目

- App 名称是否最终采用：
  - `探觅·堪舆`
  - `TAME·Geomancy`
- 副标题、宣传文本、描述、关键词是否已同步为审核安全版本
- `Support URL` 是否已填写正确
- `Privacy Policy URL` 是否已填写正确
- `Terms of Use URL` 是否已填写正确
- 当前版本是否已绑定本次构建
- 终身解锁 IAP `com.tame.geomancy.premium.lifetime` 是否真实挂到当前提审版本，且产品展示名、价格和本地化均已同步
- 各 locale 截图是否分别上传，且未混入审核专用图片

## 建议的提审前最终检查清单

1. 先恢复本机构建 / Simulator 服务链路并完成最新 `xcodebuild`
2. 完成一轮 fresh install smoke test
3. 确认相机、相册、定位、运动权限路径都能正常触发与返回
4. 检查所有页面免责声明是否保持“民俗文化参考”表达
5. 核对名称、截图标题、审核备注、应用内品牌是否一致
6. 上传前逐个检查截图尺寸、无 alpha、locale 分离，并在 ASC 上传后核对在线预览
7. 在 App Store Connect 内再次核对支持链接、隐私链接、使用条款链接、build 绑定和 lifetime IAP 挂载
8. 若上线前有任何 UI、截图、文案、IAP 或权限改动，重新做一次审核风险复盘
