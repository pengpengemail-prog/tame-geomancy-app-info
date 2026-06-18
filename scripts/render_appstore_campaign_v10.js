#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const { execFileSync } = require("child_process");

const root = path.resolve(__dirname, "..");
const outRoot = path.join(root, "AppStoreAssets");
const campaignDir = path.join(outRoot, "generated-marketing", "campaign-v10");
const zhDir = path.join(outRoot, "zh-Hans-campaign-v10");
const enDir = path.join(outRoot, "en-US-campaign-v10");
const chromeBin = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const chromeProfileRoot = path.join(root, "build", "chrome-appstore-render-profile-v10");
const W = 1284;
const H = 2778;

const assets = {
  icon: "/Users/pengpeng/Downloads/下载.png",
  zh: [
    path.join(root, "VerificationShots", "compass_pointer_to_marked_ring.png"),
    path.join(root, "VerificationShots", "compass_red_pointer_arrow_unified.png"),
    path.join(root, "AppStoreAssets", "zh-Hans", "03-flying-star.png"),
    path.join(root, "AppStoreAssets", "zh-Hans", "04-floor-plan-heatmap.png"),
    path.join(root, "AppStoreAssets", "zh-Hans", "05-bazhai.png"),
    path.join(root, "AppStoreAssets", "zh-Hans", "06-record-share.png"),
  ],
  en: [
    path.join(root, "AppStoreAssets", "en-US", "01-dual-compass.png"),
    path.join(root, "AppStoreAssets", "en-US", "02-opening-reference.png"),
    path.join(root, "AppStoreAssets", "en-US", "03-flying-star.png"),
    path.join(root, "AppStoreAssets", "en-US", "04-floor-plan-heatmap.png"),
    path.join(root, "AppStoreAssets", "en-US", "05-bazhai.png"),
    path.join(root, "AppStoreAssets", "en-US", "06-record-share.png"),
  ],
};

const copy = {
  zh: [
    ["空间方向", "打开就能看清", "用罗盘、户型和记录整理现场判断。"],
    ["测向现场", "主方向一眼确认", "红针、角度和参考信息分层呈现。"],
    ["九宫布局", "复杂关系变直观", "把方位、年度与阶段参考放到同一屏。"],
    ["户型导入", "让方向落到房间", "中心点、开口和区域关系直接对齐。"],
    ["逐房间整理", "卧室书房各看各的", "把不同空间的参考信息分开记录。"],
    ["本地报告", "复盘分享更轻松", "离线保存，需要沟通时再生成分享卡。"],
  ],
  en: [
    ["Room Direction", "Clear From The Start", "Organize compass checks, plans, and records in one place."],
    ["On-Site Checks", "Confirm The Main Direction", "Needle, angle, and reference details stay separated."],
    ["Nine-Grid View", "Make Layouts Easier To Read", "Keep direction, annual, and period references together."],
    ["Import A Plan", "Map Direction To Rooms", "Align center point, openings, and room zones directly."],
    ["Room Notes", "Separate Each Space", "Keep bedroom, study, and living areas organized."],
    ["Local Reports", "Review And Share Calmly", "Save offline, then create a share card when needed."],
  ],
};

function mkdirp(p) {
  fs.mkdirSync(p, { recursive: true });
}

function fileUrl(p) {
  return `file://${p.split(path.sep).map(encodeURIComponent).join("/")}`;
}

function esc(s) {
  return String(s).replace(/[&<>"']/g, (c) => ({
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "'": "&#39;",
  }[c]));
}

