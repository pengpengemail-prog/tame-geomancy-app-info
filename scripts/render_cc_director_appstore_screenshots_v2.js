#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const { execFileSync } = require("child_process");

const root = path.resolve(__dirname, "..");
const workspace = path.resolve(root, "..");
const frameRoot = path.join(workspace, "算命", "LumaBaziIOS", "node_modules", "appshot-cli", "frames");
const campaign = "cc-director-v2";
const outRoot = path.join(root, "AppStoreAssets");
const campaignDir = path.join(outRoot, "generated-marketing", campaign);
const zhDir = path.join(outRoot, "zh-Hans-cc-director-v2");
const enDir = path.join(outRoot, "en-US-cc-director-v2");
const chromeBin = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const chromeProfileRoot = path.join(root, "build", "chrome-appstore-render-profile", campaign);

const W = 1284;
const H = 2778;

const framePng = path.join(frameRoot, "iPhone 16 Pro Max Portrait.png");
const iconPng = path.join(root, "Design", "app-icon-original-geomancy-1024.png");

const assets = {
  frame: framePng,
  icon: iconPng,
  heroBg: path.join(root, "AppStoreAssets", "background-source", "01-space-ring-mountains.jpg"),
  linenBg: path.join(root, "AppStoreAssets", "background-source", "03-silver-flow.jpg"),
  goldBg: path.join(root, "AppStoreAssets", "background-source", "06-gold-crease.jpg"),
  glassBg: path.join(root, "AppStoreAssets", "background-source", "07-glass-forest-bubble.jpg"),
  galaxyBg: path.join(root, "AppStoreAssets", "background-source", "10-galaxy-spiral.jpg"),
  chromeBg: path.join(root, "AppStoreAssets", "background-source", "09-chrome-sphere.jpg"),
  compassZh: path.join(root, "VerificationShots", "compass_pointer_to_marked_ring.png"),
  compassEn: path.join(root, "VerificationShots", "compass_red_pointer_arrow_unified.png"),
  readingZh: path.join(root, "VerificationShots", "compass_red_pointer_arrow_unified.png"),
  readingEn: path.join(root, "VerificationShots", "compass_red_pointer_arrow_unified.png"),
  gridZh: path.join(root, "VerificationShots", "overview-nine-palace-2026-05-22.png"),
  gridEn: path.join(root, "VerificationShots", "en-US", "flying-star-demo-2.png"),
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
      mode: "dark",
      bg: "heroBg",
      source: "compassZh",
      title: ["精准测向", "一眼定局"],
      eyebrow: "探觅·空间罗盘",
      sub: "把罗盘、坐向与空间关系收束成一张现场判断图。",
      badge: "空间坐向",
      detail: "185° S",
      scene: "hero",
    },
    {
      mode: "dark",
      bg: "goldBg",
      source: "readingZh",
      title: ["专业罗盘", "稳定定位"],
      eyebrow: "现场测向",
      sub: "红针、刻度、角度和参考信息保持同一视线。",
      badge: "双盘读数",
      detail: "地盘 182.5° / 空间 190°",
      scene: "single",
    },
    {
      mode: "light",
      bg: "linenBg",
      source: "gridZh",
      title: ["格局参考", "清晰归位"],
      eyebrow: "九宫与年度参考",
      sub: "把方位、年度和阶段关系集中整理，复杂空间不再散乱。",
      badge: "一屏理顺",
      detail: "方位 / 年度 / 阶段",
      scene: "split",
    },
    {
      mode: "light",
      bg: "glassBg",
      source: "planZh",
      title: ["户型落点", "直接看图"],
      eyebrow: "平面关系",
      sub: "中心点、开口与功能区落到真实户型里，判断更直观。",
      badge: "立极点",
      detail: "中心 / 开口 / 房间",
      scene: "map",
    },
    {
      mode: "light",
      bg: "chromeBg",
      source: "roomZh",
      title: ["卧室书房", "分开判断"],
      eyebrow: "空间分组",
      sub: "每个房间独立记录，现场复盘和后续整理都更稳。",
      badge: "房间分组",
      detail: "卧室 / 书房 / 客厅 / 玄关",
      scene: "rooms",
    },
    {
      mode: "dark",
      bg: "galaxyBg",
      source: "reportZh",
      source2: "planZh",
      title: ["本地保存", "按需分享"],
      eyebrow: "记录与报告",
      sub: "测向、户型和备注留在本机，需要沟通时再生成报告。",
      badge: "隐私优先",
      detail: "无需登录 / 本地记录",
      scene: "final",
    },
  ],
  en: [
    {
      mode: "dark",
      bg: "heroBg",
      source: "compassEn",
      title: ["Precise Orientation", "At A Glance"],
      eyebrow: "TAME Space Compass",
      sub: "Bring compass, direction, and spatial context into one field view.",
      badge: "Spatial read",
      detail: "185° S",
      scene: "hero",
    },
    {
      mode: "dark",
      bg: "goldBg",
      source: "readingEn",
      title: ["A Steady Compass", "For Field Work"],
      eyebrow: "On-site reading",
      sub: "Needle, angle, and reference notes stay together while you read.",
      badge: "Dual read",
      detail: "Earth 182.5° / Space 190°",
      scene: "single",
    },
    {
      mode: "light",
      bg: "linenBg",
      source: "gridEn",
      title: ["Organize Layouts", "With Clarity"],
      eyebrow: "Grid and annual reference",
      sub: "Keep direction, annual, and period references in one calm view.",
      badge: "One clean map",
      detail: "Direction / Year / Period",
      scene: "split",
    },
    {
      mode: "light",
      bg: "glassBg",
      source: "planEn",
      title: ["Map Direction", "To Real Rooms"],
      eyebrow: "Plan alignment",
      sub: "Place center points, openings, and room zones directly on a plan.",
      badge: "Center point",
      detail: "Center / Opening / Rooms",
      scene: "map",
    },
    {
      mode: "light",
      bg: "chromeBg",
      source: "roomEn",
      title: ["Review Each Room", "Separately"],
      eyebrow: "Room groups",
      sub: "Keep bedroom, study, living, and entry notes organized by space.",
      badge: "Room groups",
      detail: "Bedroom / Study / Living / Entry",
      scene: "rooms",
    },
    {
      mode: "dark",
      bg: "galaxyBg",
      source: "reportEn",
      source2: "planEn",
      title: ["Save Locally", "Share When Ready"],
      eyebrow: "Records and reports",
      sub: "Compass checks, plans, and notes stay on device until you share.",
      badge: "Privacy first",
      detail: "No login / Local records",
      scene: "final",
    },
  ],
};

