# TAME Space Compass WebLegal 部署说明

更新时间：2026-05-08

## 目标

将 `WebLegal` 目录中的静态页面部署到一个公开可访问的 URL，用作 App Store Connect 中的：

- `Support URL`
- `Privacy Policy URL`
- `Terms of Use URL`

## 推荐 URL 结构

```text
https://pengpengemail-prog.github.io/tame-geomancy-app-info/support.html
https://pengpengemail-prog.github.io/tame-geomancy-app-info/privacy-policy.html
https://pengpengemail-prog.github.io/tame-geomancy-app-info/terms-of-use.html
```

如果托管平台不支持无后缀路由，也可以直接使用：

```text
https://pengpengemail-prog.github.io/tame-geomancy-app-info/support.html
https://pengpengemail-prog.github.io/tame-geomancy-app-info/privacy-policy.html
https://pengpengemail-prog.github.io/tame-geomancy-app-info/terms-of-use.html
```

## 上线前替换项

1. `pengpengemail@gmail.com`
2. `pengpengemail-prog.github.io/tame-geomancy-app-info`
3. 页面底部版权或团队信息
4. 最后更新时间

当前本地模板已使用 `pengpengemail@gmail.com` 与 `pengpengemail-prog.github.io/tame-geomancy-app-info` 作为目标线上口径；若最终域名或邮箱不同，需先运行 `scripts/configure_weblegal.sh` 替换并重建 `WebLegal/dist/`。

## 部署后核对

- 页面可公开访问
- 移动端打开无样式错乱
- 页面内没有占位邮箱或占位域名残留
- 三个 URL 都可正常加载
- 内容与 App 内政策页一致
- App Store Connect 的版本页与 App Privacy 页都已填入同一套真实 URL

## App Store Connect 填写建议

- `Support URL`：填 `support.html` 或对应支持页路由
- `Privacy Policy URL`：填 `privacy-policy.html` 或对应路由
- `Terms of Use URL`：填 `terms-of-use.html` 或对应路由
