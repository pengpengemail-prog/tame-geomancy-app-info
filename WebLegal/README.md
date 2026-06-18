# TAME Space Compass WebLegal

更新时间：2026-05-08

## 目录用途

该目录提供可直接托管到静态站点的法务与支持网页模板，用于：

- `Support URL`
- `Privacy Policy URL`
- `Terms of Use URL`

## 当前文件

- `support.html`
- `privacy-policy.html`
- `terms-of-use.html`
- `DEPLOYMENT_GUIDE.md`

## 推荐托管方式

- GitHub Pages
- Cloudflare Pages
- Vercel 静态站点
- 任意支持静态 HTML 的官网目录

## 推荐操作顺序

1. 先运行 `./scripts/configure_weblegal.sh --site-root <公开根路径> --support-email <支持邮箱>`
2. 确认预览输出无误后，再加 `--apply`
3. 运行 `./scripts/build_weblegal_dist.sh`
4. 将 `WebLegal/dist/` 部署到公开站点
5. 用部署后的真实 URL 回填 App Store Connect

## 上线前需要替换

- 支持邮箱
- 官方域名
- 品牌归属信息
- 最后更新时间

当前本地模板已使用 `pengpengemail@gmail.com` 与 `pengpengemail-prog.github.io/tame-geomancy-app-info` 作为目标线上口径；若最终域名或邮箱不同，先运行配置脚本替换并重建 `WebLegal/dist/`。部署完成后，还需要在 App Store Connect 的版本页和 App Privacy 页面核对真实 URL。
