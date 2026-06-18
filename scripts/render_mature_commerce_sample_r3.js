#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const { spawnSync } = require("child_process");

const root = path.resolve(__dirname, "..");
const outDir = path.join(root, "AppStoreAssets", "mature-commerce-r3");
const htmlPath = path.join(outDir, "zh-01-mature-commerce-r3.html");
const outPath = path.join(outDir, "zh-01-mature-commerce-r3.png");
const chromeBin = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const profile = path.join(root, "build", "chrome-appstore-render-profile", "mature-commerce-r3");
const W = 1284;
const H = 2778;

const assets = {
  icon: path.join(root, "Design", "app-icon-original-geomancy-1024.png"),
  bg: path.join(root, "AppStoreAssets", "background-source", "03-silver-flow.jpg"),
  chrome: path.join(root, "AppStoreAssets", "background-source", "09-chrome-sphere.jpg"),
  compass: path.join(root, "VerificationShots", "compass_pointer_to_marked_ring.png"),
};

function fileUrl(file) {
  return `file://${path.resolve(file).split(path.sep).map(encodeURIComponent).join("/")}`;
}

function validPng(file) {
  if (!fs.existsSync(file) || fs.statSync(file).size < 100000) return false;
  const fd = fs.openSync(file, "r");
  const buf = Buffer.alloc(8);
  fs.readSync(fd, buf, 0, 8, 0);
  fs.closeSync(fd);
  return buf.toString("hex") === "89504e470d0a1a0a";
}