function page(locale, index) {
  const isZh = locale === "zh";
  const src = assets[locale][index];
  const [kicker, title, subtitle] = copy[locale][index];
  const dark = index === 0 || index === 5;
  const layout = index % 2 === 0 ? "left" : "right";
  const brand = isZh ? "TAME Space Compass / 探觅·空间罗盘" : "TAME Space Compass";
  const proof = isZh
    ? ["离线运行", "本地记录", "无需登录"]
    : ["Offline", "Local records", "No login"];
  return `<!doctype html>
<html lang="${isZh ? "zh-Hans" : "en"}">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=${W}, height=${H}, initial-scale=1" />
<style>
@font-face{font-family:Heiti;src:local("STHeiti");}
*{box-sizing:border-box}
body{margin:0;width:${W}px;height:${H}px;overflow:hidden;font-family:${isZh ? "Heiti" : "Arial"}, -apple-system, BlinkMacSystemFont, sans-serif;color:#111;letter-spacing:0}
.frame{position:relative;width:${W}px;height:${H}px;overflow:hidden;background:${dark ? "#19362e" : "#f8f5ed"}}
.frame:before{content:"";position:absolute;inset:0;background:${dark
  ? "radial-gradient(900px 720px at 78% 22%,rgba(232,207,143,.16),rgba(232,207,143,0) 68%),linear-gradient(145deg,#142b25 0,#23433a 100%)"
  : "radial-gradient(900px 640px at 20% 18%,rgba(255,255,255,.86),rgba(255,255,255,0) 72%),linear-gradient(145deg,#fbfaf5 0,#efe7d8 100%)"}}
.frame:after{content:"";position:absolute;right:-240px;top:-170px;width:760px;height:760px;border-radius:50%;border:1px solid ${dark ? "rgba(239,222,173,.16)" : "rgba(42,47,42,.09)"};box-shadow:0 0 0 120px ${dark ? "rgba(239,222,173,.04)" : "rgba(42,47,42,.025)"},0 0 0 260px ${dark ? "rgba(239,222,173,.025)" : "rgba(42,47,42,.018)"}}
.grain{position:absolute;inset:0;opacity:${dark ? ".11" : ".08"};background-image:radial-gradient(${dark ? "#fff" : "#000"} .45px,transparent .6px);background-size:6px 6px}
.copy{position:absolute;z-index:8;top:104px;left:82px;width:820px;color:${dark ? "#f8f2e4" : "#101112"}}
.num{display:flex;align-items:center;gap:26px;color:${dark ? "#d8ba72" : "#b0904f"};font-size:29px;font-weight:800;margin-bottom:26px}
.num:after{content:"";display:block;width:124px;height:2px;background:currentColor}
.brand{font-size:${isZh ? 25 : 23}px;font-weight:800;color:${dark ? "#d8ba72" : "#a6894f"};margin-bottom:42px}
.kicker{font-size:${isZh ? 38 : 34}px;font-weight:800;color:${dark ? "#e8dbc0" : "#705f3b"};margin-bottom:18px}
h1{margin:0;font-size:${isZh ? 92 : 78}px;line-height:1.02;font-weight:900;max-width:850px}
.sub{margin-top:28px;font-size:${isZh ? 32 : 29}px;line-height:1.42;color:${dark ? "#e9e2d2" : "#5d605d"};max-width:710px;font-weight:500}
.phone{position:absolute;z-index:5;width:${index === 0 ? 650 : 590}px;padding:22px;border-radius:88px;background:#141411;box-shadow:0 48px 108px rgba(20,18,12,.32),inset 0 0 0 2px rgba(255,255,255,.12)}
.phone:before{content:"";position:absolute;left:50%;top:34px;transform:translateX(-50%);width:178px;height:38px;border-radius:22px;background:#050505;z-index:4}
.phone:after{content:"";position:absolute;inset:30px;border-radius:66px;border:2px solid rgba(255,255,255,.36);z-index:5;pointer-events:none}
.phone img{display:block;width:100%;border-radius:64px;background:#faf8f2}
.shine{position:absolute;inset:24px;border-radius:66px;background:linear-gradient(108deg,rgba(255,255,255,.32),rgba(255,255,255,0) 30%,rgba(255,255,255,.12) 58%,rgba(255,255,255,0));mix-blend-mode:screen;z-index:6;pointer-events:none}
.phone.left{left:82px;top:${index === 5 ? 760 : 760}px;transform:rotate(-4deg)}
.phone.right{right:74px;top:${index === 0 ? 760 : 770}px;transform:rotate(4deg)}
.detail{position:absolute;z-index:6;width:450px;height:450px;border-radius:50%;background:url("${fileUrl(src)}") center ${index === 0 ? "48%" : "38%"}/cover no-repeat;box-shadow:0 34px 96px rgba(34,29,18,.22), inset 0 0 0 14px rgba(255,255,255,.72), inset 0 0 0 16px rgba(192,166,104,.46);filter:saturate(.98) contrast(1.03)}
.detail.left{left:96px;top:1580px}.detail.right{right:108px;top:1540px}
.proof{position:absolute;z-index:7;display:flex;gap:14px;left:82px;right:82px;bottom:250px;justify-content:${layout === "left" ? "flex-end" : "flex-start"}}
.proof span{padding:20px 26px;border-radius:999px;background:${dark ? "rgba(255,255,255,.12)" : "rgba(255,255,255,.72)"};border:1px solid ${dark ? "rgba(232,218,178,.24)" : "rgba(180,164,126,.46)"};color:${dark ? "#f4ead3" : "#3d403d"};font-size:25px;font-weight:800;box-shadow:0 18px 54px rgba(32,28,18,.08)}
.brandmark{position:absolute;z-index:8;left:82px;bottom:106px;display:flex;gap:22px;align-items:center;color:${dark ? "#f8f2e4" : "#151615"}}
.icon{width:82px;height:82px;border-radius:22px;box-shadow:0 18px 42px rgba(20,18,10,.18)}
.brandmark b{display:block;font-size:26px}.brandmark span{display:block;font-size:22px;color:${dark ? "#dccfab" : "#6a6d69"};margin-top:8px}
.line{position:absolute;z-index:3;background:${dark ? "rgba(232,218,178,.16)" : "rgba(34,36,34,.09)"}}
.line.h{left:82px;right:82px;top:1390px;height:1px}.line.v{top:210px;bottom:210px;left:50%;width:1px}
</style>
</head>
<body>
<main class="frame">
  <div class="grain"></div><div class="line h"></div><div class="line v"></div>
  <section class="copy">
    <div class="num">${String(index + 1).padStart(2, "0")}</div>
    <div class="brand">${esc(brand)}</div>
    <div class="kicker">${esc(kicker)}</div>
    <h1>${esc(title)}</h1>
    <div class="sub">${esc(subtitle)}</div>
  </section>
  <div class="phone ${layout}"><img src="${fileUrl(src)}" /><div class="shine"></div></div>
  <div class="detail ${layout === "left" ? "right" : "left"}"></div>
  <div class="proof">${proof.map((x) => `<span>${esc(x)}</span>`).join("")}</div>
  <section class="brandmark"><img class="icon" src="${fileUrl(assets.icon)}" /><div><b>TAME Space Compass</b><span>${isZh ? "空间参考工具" : "Spatial reference tool"}</span></div></section>
</main>
</body>
</html>`;
}

