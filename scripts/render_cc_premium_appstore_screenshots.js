#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const { execFileSync } = require("child_process");

const root = path.resolve(__dirname, "..");
const outRoot = path.join(root, "AppStoreAssets");
const campaignName = "cc-premium-v1";
const campaignDir = path.join(outRoot, "generated-marketing", campaignName);
const zhDir = path.join(outRoot, "zh-Hans-cc-premium-v1");
const enDir = path.join(outRoot, "en-US-cc-premium-v1");
const chromeBin = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const chromeProfileRoot = path.join(root, "build", "chrome-appstore-render-profile", campaignName);

const W = 1284;
const H = 2778;

const assets = {
  icon: path.join(root, "Design", "app-icon-original-geomancy-1024.png"),
  compass: path.join(root, "VerificationShots", "compass_red_pointer_arrow_unified.png"),
  compassMarked: path.join(root, "VerificationShots", "compass_pointer_to_marked_ring.png"),
  overviewZh: path.join(root, "VerificationShots", "overview-nine-palace-2026-05-22.png"),
  overviewEn: path.join(root, "VerificationShots", "en-US", "flying-star-demo-2.png"),
  planZh: path.join(root, "VerificationShots", "analysis-yanggong-entry-2026-05-22.png"),
  planEn: path.join(root, "VerificationShots", "en-US", "annual-demo-3.png"),
  roomZh: path.join(root, "VerificationShots", "yanggong-fenjin-clean.png"),
  roomEn: path.join(root, "VerificationShots", "en-US", "bazhai-smoke-3.png"),
  reportZh: path.join(root, "VerificationShots", "overview-graphical-entry-2026-05-22.png"),
  reportEn: path.join(root, "VerificationShots", "en-US", "annual-demo-3.png"),
};

const finalNames = [
  "01-dual-compass.png",
  "02-opening-reference.png",
  "03-flying-star.png",
  "04-floor-plan-heatmap.png",
  "05-bazhai.png",
  "06-record-share.png",
];

const copy = {
  zh: [
    {
      eyebrow: "TAME Space Compass / 探觅·空间罗盘",
      title: ["把空间方位", "变成清晰判断"],
      sub: "双盘罗盘、户型参考与本地记录，专为现场空间判断而生。",
      proof: "双盘测向 / 户型参考 / 本地报告",
    },
    {
      eyebrow: "现场测向",
      title: ["地盘与空间盘", "同屏对照"],
      sub: "红针突出主方向，角度、刻度和参考信息保持同一视线。",
      proof: "182.5° 地盘读数   190.0° 空间参考",
    },
    {
      eyebrow: "九宫布局",
      title: ["格局参考", "不用重新记"],
      sub: "把方位、年度与阶段信息集中查看，复杂关系一屏整理。",
      proof: "九宫 / 年度 / 阶段",
    },
    {
      eyebrow: "户型叠加",
      title: ["让方向", "落到房间"],
      sub: "导入户型，标记中心点、开口与功能区，关系直接看图。",
      proof: "中心点 / 开口 / 功能区",
    },
    {
      eyebrow: "空间分组",
      title: ["不同空间", "分开判断"],
      sub: "卧室、书房、客厅、玄关各自成组，整理更稳定。",
      proof: "卧室 / 书房 / 客厅 / 玄关",
    },
    {
      eyebrow: "本地记录",
      title: ["复盘与分享", "更从容"],
      sub: "测向、户型与备注保存在本机，需要沟通时再生成报告。",
      proof: "本地保存 / 按需分享",
    },
  ],
  en: [
    {
      eyebrow: "TAME Space Compass",
      title: ["Turn Orientation", "Into Clear Decisions"],
      sub: "Dual compass, floor-plan references, and local records for spatial field work.",
      proof: "Dual compass / Plans / Local reports",
    },
    {
      eyebrow: "On-Site Reading",
      title: ["Compare Two Plates", "In One View"],
      sub: "A dominant red needle keeps the main direction visible while details stay structured.",
      proof: "182.5° Earth plate   190.0° Space reference",
    },
    {
      eyebrow: "Nine-Grid Layouts",
      title: ["Organize Complex", "Spatial Context"],
      sub: "Bring direction, annual, and period references into one calm visual system.",
      proof: "Grid / Annual / Period",
    },
    {
      eyebrow: "Plan Alignment",
      title: ["Map Direction", "To Real Rooms"],
      sub: "Import a plan, place the center point, and align openings with room zones.",
      proof: "Center / Opening / Room zones",
    },
    {
      eyebrow: "Room Groups",
      title: ["Separate Notes", "By Space"],
      sub: "Keep bedrooms, studies, living areas, and entries organized for review.",
      proof: "Bedroom / Study / Living / Entry",
    },
    {
      eyebrow: "Local Records",
      title: ["Review And Share", "With Control"],
      sub: "Compass checks, plans, and notes stay on device until you choose to share.",
      proof: "Local first / Share when needed",
    },
  ],
};