function mkdirp(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

function fileUrl(file) {
  return `file://${path.resolve(file).split(path.sep).map(encodeURIComponent).join("/")}`;
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

function deviceHtml(src, cls = "", scale = 1) {
  const style = `--device-scale:${scale}`;
  return `
    <div class="device-real ${cls}" style="${style}">
      <div class="device-shadow"></div>
      <div class="device-body">
        <img class="device-screen" src="${fileUrl(src)}">
        <img class="device-frame" src="${fileUrl(framePng)}">
        <div class="device-glass"></div>
      </div>
      <div class="device-reflection">
        <div class="reflection-mask">
          <img class="device-screen reflection-screen" src="${fileUrl(src)}">
          <img class="device-frame reflection-frame" src="${fileUrl(framePng)}">
        </div>
      </div>
    </div>`;
}

function focusCompass(data) {
  return `
    <div class="compass-disc">
      <img src="${fileUrl(assets[data.source])}">
      <div class="compass-glass"></div>
    </div>`;
}

function renderDecor(data, locale, index) {
  const seq = String(index + 1).padStart(2, "0");
  const title = data.title.map((line) => `<span>${escapeHtml(line)}</span>`).join("");
  return `
    <div class="noise"></div>
    <div class="brand-orbit"></div>
    <div class="orbit orbit-a"></div>
    <div class="orbit orbit-b"></div>
    <div class="axis axis-h"></div>
    <div class="axis axis-v"></div>
    <section class="copy">
      <div class="seq"><span>${seq}</span></div>
      <div class="eyebrow">${escapeHtml(data.eyebrow)}</div>
      <h1>${title}</h1>
      <p>${escapeHtml(data.sub)}</p>
    </section>
    <section class="proof">
      <img src="${fileUrl(iconPng)}">
      <div>
        <b>${escapeHtml(data.badge)}</b>
        <span>${escapeHtml(data.detail)}</span>
      </div>
    </section>`;
}

function sceneBody(data, locale, index) {
  const source = assets[data.source];
  const source2 = data.source2 ? assets[data.source2] : source;
  if (data.scene === "hero") {
    return `
      <div class="stage-plinth"></div>
      ${focusCompass(data)}
      ${deviceHtml(source, "hero-phone tilt-back", 0.58)}
      <div class="hero-readout"><b>${locale === "zh" ? "185° S" : "185° S"}</b><span>${locale === "zh" ? "空间方位 · 南" : "Spatial direction · South"}</span></div>`;
  }
  if (data.scene === "single") {
    return `
      ${deviceHtml(source, "single-phone tilt-front", 0.68)}
      <div class="reading-card card-a"><b>182.5°</b><span>${locale === "zh" ? "地盘读数" : "Earth plate"}</span></div>
      <div class="reading-card card-b"><b>190.0°</b><span>${locale === "zh" ? "空间参考" : "Space reference"}</span></div>
      <div class="gold-token"></div>`;
  }
  if (data.scene === "split") {
    const labels = locale === "zh" ? ["东", "南", "西", "北", "中", "宅"] : ["East", "South", "West", "North", "Center", "Home"];
    return `
      ${deviceHtml(source, "split-phone tilt-back", 0.64)}
      <div class="grid-block">${labels.map((label) => `<div>${escapeHtml(label)}</div>`).join("")}</div>
      <div class="callout-panel"><b>${locale === "zh" ? "从方位到判断" : "From direction to read"}</b><span>${locale === "zh" ? "把格局线索整理进一个稳定视图。" : "Keep spatial clues in a steady view."}</span></div>`;
  }
  if (data.scene === "map") {
    return `
      ${deviceHtml(source, "map-phone tilt-front", 0.66)}
      <div class="floor-plan"><div></div><div></div><div></div><div></div><i></i></div>
      <div class="red-needle"></div>
      <div class="map-label"><b>${locale === "zh" ? "立极点" : "Center point"}</b><span>${locale === "zh" ? "方向落到房间关系里" : "Direction mapped to room zones"}</span></div>`;
  }
  if (data.scene === "rooms") {
    const rooms = locale === "zh" ? ["卧室", "书房", "客厅", "玄关"] : ["Bedroom", "Study", "Living", "Entry"];
    return `
      ${deviceHtml(source, "rooms-phone tilt-back", 0.66)}
      <div class="room-stack">${rooms.map((room, i) => `<div style="--i:${i}">${escapeHtml(room)}<span></span></div>`).join("")}</div>
      <div class="soft-lens"></div>`;
  }
  return `
    ${deviceHtml(source, "final-phone-one tilt-back", 0.62)}
    ${deviceHtml(source2, "final-phone-two tilt-front", 0.48)}
    <div class="closing-mark"><img src="${fileUrl(iconPng)}"><b>${locale === "zh" ? "探觅·空间罗盘" : "TAME Space Compass"}</b><span>${locale === "zh" ? "空间参考工具" : "Spatial reference tool"}</span></div>`;
}

function renderHtml(data, locale, index) {
  const bg = assets[data.bg];
  const langClass = locale === "zh" ? "zh" : "en";
  return `<!doctype html>
<html lang="${locale === "zh" ? "zh-Hans" : "en"}">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=${W}, height=${H}, initial-scale=1">
<style>
*{box-sizing:border-box}
html,body{margin:0;width:${W}px;height:${H}px;overflow:hidden}
body{font-family:-apple-system,BlinkMacSystemFont,"SF Pro Display","PingFang SC","Hiragino Sans GB",sans-serif}
.poster{position:relative;width:${W}px;height:${H}px;overflow:hidden;background:#f7f4ea;color:#151614}
.poster:before{content:"";position:absolute;inset:-18px;background:url("${fileUrl(bg)}") center/cover no-repeat;filter:saturate(.9) contrast(1.04);transform:scale(1.04)}
.poster:after{content:"";position:absolute;inset:0;background:
  radial-gradient(800px 680px at 76% 18%,rgba(219,184,105,.30),transparent 66%),
  radial-gradient(760px 650px at 18% 64%,rgba(255,255,255,.72),transparent 70%),
  linear-gradient(180deg,rgba(250,248,241,.84),rgba(241,235,220,.50) 42%,rgba(15,20,18,.10));}
.poster.dark{background:#13241e;color:#fbf4e2}
.poster.dark:before{filter:saturate(.8) contrast(1.1) brightness(.72)}
.poster.dark:after{background:
  radial-gradient(920px 720px at 74% 22%,rgba(209,169,86,.30),transparent 68%),
  radial-gradient(760px 720px at 14% 72%,rgba(255,255,255,.08),transparent 72%),
  linear-gradient(180deg,rgba(12,23,20,.88),rgba(20,38,32,.62) 48%,rgba(10,15,14,.86));}
.noise{position:absolute;z-index:2;inset:0;opacity:.16;background-image:radial-gradient(rgba(20,18,13,.30) .55px,transparent .75px);background-size:7px 7px;mix-blend-mode:multiply}
.dark .noise{opacity:.20;background-image:radial-gradient(rgba(255,246,222,.34) .5px,transparent .75px);mix-blend-mode:screen}
.brand-orbit{position:absolute;z-index:3;right:-270px;top:-245px;width:920px;height:920px;background:url("${fileUrl(iconPng)}") center/contain no-repeat;opacity:.08;filter:grayscale(1)}
.dark .brand-orbit{opacity:.12;filter:grayscale(1) invert(1)}
.orbit{position:absolute;z-index:3;border-radius:50%;border:1.5px solid rgba(163,140,91,.20)}
.dark .orbit{border-color:rgba(230,199,123,.22)}
.orbit-a{width:1200px;height:1200px;right:-420px;top:320px}
.orbit-b{width:760px;height:760px;left:-300px;bottom:410px}
.axis{position:absolute;z-index:3;background:rgba(54,48,36,.13)}
.dark .axis{background:rgba(241,225,178,.18)}
.axis-h{height:1px;left:86px;right:86px;top:1400px}
.axis-v{width:1px;top:150px;bottom:210px;left:50%}
.copy{position:absolute;z-index:20;left:88px;top:92px;width:900px}
.seq{display:flex;align-items:center;gap:22px;color:#b8934f;font-weight:800;font-size:28px;margin-bottom:28px}
.seq:after{content:"";display:block;width:122px;height:2px;background:#b8934f}
.eyebrow{color:#b8934f;font-weight:800;font-size:25px;margin-bottom:34px}
h1{margin:0;font-size:90px;line-height:.99;letter-spacing:0;font-weight:850;color:#151614}
.en h1{font-size:76px;line-height:1.02}
h1 span{display:block}
p{margin:30px 0 0;max-width:760px;color:#5e625d;font-size:31px;line-height:1.38;font-weight:500}
.dark h1,.dark p{color:#fbf4e2}.dark p{color:#e8deca}.dark .seq,.dark .eyebrow{color:#d6b66c}.dark .seq:after{background:#d6b66c}
.proof{position:absolute;z-index:24;left:88px;bottom:118px;display:flex;align-items:center;gap:22px}
.proof img{width:76px;height:76px;border-radius:20px;box-shadow:0 18px 42px rgba(26,22,16,.20)}
.proof b,.proof span{display:block}.proof b{color:#151614;font-size:27px}.proof span{margin-top:8px;color:#666862;font-size:22px;font-weight:650}
.dark .proof b{color:#fbf4e2}.dark .proof span{color:#ded3bb}
.device-real{position:absolute;z-index:14;width:calc(1470px * var(--device-scale));height:calc(3000px * var(--device-scale));transform-origin:center center}
.device-body{position:absolute;inset:0}
.device-shadow{position:absolute;inset:3.2% 2.8%;border-radius:12%/6%;background:rgba(0,0,0,.52);filter:blur(58px);transform:translateY(56px) scale(.96)}
.device-screen{position:absolute;left:5.102%;top:2.2%;width:89.796%;height:95.6%;object-fit:cover;border-radius:7.3%/3.55%;filter:saturate(1.02) contrast(1.03)}
.device-frame{position:absolute;inset:0;width:100%;height:100%;object-fit:contain;filter:drop-shadow(0 22px 50px rgba(0,0,0,.18))}
.device-glass{position:absolute;left:5.102%;top:2.2%;width:89.796%;height:95.6%;border-radius:7.3%/3.55%;background:linear-gradient(112deg,rgba(255,255,255,.30),transparent 27%,rgba(255,255,255,.10) 61%,transparent);mix-blend-mode:screen;pointer-events:none}
.device-reflection{position:absolute;left:0;right:0;top:92%;height:34%;transform:scaleY(-1);opacity:.24;filter:blur(.7px)}
.reflection-mask{position:absolute;inset:0;overflow:hidden;mask-image:linear-gradient(to bottom,rgba(0,0,0,.48),transparent 74%);-webkit-mask-image:linear-gradient(to bottom,rgba(0,0,0,.48),transparent 74%)}
.reflection-screen,.reflection-frame{position:absolute}
.tilt-front{transform:rotate(3.2deg)}.tilt-back{transform:rotate(-4.4deg)}
.stage-plinth{position:absolute;z-index:8;left:120px;top:1905px;width:1050px;height:300px;border-radius:50%;background:radial-gradient(ellipse at center,rgba(241,219,164,.36),rgba(0,0,0,.10) 46%,transparent 72%);filter:blur(3px)}
.compass-disc{position:absolute;z-index:16;left:126px;top:975px;width:670px;height:670px;border-radius:50%;padding:31px;background:radial-gradient(circle at 34% 26%,#fff7d9,#d6b66c 22%,#4d473a 66%,#191b19 100%);box-shadow:0 56px 140px rgba(0,0,0,.35),inset 0 0 0 2px rgba(255,244,210,.42)}
.compass-disc img{width:100%;height:100%;object-fit:cover;border-radius:50%;box-shadow:inset 0 0 0 3px rgba(255,255,255,.38)}
.compass-glass{position:absolute;inset:40px;border-radius:50%;background:linear-gradient(128deg,rgba(255,255,255,.32),transparent 38%,rgba(255,255,255,.12));mix-blend-mode:screen}
.hero-phone{right:80px;top:850px}.hero-readout{position:absolute;z-index:22;left:164px;top:1655px;width:500px;padding:28px 34px;border-radius:26px;background:rgba(18,24,21,.78);border:1px solid rgba(220,185,106,.44);box-shadow:0 28px 70px rgba(0,0,0,.26);backdrop-filter:blur(14px);color:#fbf4e2}
.hero-readout b{font-size:46px}.hero-readout span{display:block;margin-top:8px;font-size:24px;color:#d9ceb6;font-weight:650}
.single-phone{right:96px;top:865px}.reading-card{position:absolute;z-index:23;left:92px;width:360px;padding:30px 34px;border-radius:30px;background:rgba(255,250,236,.75);border:1px solid rgba(222,190,118,.48);box-shadow:0 28px 88px rgba(31,25,14,.19);backdrop-filter:blur(18px)}
.reading-card b{display:block;font-size:44px;color:#151614}.reading-card span{display:block;margin-top:12px;color:#656862;font-size:22px;font-weight:700}.card-a{top:960px}.card-b{top:1215px}
.gold-token{position:absolute;z-index:24;left:385px;top:1445px;width:88px;height:88px;border-radius:50%;background:radial-gradient(circle at 35% 30%,#fff8dc,#deb75f 34%,#72531f 78%);box-shadow:0 18px 54px rgba(82,55,12,.30)}
.split-phone{right:96px;top:930px}.grid-block{position:absolute;z-index:22;left:94px;top:910px;display:grid;grid-template-columns:repeat(3,152px);gap:13px}
.grid-block div{height:132px;border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:34px;font-weight:850;color:#151614;border:1px solid rgba(72,61,38,.20)}
.grid-block div:nth-child(3n+1){background:#eee2bb}.grid-block div:nth-child(3n+2){background:#dcebe2}.grid-block div:nth-child(3n){background:#ead7d4}
.callout-panel{position:absolute;z-index:22;left:94px;top:1505px;width:480px;padding:32px 36px;border-radius:30px;background:rgba(255,255,255,.68);border:1px solid rgba(190,164,96,.34);box-shadow:0 28px 80px rgba(43,38,25,.14);backdrop-filter:blur(18px)}
.callout-panel b{display:block;font-size:30px;color:#ad8e4e}.callout-panel span{display:block;margin-top:13px;font-size:23px;line-height:1.35;color:#62645f;font-weight:650}
.map-phone{right:98px;top:1010px}.floor-plan{position:absolute;z-index:20;left:96px;top:920px;width:520px;height:520px;display:grid;grid-template-columns:1fr 1fr;grid-template-rows:1fr 1fr;border:2px solid rgba(61,55,39,.52);box-shadow:0 28px 80px rgba(38,31,16,.16)}
.floor-plan div{border:1px solid rgba(61,55,39,.36)}.floor-plan div:nth-child(1){background:#dcebe2}.floor-plan div:nth-child(2){background:#eee1bb}.floor-plan div:nth-child(3){background:#dfe9f2}.floor-plan div:nth-child(4){background:#ead7d4}.floor-plan i{position:absolute;left:50%;top:50%;width:28px;height:28px;border-radius:50%;background:#151614;transform:translate(-50%,-50%);box-shadow:0 0 0 14px rgba(177,42,38,.10)}
.red-needle{position:absolute;z-index:23;left:348px;top:778px;width:8px;height:410px;background:#b32927;box-shadow:0 16px 32px rgba(135,25,22,.22)}
.red-needle:before{content:"";position:absolute;left:50%;top:-54px;transform:translateX(-50%);border-left:32px solid transparent;border-right:32px solid transparent;border-bottom:74px solid #b32927}
.map-label{position:absolute;z-index:24;left:585px;top:900px;width:430px;padding:30px 34px;border-radius:30px;background:rgba(255,255,255,.70);border:1px solid rgba(190,164,96,.36);box-shadow:0 28px 80px rgba(43,38,25,.14);backdrop-filter:blur(18px)}
.map-label b{display:block;color:#ad8e4e;font-size:30px}.map-label span{display:block;margin-top:12px;color:#62645f;font-size:23px;font-weight:650}
.rooms-phone{right:94px;top:890px}.room-stack{position:absolute;z-index:22;left:92px;top:915px;display:flex;flex-direction:column;gap:25px}
.room-stack div{position:relative;width:365px;padding:28px 32px;border-radius:24px;background:#fff;border:1px solid rgba(190,164,96,.28);box-shadow:0 18px 54px rgba(43,38,25,.11);font-size:31px;font-weight:850;color:#151614;transform:translateX(calc(var(--i) * 22px))}
.room-stack div:nth-child(1){background:#dceee4}.room-stack div:nth-child(2){background:#efe8c8}.room-stack div:nth-child(3){background:#dfe9f3}.room-stack div:nth-child(4){background:#ead7d4}
.room-stack span{position:absolute;right:26px;top:50%;width:68px;height:2px;background:#b8934f}
.soft-lens{position:absolute;z-index:8;left:-60px;bottom:170px;width:760px;height:760px;border-radius:50%;background:radial-gradient(circle,rgba(255,255,255,.70),rgba(219,190,120,.16) 46%,transparent 70%);filter:blur(3px)}
.final-phone-one{right:104px;top:850px}.final-phone-two{left:95px;top:1150px}.closing-mark{position:absolute;z-index:25;left:90px;bottom:315px;width:670px;color:#fbf4e2}
.closing-mark img{width:102px;height:102px;border-radius:28px;box-shadow:0 22px 60px rgba(0,0,0,.28);margin-bottom:26px}
.closing-mark b{display:block;font-size:42px}.closing-mark span{display:block;margin-top:12px;font-size:26px;color:#ded2bb}
</style>
</head>
<body>
<main class="poster ${data.mode} ${langClass}">
  ${renderDecor(data, locale, index)}
  ${sceneBody(data, locale, index)}
</main>
</body>
</html>`;
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
    "--timeout=2500",
    `--user-data-dir=${profile}`,
    `--window-size=${windowSize}`,
    `--screenshot=${outPath}`,
    fileUrl(htmlPath),
  ];
  try {
    execFileSync(chromeBin, args, { stdio: "ignore", timeout: 14000 });
  } catch (error) {
    if (!validPng(outPath)) throw error;
  } finally {
    try {
      execFileSync("pkill", ["-f", profile], { stdio: "ignore" });
    } catch {}
  }
}

function contactSheet(files, outPath) {
  const script = `
from PIL import Image
from pathlib import Path
files = ${JSON.stringify(files)}
out = Path(${JSON.stringify(outPath)})
thumb_w = 360
thumb_h = round(thumb_w * ${H} / ${W})
gap = 22
sheet = Image.new("RGB", (thumb_w * 3 + gap * 4, thumb_h * 2 + gap * 3), "#e7e4dc")
for i, file in enumerate(files):
    im = Image.open(file).convert("RGB").resize((thumb_w, thumb_h), Image.Resampling.LANCZOS)
    x = gap + (i % 3) * (thumb_w + gap)
    y = gap + (i // 3) * (thumb_h + gap)
    sheet.paste(im, (x, y))
out.parent.mkdir(parents=True, exist_ok=True)
sheet.save(out, quality=92)
`;
  execFileSync("python3", ["-c", script], { stdio: "ignore" });
}

function writeHtml(locale, index) {
  const data = copy[locale][index];
  const html = renderHtml(data, locale, index);
  const htmlFile = path.join(campaignDir, `${locale}-${String(index + 1).padStart(2, "0")}.html`);
  const outFile = path.join(locale === "zh" ? zhDir : enDir, finalNames[index]);
  fs.writeFileSync(htmlFile, html);
  return { htmlFile, outFile };
}

function main() {
  [campaignDir, zhDir, enDir].forEach(mkdirp);
  for (const [key, file] of Object.entries(assets)) {
    if (!fs.existsSync(file)) throw new Error(`Missing asset ${key}: ${file}`);
  }
  if (!fs.existsSync(chromeBin)) throw new Error(`Missing Chrome binary: ${chromeBin}`);

  const outputs = { zh: [], en: [] };
  for (const locale of ["zh", "en"]) {
    for (let index = 0; index < finalNames.length; index += 1) {
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