function html() {
  return `<!doctype html>
<html lang="zh-Hans">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=${W}, height=${H}, initial-scale=1">
<style>
*{box-sizing:border-box}
html,body{margin:0;width:${W}px;height:${H}px;overflow:hidden;background:#f4f1e8}
body{font-family:-apple-system,BlinkMacSystemFont,"SF Pro Display","PingFang SC","Hiragino Sans GB","Noto Sans CJK SC",sans-serif}
.poster{position:relative;width:${W}px;height:${H}px;overflow:hidden;background:#f5f2e9;color:#111312}
.poster:before{content:"";position:absolute;inset:-28px;background:url("${fileUrl(assets.bg)}") center/cover no-repeat;filter:saturate(.82) contrast(1.04) brightness(1.03);transform:scale(1.06)}
.poster:after{content:"";position:absolute;inset:0;background:
  radial-gradient(780px 640px at 70% 19%,rgba(210,180,112,.22),transparent 70%),
  radial-gradient(720px 620px at 19% 66%,rgba(255,255,255,.76),transparent 72%),
  linear-gradient(180deg,rgba(255,255,255,.90),rgba(247,242,229,.62) 43%,rgba(12,18,15,.09));}
.grain{position:absolute;z-index:2;inset:0;opacity:.10;background-image:radial-gradient(rgba(18,16,12,.28) .55px,transparent .75px);background-size:7px 7px;mix-blend-mode:multiply}
.top{position:absolute;z-index:24;left:82px;right:82px;top:78px;display:flex;align-items:center;justify-content:space-between}
.brand{display:flex;align-items:center;gap:16px}.brand img{width:58px;height:58px;border-radius:17px;box-shadow:0 16px 42px rgba(31,25,16,.16)}.brand b,.brand span{display:block}.brand b{font-size:23px;color:#111312}.brand span{margin-top:5px;color:#65665f;font-size:16px;font-weight:650}
.tag{height:46px;padding:0 20px;border-radius:999px;background:rgba(17,19,18,.86);color:#f9efd7;display:inline-flex;align-items:center;font-size:18px;font-weight:800;box-shadow:0 18px 44px rgba(0,0,0,.16)}
.copy{position:absolute;z-index:22;left:82px;top:208px;width:890px}.kicker{margin-bottom:28px;color:#a98646;font-size:24px;font-weight:850}
h1{margin:0;color:#0f1110;font-size:112px;line-height:.98;font-weight:900;letter-spacing:0}h1 span{display:block}
.sub{margin-top:26px;max-width:740px;color:#535852;font-size:31px;line-height:1.38;font-weight:620}
.chips{display:flex;gap:14px;margin-top:32px}.chips span{height:50px;padding:0 18px;border-radius:999px;background:rgba(255,255,255,.76);border:1px solid rgba(151,126,74,.22);box-shadow:0 14px 38px rgba(55,48,34,.08);display:inline-flex;align-items:center;color:#6c5630;font-size:19px;font-weight:780}
.product-stage{position:absolute;z-index:5;left:0;right:0;bottom:0;height:1840px;background:
  radial-gradient(760px 520px at 56% 66%,rgba(255,255,255,.96),rgba(255,255,255,.36) 48%,transparent 76%),
  linear-gradient(180deg,transparent 0%,rgba(14,22,18,.08) 56%,rgba(7,11,10,.22));}
.platform{position:absolute;z-index:8;left:148px;right:110px;bottom:188px;height:430px;border-radius:50%;background:radial-gradient(ellipse at center,rgba(38,44,39,.24),rgba(213,196,150,.18) 38%,transparent 72%);filter:blur(1px)}
.device{position:absolute;z-index:16;right:106px;bottom:230px;width:655px;height:1418px;border-radius:84px;padding:22px;background:linear-gradient(90deg,#0a0b0a,#5b625a 5%,#171917 12%,#090a09 88%,#827a67 96%,#151715);box-shadow:
  inset 0 0 0 2px rgba(255,255,255,.18),
  inset 28px 0 46px rgba(255,255,255,.12),
  inset -28px 0 46px rgba(0,0,0,.72),
  0 68px 160px rgba(0,0,0,.30);
  transform:rotate(-3.6deg);transform-origin:50% 100%}
.device:before{content:"";position:absolute;inset:-10px;border-radius:96px;background:linear-gradient(112deg,rgba(255,255,255,.30),transparent 19%,transparent 82%,rgba(255,255,255,.30));pointer-events:none}
.device:after{content:"";position:absolute;left:-12px;top:300px;width:12px;height:128px;border-radius:12px 0 0 12px;background:linear-gradient(180deg,#626a61,#121512);box-shadow:0 178px 0 #151816}
.screen{position:relative;z-index:3;width:100%;height:100%;border-radius:62px;overflow:hidden;background:#fff}.screen img{display:block;width:100%;height:100%;object-fit:cover}
.island{position:absolute;z-index:6;left:50%;top:34px;width:190px;height:55px;transform:translateX(-50%);border-radius:999px;background:#050505;box-shadow:inset 0 0 0 1px rgba(255,255,255,.10)}.island:after{content:"";position:absolute;right:29px;top:18px;width:16px;height:16px;border-radius:50%;background:radial-gradient(circle at 35% 35%,#405869,#040506 70%)}
.glass{position:absolute;z-index:7;inset:22px;border-radius:62px;background:linear-gradient(118deg,rgba(255,255,255,.36),transparent 22%,transparent 68%,rgba(255,255,255,.12)),linear-gradient(18deg,transparent,rgba(255,255,255,.16) 48%,transparent 58%);mix-blend-mode:screen;pointer-events:none}
.compass-object{position:absolute;z-index:18;left:74px;bottom:468px;width:520px;height:520px;border-radius:50%;padding:24px;background:radial-gradient(circle at 34% 26%,#fff7dc,#d8b967 24%,#5c523e 66%,#151715 100%);box-shadow:0 48px 120px rgba(28,31,27,.28),inset 0 0 0 2px rgba(255,244,210,.46);transform:rotate(2deg)}.compass-object img{width:100%;height:100%;object-fit:cover;border-radius:50%}.compass-object:after{content:"";position:absolute;inset:32px;border-radius:50%;background:linear-gradient(130deg,rgba(255,255,255,.35),transparent 40%,rgba(255,255,255,.10));mix-blend-mode:screen}
.readout{position:absolute;z-index:20;left:84px;bottom:390px;width:430px;padding:28px 32px;border-radius:28px;background:rgba(12,18,15,.91);border:1px solid rgba(204,169,87,.48);box-shadow:0 30px 76px rgba(0,0,0,.24);color:#fff7e7}.readout small{display:block;color:#cfc0a0;font-size:20px;font-weight:760}.readout b{display:block;margin-top:8px;font-size:56px;line-height:1;font-weight:900}
.feature{position:absolute;z-index:21;right:78px;top:730px;width:330px;padding:26px 28px;border-radius:28px;background:rgba(255,255,255,.84);border:1px solid rgba(255,255,255,.86);box-shadow:0 30px 78px rgba(27,33,29,.14);backdrop-filter:blur(18px)}.feature small{display:block;color:#8b7140;font-size:18px;font-weight:850}.feature b{display:block;margin-top:8px;color:#101210;font-size:31px;line-height:1.08;font-weight:880}
.line-art{position:absolute;z-index:4;right:-300px;bottom:625px;width:1080px;height:1080px;border:1px solid rgba(169,139,75,.17);border-radius:50%}.line-art:before,.line-art:after{content:"";position:absolute;inset:126px;border-radius:50%;border:1px solid rgba(18,24,21,.08);transform:rotate(18deg) scaleX(1.26)}.line-art:after{inset:296px;border-color:rgba(169,139,75,.16);transform:rotate(-32deg) scaleX(1.5)}
footer{position:absolute;z-index:25;left:82px;bottom:72px;color:rgba(16,18,17,.54);font-size:20px;font-weight:650}
</style>
</head>
<body>
<main class="poster">
  <div class="grain"></div>
  <div class="top">
    <div class="brand"><img src="${fileUrl(assets.icon)}" alt=""><div><b>探觅·空间罗盘</b><span>TAME Space Compass</span></div></div>
    <div class="tag">本地记录 · 报告导出</div>
  </div>
  <section class="copy">
    <div class="kicker">罗盘坐向 · 户型参考</div>
    <h1><span>看清坐向</span><span>一眼定局</span></h1>
    <p class="sub">把罗盘读数、户型落点与现场记录，整理成清晰的空间参考图。</p>
    <div class="chips"><span>离线使用</span><span>本地保存</span><span>一次性解锁</span></div>
  </section>
  <div class="product-stage"></div>
  <div class="platform"></div>
  <div class="line-art"></div>
  <aside class="feature"><small>现场测向</small><b>坐向、刻度、空间关系同屏确认</b></aside>
  <div class="compass-object"><img src="${fileUrl(assets.compass)}" alt=""></div>
  <div class="readout"><small>当前方位参考</small><b>185° S</b></div>
  <div class="device"><div class="screen"><img src="${fileUrl(assets.compass)}" alt=""></div><div class="island"></div><div class="glass"></div></div>
  <footer>仅作空间与民俗文化参考，不承诺现实结果。</footer>
</main>
</body>
</html>`;
}