const frames = [
  { kind: "hero", source: "compassMarked", alt: "compass", theme: "dark" },
  { kind: "compass", source: "compass", alt: "compassMarked", theme: "light" },
  { kind: "grid", sourceZh: "overviewZh", sourceEn: "overviewEn", theme: "light" },
  { kind: "plan", sourceZh: "planZh", sourceEn: "planEn", theme: "warm" },
  { kind: "rooms", sourceZh: "roomZh", sourceEn: "roomEn", theme: "light" },
  { kind: "records", sourceZh: "reportZh", sourceEn: "reportEn", altZh: "planZh", altEn: "planEn", theme: "dark" },
];

function mkdirp(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

function fileUrl(file) {
  return `file://${file.split(path.sep).map(encodeURIComponent).join("/")}`;
}

function escapeHtml(value) {
  return String(value).replace(/[&<>"']/g, (char) => ({
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "'": "&#39;",
  }[char]));
}

function frameSource(locale, frame) {
  const key = locale === "zh" ? frame.sourceZh || frame.source : frame.sourceEn || frame.source;
  return assets[key];
}

function frameAlt(locale, frame) {
  const key = locale === "zh" ? frame.altZh || frame.alt : frame.altEn || frame.alt;
  return key ? assets[key] : frameSource(locale, frame);
}

function dataFor(locale, index) {
  const frame = frames[index];
  return {
    locale,
    frameNo: String(index + 1).padStart(2, "0"),
    filename: finalNames[index],
    ...frame,
    copy: copy[locale][index],
    source: frameSource(locale, frame),
    alt: frameAlt(locale, frame),
  };
}

