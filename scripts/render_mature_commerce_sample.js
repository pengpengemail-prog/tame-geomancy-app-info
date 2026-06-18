#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const { spawnSync } = require("child_process");

const root = path.resolve(__dirname, "..");
const outDir = path.join(root, "AppStoreAssets", "mature-commerce-r2");
const htmlPath = path.join(outDir, "zh-01-mature-commerce.html");
const outPath = path.join(outDir, "zh-01-mature-commerce.png");
const chromeBin = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const profile = path.join(root, "build", "chrome-appstore-render-profile", "mature-commerce-r2");

const W = 1284;
const H = 2778;

const assets = {
  icon: path.join(root, "Design", "app-icon-original-geomancy-1024.png"),
  bg: path.join(root, "AppStoreAssets", "background-source", "01-space-ring-mountains.jpg"),
  silver: path.join(root, "AppStoreAssets", "background-source", "03-silver-flow.jpg"),
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
html,body{margin:0;width:${W}px;height:${H}px;overflow:hidden;background:#080d0b}
body{font-family:-apple-system,BlinkMacSystemFont,"SF Pro Display","PingFang SC","Hiragino Sans GB","Noto Sans CJK SC",sans-serif}
.poster{position:relative;width:${W}px;height:${H}px;overflow:hidden;color:#f8f2df;background:#07100d}
.poster:before{content:"";position:absolute;inset:-36px;background:url("${fileUrl(assets.bg)}") center/cover no-repeat;filter:saturate(.88) contrast(1.12) brightness(.58);transform:scale(1.06)}
.poster:after{content:"";position:absolute;inset:0;background:
  radial-gradient(920px 760px at 68% 23%,rgba(205,169,88,.38),transparent 68%),
  radial-gradient(920px 920px at 17% 78%,rgba(255,255,255,.16),transparent 72%),
  linear-gradient(180deg,rgba(6,12,10,.64),rgba(8,18,15,.34) 42%,rgba(2,5,4,.86));}
.grain{position:absolute;z-index:2;inset:0;opacity:.18;background-image:radial-gradient(rgba(255,246,222,.30) .55px,transparent .8px);background-size:7px 7px;mix-blend-mode:screen}
.topbar{position:absolute;z-index:20;left:82px;right:82px;top:76px;display:flex;align-items:center;justify-content:space-between}
.brand{display:flex;align-items:center;gap:18px}
.brand img{width:64px;height:64px;border-radius:18px;box-shadow:0 18px 56px rgba(0,0,0,.32)}
.brand b,.brand span{display:block}.brand b{font-size:24px;letter-spacing:0;color:#fff7e8}.brand span{margin-top:5px;color:#cabe9e;font-size:17px;font-weight:650}
.pill{height:48px;padding:0 22px;display:inline-flex;align-items:center;border-radius:999px;background:rgba(255,250,232,.12);border:1px solid rgba(232,196,112,.28);color:#f0dcab;font-size:19px;font-weight:760;backdrop-filter:blur(16px)}
.copy{position:absolute;z-index:20;left:82px;top:226px;width:980px}
.kicker{display:flex;align-items:center;gap:18px;margin-bottom:34px;color:#d8b666;font-size:25px;font-weight:850}
.kicker:before{content:"01";font-size:27px}.kicker:after{content:"";width:112px;height:2px;background:#d8b666}
h1{margin:0;color:#fff9ea;font-size:118px;line-height:.96;font-weight:900;letter-spacing:0;text-shadow:0 22px 74px rgba(0,0,0,.35)}
h1 span{display:block}
.sub{margin-top:28px;max-width:770px;color:#efe5ca;font-size:33px;line-height:1.34;font-weight:620;text-shadow:0 14px 40px rgba(0,0,0,.32)}
.proof-row{display:flex;gap:14px;margin-top:34px}
.proof-row span{height:54px;padding:0 19px;display:inline-flex;align-items:center;border-radius:999px;background:rgba(255,247,225,.13);border:1px solid rgba(232,196,112,.28);box-shadow:0 18px 58px rgba(0,0,0,.16);color:#f8e4af;font-size:20px;font-weight:780;backdrop-filter:blur(18px)}
.stage-light{position:absolute;z-index:4;left:80px;right:80px;bottom:210px;height:620px;background:radial-gradient(ellipse at center,rgba(235,199,117,.36),rgba(255,255,255,.08) 35%,transparent 70%);filter:blur(2px)}
.hero-device{position:absolute;z-index:15;right:54px;bottom:218px;width:675px;height:1462px;border-radius:86px;padding:22px;background:linear-gradient(90deg,#070807,#565c55 5%,#151715 12%,#090a09 88%,#8a836e 96%,#141614);box-shadow:
  inset 0 0 0 2px rgba(255,255,255,.18),
  inset 28px 0 48px rgba(255,255,255,.12),
  inset -28px 0 48px rgba(0,0,0,.74),
  0 76px 170px rgba(0,0,0,.48);
  transform:rotate(-5deg);transform-origin:50% 100%}
.hero-device:before{content:"";position:absolute;inset:-10px;border-radius:96px;background:linear-gradient(112deg,rgba(255,255,255,.30),transparent 18%,transparent 80%,rgba(255,255,255,.32));pointer-events:none}
.hero-device:after{content:"";position:absolute;left:-13px;top:300px;width:12px;height:128px;border-radius:12px 0 0 12px;background:linear-gradient(180deg,#626a61,#121512);box-shadow:0 180px 0 #151816}
.screen{position:relative;z-index:3;width:100%;height:100%;border-radius:64px;overflow:hidden;background:#fff}
.screen img{display:block;width:100%;height:100%;object-fit:cover}
.island{position:absolute;z-index:6;left:50%;top:34px;width:196px;height:56px;transform:translateX(-50%);border-radius:999px;background:#050505;box-shadow:inset 0 0 0 1px rgba(255,255,255,.10)}
.island:after{content:"";position:absolute;right:30px;top:18px;width:17px;height:17px;border-radius:50%;background:radial-gradient(circle at 35% 35%,#405869,#040506 70%)}
.glass{position:absolute;z-index:7;inset:22px;border-radius:64px;background:
  linear-gradient(118deg,rgba(255,255,255,.38),transparent 22%,transparent 68%,rgba(255,255,255,.12)),
  linear-gradient(18deg,transparent,rgba(255,255,255,.18) 48%,transparent 58%);
  mix-blend-mode:screen;pointer-events:none}
.coin{position:absolute;z-index:16;left:68px;bottom:470px;width:560px;height:560px;border-radius:50%;padding:28px;background:radial-gradient(circle at 34% 26%,#fff9dc,#dec06f 23%,#514738 66%,#131513 100%);box-shadow:0 60px 150px rgba(0,0,0,.48),inset 0 0 0 2px rgba(255,244,210,.40);transform:rotate(4deg)}
.coin img{width:100%;height:100%;object-fit:cover;border-radius:50%}
.coin:after{content:"";position:absolute;inset:36px;border-radius:50%;background:linear-gradient(130deg,rgba(255,255,255,.34),transparent 40%,rgba(255,255,255,.10));mix-blend-mode:screen}
.readout{position:absolute;z-index:18;left:94px;bottom:390px;width:480px;padding:30px 34px;border-radius:30px;background:rgba(7,13,11,.82);border:1px solid rgba(219,181,94,.44);box-shadow:0 34px 90px rgba(0,0,0,.34);backdrop-filter:blur(18px)}
.readout small{display:block;color:#d7c9a7;font-size:22px;font-weight:760}.readout b{display:block;margin-top:8px;color:#fff8e5;font-size:58px;line-height:1}
.badge-card{position:absolute;z-index:19;right:88px;top:798px;width:344px;padding:28px 30px;border-radius:30px;background:rgba(255,250,235,.88);border:1px solid rgba(255,255,255,.72);box-shadow:0 34px 90px rgba(0,0,0,.25);color:#111312}
.badge-card small{display:block;color:#78613b;font-size:18px;font-weight:820}.badge-card b{display:block;margin-top:9px;font-size:34px;line-height:1.08}
.orbital{position:absolute;z-index:3;right:-210px;top:660px;width:980px;height:980px;border-radius:50%;border:1px solid rgba(223,190,111,.20)}
.orbital:before,.orbital:after{content:"";position:absolute;inset:120px;border-radius:50%;border:1px solid rgba(255,255,255,.12);transform:rotate(20deg) scaleX(1.32)}
.orbital:after{inset:270px;border-color:rgba(223,190,111,.20);transform:rotate(-34deg) scaleX(1.52)}
footer{position:absolute;z-index:22;left:82px;bottom:76px;color:rgba(255,246,222,.68);font-size:20px;font-weight:650}
</style>
</head>
<body>
<main class="poster">
  <div class="grain"></div>
  <div class="orbital"></div>
  <div class="topbar">
    <div class="brand">
      <img src="${fileUrl(assets.icon)}" alt="">
      <div><b>探觅·空间罗盘</b><span>TAME Space Compass</span></div>
    </div>
    <div class="pill">一次性解锁报告</div>
  </div>
  <section class="copy">
    <div class="kicker">罗盘坐向 · 户型参考</div>
    <h1><span>看清坐向</span><span>一眼定局</span></h1>
    <p class="sub">罗盘读数、户型落点与现场记录，收进一张更清晰的空间参考图。</p>
    <div class="proof-row"><span>离线使用</span><span>本地记录</span><span>报告导出</span></div>
  </section>
  <div class="stage-light"></div>
  <div class="coin"><img src="${fileUrl(assets.compass)}" alt=""></div>
  <div class="readout"><small>当前方位参考</small><b>185° S</b></div>
  <aside class="badge-card"><small>现场测向</small><b>坐向、刻度、空间关系同屏确认</b></aside>
  <div class="hero-device">
    <div class="screen"><img src="${fileUrl(assets.compass)}" alt=""></div>
    <div class="island"></div>
    <div class="glass"></div>
  </div>
  <footer>仅作空间与民俗文化参考，不承诺现实结果。</footer>
</main>
</body>
</html>`;
}

function main() {
  fs.mkdirSync(outDir, { recursive: true });
  fs.mkdirSync(profile, { recursive: true });
  Object.entries(assets).forEach(([key, file]) => {
    if (!fs.existsSync(file)) throw new Error(`Missing asset ${key}: ${file}`);
  });
  fs.writeFileSync(htmlPath, html());
  fs.rmSync(outPath, { force: true });
  fs.rmSync(profile, { recursive: true, force: true });
  fs.mkdirSync(profile, { recursive: true });
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
  const py = `
from PIL import Image
p = ${JSON.stringify(outPath)}
Image.open(p).convert("RGB").save(p)
`;
  spawnSync("python3", ["-c", py], { stdio: "ignore" });
  console.log(outPath);
}

main();