function chromeArgs(profile, windowSize, outPath, url) {
  return [
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
    "--timeout=1500",
    `--user-data-dir=${profile}`,
    `--window-size=${windowSize}`,
    `--screenshot=${outPath}`,
    url,
  ];
}

function validPng(file) {
  if (!fs.existsSync(file)) return false;
  if (fs.statSync(file).size < 100000) return false;
  const fd = fs.openSync(file, "r");
  const buf = Buffer.alloc(8);
  fs.readSync(fd, buf, 0, 8, 0);
  fs.closeSync(fd);
  return buf.toString("hex") === "89504e470d0a1a0a";
}

function cleanup(profile) {
  try {
    execFileSync("pkill", ["-f", profile], { stdio: "ignore" });
  } catch {}
}

function render(htmlPath, outPath, size = `${W},${H}`) {
  const profile = path.join(chromeProfileRoot, outPath.replace(/[^a-zA-Z0-9]+/g, "-"));
  fs.rmSync(profile, { recursive: true, force: true });
  mkdirp(profile);
  fs.rmSync(outPath, { force: true });
  const url = fileUrl(htmlPath);
  try {
    execFileSync(chromeBin, chromeArgs(profile, size, outPath, url), { stdio: "ignore", timeout: 7000 });
  } catch (error) {
    if (!validPng(outPath)) throw error;
  } finally {
    cleanup(profile);
  }
}

function contactSheet(files, outPath) {
  const htmlPath = outPath.replace(/\.jpg$/, ".html");
  const html = `<!doctype html><meta charset="utf-8"><style>
body{margin:0;background:#e9e5dc}.sheet{display:grid;grid-template-columns:repeat(3,360px);gap:22px;padding:22px}
img{width:360px;height:${Math.round(360 * H / W)}px;object-fit:cover;display:block;background:#fff}
</style><div class="sheet">${files.map((f) => `<img src="${fileUrl(f)}">`).join("")}</div>`;
  fs.writeFileSync(htmlPath, html);
  render(htmlPath, outPath, "1126,1610");
}

function main() {
  [campaignDir, zhDir, enDir].forEach(mkdirp);
  const written = { zh: [], en: [] };
  for (const locale of ["zh", "en"]) {
    const dir = locale === "zh" ? zhDir : enDir;
    for (let i = 0; i < 6; i++) {
      const htmlPath = path.join(campaignDir, `${locale}-${String(i + 1).padStart(2, "0")}.html`);
      const outPath = path.join(dir, `${String(i + 1).padStart(2, "0")}.png`);
      fs.writeFileSync(htmlPath, page(locale, i));
      render(htmlPath, outPath);
      written[locale].push(outPath);
    }
  }
  contactSheet(written.zh, path.join(campaignDir, "zh-contactsheet.jpg"));
  contactSheet(written.en, path.join(campaignDir, "en-contactsheet.jpg"));
  console.log(`Wrote ${written.zh.length} zh screenshots to ${zhDir}`);
  console.log(`Wrote ${written.en.length} en screenshots to ${enDir}`);
  console.log(`Contact sheets in ${campaignDir}`);
}

main();