function renderHtml(data) {
  const isZh = data.locale === "zh";
  const bodyClass = `${data.kind} ${data.theme} ${isZh ? "zh" : "en"}`;
  const source = fileUrl(data.source);
  const alt = fileUrl(data.alt);
  const icon = fileUrl(assets.icon);
  const title = data.copy.title.map((line) => `<span>${escapeHtml(line)}</span>`).join("");

  return `<!doctype html>
<html lang="${isZh ? "zh-Hans" : "en"}">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=${W}, height=${H}, initial-scale=1">
<style>
*{box-sizing:border-box}
html,body{margin:0;width:${W}px;height:${H}px;overflow:hidden}
body{font-family:-apple-system,BlinkMacSystemFont,"SF Pro Display","Hiragino Sans GB","Songti SC",serif;color:#151617;background:#f6f3ea}
.poster{position:relative;width:${W}px;height:${H}px;overflow:hidden;background:#f8f6ef}
.poster:before{content:"";position:absolute;inset:0;background:
  radial-gradient(900px 680px at 80% 14%,rgba(215,187,124,.22),transparent 68%),
  radial-gradient(780px 560px at 16% 72%,rgba(255,255,255,.76),transparent 72%),
  linear-gradient(156deg,#fffdfa 0%,#f3eee2 54%,#e5d9c5 100%)}
.poster:after{content:"";position:absolute;inset:0;opacity:.16;background-image:radial-gradient(rgba(18,18,16,.28) .55px,transparent .75px);background-size:7px 7px;mix-blend-mode:multiply}
.dark:before{background:
  radial-gradient(900px 690px at 72% 30%,rgba(221,187,112,.22),transparent 68%),
  radial-gradient(820px 660px at 16% 74%,rgba(255,255,255,.06),transparent 70%),
  linear-gradient(156deg,#142821 0%,#233f35 52%,#142821 100%)}
.warm:before{background:
  radial-gradient(860px 620px at 18% 54%,rgba(255,255,255,.85),transparent 72%),
  radial-gradient(860px 680px at 86% 10%,rgba(198,160,91,.18),transparent 70%),
  linear-gradient(156deg,#fbfaf5 0%,#f0e7d8 100%)}
.brand-watermark{position:absolute;right:-278px;top:-255px;width:980px;height:980px;background:url('${icon}') center/contain no-repeat;opacity:.075;filter:grayscale(1) contrast(1.08)}
.dark .brand-watermark{opacity:.10;filter:grayscale(1) invert(1) contrast(1.12)}
.ring{position:absolute;border-radius:50%;border:2px solid rgba(25,28,24,.075)}
.dark .ring{border-color:rgba(244,235,210,.16)}
.r1{width:1260px;height:1260px;right:-432px;top:135px}.r2{width:840px;height:840px;left:-330px;bottom:300px}.r3{width:430px;height:430px;right:120px;bottom:360px;opacity:.65}
.axis-h,.axis-v{position:absolute;background:rgba(18,19,17,.075)}.axis-h{left:96px;right:96px;top:1340px;height:1px}.axis-v{top:176px;bottom:220px;left:50%;width:1px}
.dark .axis-h,.dark .axis-v{background:rgba(244,235,210,.18)}
.copy{position:absolute;z-index:10;left:96px;top:104px;width:860px}
.seq{display:flex;align-items:center;gap:28px;margin-bottom:28px;color:#ad8e4e;font-size:27px;font-weight:700}
.seq:after{content:"";display:block;width:124px;height:2px;background:#ad8e4e}
.eyebrow{margin-bottom:42px;color:#ad8e4e;font-size:${isZh ? 25 : 23}px;font-weight:700}
.title{font-size:${isZh ? 91 : 80}px;line-height:.98;font-weight:800;letter-spacing:0;max-width:880px}
.title span{display:block}
.sub{margin-top:34px;max-width:${isZh ? 760 : 770}px;color:#62635f;font-size:${isZh ? 32 : 30}px;line-height:1.38;font-weight:450}
.dark .title,.dark .sub{color:#f7f1e5}.dark .eyebrow,.dark .seq{color:#d5b66b}.dark .seq:after{background:#d5b66b}
.proof{position:absolute;z-index:12;left:96px;bottom:138px;display:flex;align-items:center;gap:24px;color:#656761;font-size:25px;font-weight:650}
.proof .mark{width:76px;height:76px;border-radius:22px;background:url('${icon}') center/cover no-repeat;box-shadow:0 18px 50px rgba(27,24,16,.14)}
.dark .proof{color:#eee6cf}
.device{position:absolute;z-index:8;width:610px;padding:22px;border-radius:88px;background:#121211;box-shadow:0 50px 120px rgba(33,29,19,.28),inset 0 0 0 2px rgba(255,255,255,.16)}
.device:before{content:"";position:absolute;z-index:4;left:50%;top:34px;transform:translateX(-50%);width:180px;height:38px;border-radius:999px;background:#050505}
.screen{position:relative;width:100%;border-radius:64px;overflow:hidden;background:#fbfaf6}
.screen img{display:block;width:100%;height:auto;object-fit:cover}
.device:after{content:"";position:absolute;z-index:5;inset:30px;border-radius:68px;border:2px solid rgba(255,255,255,.42);pointer-events:none}
.shine{position:absolute;z-index:6;inset:22px;border-radius:66px;background:linear-gradient(108deg,rgba(255,255,255,.28),transparent 32%,rgba(255,255,255,.12) 58%,transparent);mix-blend-mode:screen}
.tilt-left{transform:rotate(-4deg)}.tilt-right{transform:rotate(3.5deg)}
.disc{position:absolute;z-index:5;border-radius:50%;background:url('${alt}') center 38%/cover no-repeat;filter:saturate(.78) contrast(1.04);opacity:.28;box-shadow:inset 0 0 0 3px rgba(255,255,255,.28)}
.coin{position:absolute;z-index:9;border-radius:50%;background:radial-gradient(circle at 34% 28%,#fff7d7 0,#e4c16f 20%,#a7782d 49%,#f2d78d 68%,#7c591f 100%);box-shadow:0 18px 42px rgba(84,58,16,.26),inset 0 0 18px rgba(255,255,255,.52)}
.metric{position:absolute;z-index:12;width:300px;padding:30px 32px;border:1px solid rgba(176,151,95,.42);border-radius:28px;background:rgba(255,255,255,.72);box-shadow:0 26px 72px rgba(47,41,27,.12);backdrop-filter:blur(14px)}
.metric b{display:block;font-size:38px;line-height:1;color:#151617}.metric span{display:block;margin-top:12px;color:#72746e;font-size:22px;font-weight:650}
.grid-map{position:absolute;z-index:11;display:grid;grid-template-columns:repeat(3,162px);grid-template-rows:repeat(3,162px);gap:13px}
.grid-map div{display:flex;align-items:center;justify-content:center;border:1px solid rgba(92,79,51,.24);border-radius:8px;font-size:42px;font-weight:800;color:#191a18}
.grid-map div:nth-child(3n+1){background:#efe6c7}.grid-map div:nth-child(3n+2){background:#dcebe2}.grid-map div:nth-child(3n){background:#ead7d4}
.plan-map{position:absolute;z-index:11;width:520px;height:520px;display:grid;grid-template-columns:1fr 1fr;grid-template-rows:1fr 1fr;border:2px solid rgba(54,48,36,.48)}
.plan-map div{border:1px solid rgba(54,48,36,.38)}.plan-map div:nth-child(1){background:#dcebe2}.plan-map div:nth-child(2){background:#f0e7c6}.plan-map div:nth-child(3){background:#dfe9f2}.plan-map div:nth-child(4){background:#ead6d4}
.needle{position:absolute;z-index:12;width:8px;height:440px;background:#b6322e;box-shadow:0 12px 24px rgba(138,28,22,.22)}
.needle:before{content:"";position:absolute;left:50%;top:-56px;transform:translateX(-50%);width:0;height:0;border-left:34px solid transparent;border-right:34px solid transparent;border-bottom:76px solid #b6322e}
.needle:after{content:"";position:absolute;left:50%;top:380px;transform:translateX(-50%);width:54px;height:54px;border-radius:50%;background:#111}
.note-card{position:absolute;z-index:13;padding:31px 34px;border:1px solid rgba(176,151,95,.42);border-radius:30px;background:rgba(255,255,255,.76);box-shadow:0 26px 72px rgba(47,41,27,.12);backdrop-filter:blur(14px)}
.note-card b{display:block;margin-bottom:10px;font-size:31px;color:#ad8e4e}.note-card span{font-size:24px;line-height:1.34;color:#696b66;font-weight:600}
.room-list{position:absolute;z-index:12;display:flex;flex-direction:column;gap:26px}
.room-list div{width:360px;padding:28px 32px;border-radius:22px;border:1px solid rgba(176,151,95,.34);font-size:30px;font-weight:800;color:#151617;box-shadow:0 18px 54px rgba(44,39,27,.10)}
.room-list div:nth-child(1){background:#dceee4}.room-list div:nth-child(2){background:#efe9c9}.room-list div:nth-child(3){background:#dfe9f3}.room-list div:nth-child(4){background:#ead7d4}
.dark-caption{position:absolute;z-index:13;color:#f5eedb}.dark-caption b{display:block;margin-bottom:18px;color:#d5b66b;font-size:34px}.dark-caption span{display:block;font-size:27px;line-height:1.35}
.hero .copy{top:88px}.hero .title{font-size:${isZh ? 96 : 84}px}.hero .disc{width:1210px;height:1210px;left:-385px;top:770px}.hero .device{right:58px;top:765px;width:620px}.hero .coin{left:426px;top:1295px;width:112px;height:112px}
.compass .device{left:86px;top:725px;width:690px}.compass .metric.one{right:86px;top:835px}.compass .metric.two{right:86px;top:1085px}.compass .coin{right:198px;top:1348px;width:82px;height:82px}.compass .dark-caption{display:none}
.grid .device{right:62px;top:760px;width:535px}.grid .grid-map{left:105px;top:1025px}.grid .note-card{left:105px;top:1705px;width:500px}
.plan .device{right:72px;top:1120px;width:590px}.plan .plan-map{left:104px;top:950px}.plan .needle{left:360px;top:778px}.plan .note-card{left:628px;top:922px;width:470px}
.rooms .device{right:64px;top:740px;width:600px}.rooms .room-list{left:96px;top:940px}.rooms .copy{width:720px}
.records .copy{top:96px}.records .device.one{right:82px;top:760px;width:565px}.records .device.two{left:88px;top:1085px;width:455px}.records .dark-caption{left:96px;bottom:285px;width:720px}.records .proof{bottom:136px}
</style>
</head>
<body>
<main class="poster ${bodyClass}">
  <div class="brand-watermark"></div>
  <div class="ring r1"></div><div class="ring r2"></div><div class="ring r3"></div>
  <div class="axis-h"></div><div class="axis-v"></div>
  <section class="copy">
    <div class="seq">${data.frameNo}</div>
    <div class="eyebrow">${escapeHtml(data.copy.eyebrow)}</div>
    <div class="title">${title}</div>
    <div class="sub">${escapeHtml(data.copy.sub)}</div>
  </section>
  ${renderFrameBody(data, { source, alt, isZh })}
  <section class="proof">
    <div class="mark"></div>
    <div>${escapeHtml(data.copy.proof)}</div>
  </section>
</main>
</body>
</html>`;
}