function main() {
  fs.mkdirSync(outDir, { recursive: true });
  fs.rmSync(profile, { recursive: true, force: true });
  fs.mkdirSync(profile, { recursive: true });
  Object.entries(assets).forEach(([key, file]) => {
    if (!fs.existsSync(file)) throw new Error(`Missing asset ${key}: ${file}`);
  });
  fs.writeFileSync(htmlPath, html());
  fs.rmSync(outPath, { force: true });
  const args = [
    "--headless=new",
    "--disable-gpu",
    "--disable-background-networking",
    "--disable-component-update",
    "--disable-default-apps",
    "--disable-extensions",
    "--disable-sync",
    "--no-first-run",
    "--no-default-browser-check",
    "--hide-scrollbars",
    "--allow-file-access-from-files",
    "--force-device-scale-factor=1",
    "--run-all-compositor-stages-before-draw",
    "--virtual-time-budget=3000",
    `--user-data-dir=${profile}`,
    `--window-size=${W},${H}`,
    `--screenshot=${outPath}`,
    fileUrl(htmlPath),
  ];
  const result = spawnSync(chromeBin, args, { stdio: "ignore", timeout: 16000 });
  try { spawnSync("pkill", ["-f", profile], { stdio: "ignore" }); } catch {}
  if (!validPng(outPath)) {
    console.error(result.error || result.status || "Chrome did not produce a valid PNG");
    process.exit(1);
  }
  spawnSync("python3", ["-c", `from PIL import Image\\np=${JSON.stringify(outPath)}\\nImage.open(p).convert("RGB").save(p)`], { stdio: "ignore" });
  console.log(outPath);
}

main();
