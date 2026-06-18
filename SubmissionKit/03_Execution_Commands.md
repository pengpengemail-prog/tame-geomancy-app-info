# TAMEGeomancy 一键执行命令清单

更新时间：2026-05-08

## 1. 重新生成工程

```bash
xcodegen -s project.yml -p . -r .
```

## 2. 本地构建

```bash
CLANG_MODULE_CACHE_PATH=$PWD/.build-cache/module-cache \
SWIFT_MODULE_CACHE_PATH=$PWD/.build-cache/module-cache \
xcodebuild -project TAMEGeomancy.xcodeproj \
  -scheme TAMEGeomancy \
  -derivedDataPath $PWD/.DerivedData \
  -destination "generic/platform=iOS Simulator" build
```

## 3. 总自检

```bash
./scripts/readiness_check.sh
```

## 4. 一键预检总控

```bash
./scripts/preflight_audit.sh
```

## 5. 发布门禁总控

```bash
./scripts/release_gate.sh
```

输出位置：`SubmissionKit/RELEASE_GATE_REPORT.md`

## 6. Xcode / Simulator 只读诊断

```bash
./scripts/diagnose_xcode_simulator.sh
```

输出位置：`.build-cache/xcode_simulator_diagnostics.md`

## 7. 截图校验

```bash
./scripts/validate_appstore_screenshots.sh
```

## 8. 预览法务链接替换

```bash
./scripts/configure_weblegal.sh \
  --site-root https://pengpengemail-prog.github.io/tame-geomancy-app-info \
  --support-email pengpengemail@gmail.com
```

## 9. 写入真实法务链接

```bash
./scripts/configure_weblegal.sh \
  --site-root https://pengpengemail-prog.github.io/tame-geomancy-app-info \
  --support-email pengpengemail@gmail.com \
  --apply
```

## 10. 生成可部署 WebLegal 产物

```bash
./scripts/build_weblegal_dist.sh
```

## 11. 生成截图 manifest

```bash
./scripts/generate_screenshot_manifest.sh
```

## 12. 最后人工核销顺序

1. 先跑 `./scripts/release_gate.sh`
2. 若门禁失败，查看 `SubmissionKit/RELEASE_GATE_REPORT.md`
3. 若构建失败，查看 `.build-cache/xcode_simulator_diagnostics.md` 区分工程问题与 Simulator 服务问题
4. 完成 `SMOKE_TEST_RUNBOOK.md`
5. 复核截图上传前状态：当前 `AppStoreAssets/zh-Hans/` 与 `AppStoreAssets/en-US/` 均已本地校验通过；如替换素材则重新运行截图校验与 manifest
6. 写入真实法务链接并构建 `WebLegal/dist/`
7. 部署 `WebLegal/dist/`
8. 在 App Store Connect 上传截图并核对在线预览
9. 填写 `SubmissionKit/02_ASC_Live_Checklist.md`
10. 回填 `BLOCKER_CLEARANCE_LOG.md`

## 13. 核对一次性解锁价格基准（规划 / 执行）

```bash
python3 scripts/asc_tame_iap_price_plan.py \
  --issuer-id b88a3dc3-7f22-48df-b6a4-d93d08e29f92
```

`--apply` 只会输出提示；一次性 IAP 价格需在 App Store Connect 中人工核对。当前本地基准价为终身解锁 `US$12.99` / 中国区 `CNY ¥88.00`。