function device(src, classes = "") {
  return `<div class="device ${classes}"><div class="screen"><img src="${src}"></div><div class="shine"></div></div>`;
}

function renderFrameBody(data, ctx) {
  const { source, alt, isZh } = ctx;
  if (data.kind === "hero") {
    return `<div class="disc"></div>${device(source, "tilt-left")}<div class="coin"></div>`;
  }
  if (data.kind === "compass") {
    return `${device(source)}<div class="metric one"><b>182.5°</b><span>${isZh ? "地盘读数" : "Earth plate"}</span></div><div class="metric two"><b>190.0°</b><span>${isZh ? "空间参考" : "Space plate"}</span></div><div class="coin"></div>`;
  }
  if (data.kind === "grid") {
    return `${device(source, "tilt-right")}<div class="grid-map">${[1, 2, 3, 4, 5, 6, 7, 8, 9].map((n) => `<div>${n}</div>`).join("")}</div><div class="note-card"><b>${isZh ? "一屏整理" : "One calm map"}</b><span>${isZh ? "九宫、年度与阶段参考集中呈现。" : "Grid, annual, and period references stay together."}</span></div>`;
  }
  if (data.kind === "plan") {
    return `${device(source, "tilt-left")}<div class="plan-map"><div></div><div></div><div></div><div></div></div><div class="needle"></div><div class="note-card"><b>${isZh ? "立极点" : "Center point"}</b><span>${isZh ? "方向与房间关系同步标记。" : "Direction and room relationship align together."}</span></div>`;
  }
  if (data.kind === "rooms") {
    const rooms = isZh ? ["卧室", "书房", "客厅", "玄关"] : ["Bedroom", "Study", "Living", "Entry"];
    return `${device(source, "tilt-right")}<div class="room-list">${rooms.map((room) => `<div>${room}</div>`).join("")}</div>`;
  }
  return `${device(source, "one tilt-right")}${device(alt, "two tilt-left")}<div class="dark-caption"><b>${isZh ? "隐私与控制" : "Privacy and control"}</b><span>${isZh ? "记录留在本机，需要交接时再生成分享卡。" : "Records stay local until you choose to create a report card."}</span></div>`;
}

function writeHtml(locale, index) {
  const data = dataFor(locale, index);
  const html = renderHtml(data);
  const file = path.join(campaignDir, `${locale}-${data.frameNo}.html`);
  fs.writeFileSync(file, html);
  return { htmlFile: file, outFile: path.join(locale === "zh" ? zhDir : enDir, data.filename) };
}

function runShot(htmlPath, outPath, windowSize = `${W},${H}`) {
  const profile = path.join(chromeProfileRoot, outPath.replace(/[^a-zA-Z0-9]+/g, "-"));
  fs.rmSync(profile, { recursive: true, force: true });
  fs.rmSync(outPath, { force: true });
  mkdirp(profile);
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
    "--timeout=1500",
    `--user-data-dir=${profile}`,
    `--window-size=${windowSize}`,
    `--screenshot=${outPath}`,
    fileUrl(htmlPath),
  ];
  try {
    execFileSync(chromeBin, args, { stdio: "ignore", timeout: 10000 });
  } catch (error) {
    if (!validPng(outPath)) throw error;
  } finally {
    try {
      execFileSync("pkill", ["-f", profile], { stdio: "ignore" });
    } catch {}
  }
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

function contactSheet(files, outPath) {
  const thumbW = 360;
  const thumbH = Math.round((thumbW * H) / W);
  const gap = 22;
  const html = `<!doctype html><meta charset="utf-8"><style>
body{margin:0;background:#e7e4dc}.sheet{display:grid;grid-template-columns:repeat(3,${thumbW}px);gap:${gap}px;padding:${gap}px}
img{width:${thumbW}px;height:${thumbH}px;object-fit:cover;display:block;background:white}
</style><div class="sheet">${files.map((file) => `<img src="${fileUrl(file)}">`).join("")}</div>`;
  const htmlPath = outPath.replace(/\.jpg$/, ".html");
  fs.writeFileSync(htmlPath, html);
  runShot(htmlPath, outPath, `${thumbW * 3 + gap * 4},${thumbH * 2 + gap * 3}`);
}

function main() {
  [campaignDir, zhDir, enDir].forEach(mkdirp);

  for (const asset of Object.values(assets)) {
    if (!fs.existsSync(asset)) {
      throw new Error(`Missing asset: ${asset}`);
    }
  }

  const outputs = { zh: [], en: [] };
  for (const locale of ["zh", "en"]) {
    for (let index = 0; index < frames.length; index++) {
      const { htmlFile, outFile } = writeHtml(locale, index);
      runShot(htmlFile, outFile);
      outputs[locale].push(outFile);
    }
  }

  contactSheet(outputs.zh, path.join(campaignDir, "zh-contactsheet.jpg"));
  contactSheet(outputs.en, path.join(campaignDir, "en-contactsheet.jpg"));
  console.log(`Wrote ${outputs.zh.length} zh-Hans screenshots to ${zhDir}`);
  console.log(`Wrote ${outputs.en.length} en-US screenshots to ${enDir}`);
  console.log(`Contact sheets:`);
  console.log(`- ${path.join(campaignDir, "zh-contactsheet.jpg")}`);
  console.log(`- ${path.join(campaignDir, "en-contactsheet.jpg")}`);
}

main();
