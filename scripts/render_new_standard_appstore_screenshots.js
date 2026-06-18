#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const { execFileSync } = require("child_process");

const root = path.resolve(__dirname, "..");
const outRoot = path.join(root, "AppStoreAssets");
const campaign = "new-standard-r1";
const htmlDir = path.join(outRoot, "generated-marketing", campaign, "html");
const sheetDir = path.join(outRoot, "generated-marketing", campaign);
const zhDir = path.join(outRoot, "zh-Hans-new-standard-r1");
const enDir = path.join(outRoot, "en-US-new-standard-r1");
const chromeProfileRoot = path.join(root, "build", "chrome-appstore-render-profile", campaign);
const chromeBin = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";

const W = 1284;
const H = 2778;

const assets = {
  icon: path.join(root, "Design", "app-icon-original-geomancy-1024.png"),
  bgSilver: path.join(root, "AppStoreAssets", "background-source", "03-silver-flow.jpg"),
  bgGold: path.join(root, "AppStoreAssets", "background-source", "06-gold-crease.jpg"),
  bgGlass: path.join(root, "AppStoreAssets", "background-source", "07-glass-forest-bubble.jpg"),
  bgChrome: path.join(root, "AppStoreAssets", "background-source", "09-chrome-sphere.jpg"),
  bgSpace: path.join(root, "AppStoreAssets", "background-source", "01-space-ring-mountains.jpg"),
  bgGalaxy: path.join(root, "AppStoreAssets", "background-source", "10-galaxy-spiral.jpg"),
  compassZh: path.join(root, "VerificationShots", "compass_pointer_to_marked_ring.png"),
  compassEn: path.join(root, "VerificationShots", "compass_red_pointer_arrow_unified.png"),
  overviewZh: path.join(root, "VerificationShots", "overview-nine-palace-2026-05-22.png"),
  overviewEn: path.join(root, "VerificationShots", "en-US", "flying-star-demo-2.png"),
  planZh: path.join(root, "VerificationShots", "analysis-yanggong-entry-2026-05-22.png"),
  planEn: path.join(root, "VerificationShots", "en-US", "annual-demo-3.png"),
  roomZh: path.join(root, "VerificationShots", "yanggong-fenjin-clean.png"),
  roomEn: path.join(root, "VerificationShots", "en-US", "annual-demo-3.png"),
  reportZh: path.join(root, "VerificationShots", "overview-graphical-entry-2026-05-22.png"),
  reportEn: path.join(root, "VerificationShots", "en-US", "annual-demo-3.png"),
};

const finalNames = [
  "01-core-orientation.png",
  "02-steady-compass.png",
  "03-layout-clarity.png",
  "04-plan-alignment.png",
  "05-room-review.png",
  "06-local-report.png",
];

const copy = {
  zh: [
    {
      bg: "bgSilver",
      source: "compassZh",
      eyebrow: "罗盘坐向 · 户型参考",
      title: ["看清坐向", "与空间关系"],
      sub: "把罗盘读数、户型落点与本地记录收进一张清晰的现场参考图。",
      badges: ["离线使用", "本地记录", "一次性解锁报告"],
      metricLabel: "当前方位参考",
      metric: "185° S",
      scene: "hero",
      mood: "light",
    },
    {
      bg: "bgGold",
      source: "compassZh",
      eyebrow: "现场测向",
      title: ["专业罗盘", "稳定定位"],
      sub: "红针、刻度、角度和参考信息保持同一视线，现场读数更稳。",
      badges: ["红针读数", "双盘参考", "精密刻度"],
      metricLabel: "读数结构",
      metric: "182.5° / 190°",
      scene: "single",
      mood: "dark",
    },
    {
      bg: "bgGlass",
      source: "overviewZh",
      eyebrow: "九宫与年度参考",
      title: ["格局参考", "清晰归位"],
      sub: "把方位、年度与阶段线索集中整理，复杂空间也能快速复盘。",
      badges: ["九宫视图", "年度参考", "阶段整理"],
      metricLabel: "参考维度",
      metric: "方位 / 年度 / 阶段",
      scene: "grid",
      mood: "light",
    },
    {
      bg: "bgChrome",
      source: "planZh",
      eyebrow: "户型关系",
      title: ["户型落点", "直接看图"],
      sub: "中心点、开口与功能区落到真实户型里，现场判断更直观。",
      badges: ["立极点", "开口方向", "功能区"],
      metricLabel: "空间锚点",
      metric: "中心 / 开口 / 房间",
      scene: "plan",
      mood: "light",
    },
    {
      bg: "bgSilver",
      source: "roomZh",
      eyebrow: "空间分组",
      title: ["卧室书房", "分开判断"],
      sub: "每个房间独立记录，现场复盘和后续整理都更有秩序。",
      badges: ["卧室", "书房", "客厅", "玄关"],
      metricLabel: "记录方式",
      metric: "按房间整理",
      scene: "rooms",
      mood: "light",
    },
    {
      bg: "bgGalaxy",
      source: "reportZh",
      source2: "planZh",
      eyebrow: "记录与报告",
      title: ["本地保存", "按需分享"],
      sub: "测向、户型和备注留在本机，需要沟通时再生成清晰报告。",
      badges: ["无需登录", "本地记录", "报告导出"],
      metricLabel: "隐私口径",
      metric: "Local-first",
      scene: "final",
      mood: "dark",
    },
  ],
  en: [
    {
      bg: "bgSilver",
      source: "compassEn",
      eyebrow: "Compass direction · Plan reference",
      title: ["See Direction", "And Space"],
      sub: "Bring compass readings, room positions, and local notes into one clear field view.",
      badges: ["Offline use", "Local records", "One-time report unlock"],
      metricLabel: "Current reference",
      metric: "185° S",
      scene: "hero",
      mood: "light",
    },
    {
      bg: "bgGold",
      source: "compassEn",
      eyebrow: "On-site reading",
      title: ["A Steady", "Field Compass"],
      sub: "Needle, scale, angle, and reference notes stay together while you read.",
      badges: ["Needle read", "Dual reference", "Clear scale"],
      metricLabel: "Reading structure",
      metric: "182.5° / 190°",
      scene: "single",
      mood: "dark",
    },
    {
      bg: "bgGlass",
      source: "overviewEn",
      eyebrow: "Grid and annual reference",
      title: ["Organize Layouts", "With Clarity"],
      sub: "Keep direction, annual, and period references in one calm review screen.",
      badges: ["Grid view", "Annual reference", "Period notes"],
      metricLabel: "Reference layers",
      metric: "Direction / Year / Period",
      scene: "grid",
      mood: "light",
    },
    {
      bg: "bgChrome",
      source: "planEn",
      eyebrow: "Plan relationship",
      title: ["Map Direction", "To Real Rooms"],
      sub: "Place center points, openings, and room zones directly on a floor plan.",
      badges: ["Center point", "Opening", "Room zones"],
      metricLabel: "Spatial anchors",
      metric: "Center / Opening / Rooms",
      scene: "plan",
      mood: "light",
    },
    {
      bg: "bgSilver",
      source: "roomEn",
      eyebrow: "Room groups",
      title: ["Review Each", "Room Separately"],
      sub: "Keep bedroom, study, living, and entry notes organized by space.",
      badges: ["Bedroom", "Study", "Living", "Entry"],
      metricLabel: "Record mode",
      metric: "Room by room",
      scene: "rooms",
      mood: "light",
    },
    {
      bg: "bgGalaxy",
      source: "reportEn",
      source2: "planEn",
      eyebrow: "Records and reports",
      title: ["Save Locally", "Share When Ready"],
      sub: "Compass checks, plans, and notes stay on device until you choose to export.",
      badges: ["No login", "Local records", "Report export"],
      metricLabel: "Privacy posture",
      metric: "Local-first",
      scene: "final",
      mood: "dark",
    },
  ],
};

function mkdirp(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

function fileUrl(file) {
  return `file://${path.resolve(file).split(path.sep).map(encodeURIComponent).join("/")}`;
}

function esc(value) {
  return String(value).replace(/[&<>"']/g, (char) => ({
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "'": "&#39;",
  }[char]));
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

function phone(src, cls = "") {
  return `
    <div class="device ${cls}">
      <div class="device-metal"></div>
      <div class="screen"><img src="${fileUrl(src)}" alt=""></div>
      <div class="island"><i></i></div>
      <div class="side side-left"></div>
      <div class="side side-right"></div>
      <div class="glass"></div>
    </div>`;
}

function brand(locale) {
  return `
    <div class="brand">
      <img src="${fileUrl(assets.icon)}" alt="">
      <div>
        <b>${locale === "zh" ? "探觅·空间罗盘" : "TAME Space Compass"}</b>
        <span>${locale === "zh" ? "空间与民俗文化参考工具" : "Spatial reference tool"}</span>
      </div>
    </div>`;
}

function copyBlock(item, locale, index) {
  const title = item.title.map((line) => `<span>${esc(line)}</span>`).join("");
  return `
    <section class="copy">
      <div class="sequence">${String(index + 1).padStart(2, "0")}<i></i></div>
      <div class="eyebrow">${esc(item.eyebrow)}</div>
      <h1>${title}</h1>
      <p>${esc(item.sub)}</p>
      <div class="badges">${item.badges.map((badge) => `<span>${esc(badge)}</span>`).join("")}</div>
    </section>
    <aside class="metric">
      <small>${esc(item.metricLabel)}</small>
      <b>${esc(item.metric)}</b>
    </aside>
    <footer>${locale === "zh" ? "仅作空间与民俗文化参考，不承诺现实结果。" : "For spatial and cultural reference only. No outcome is promised."}</footer>`;
}

function scene(item, locale) {
  const src = assets[item.source];
  const src2 = item.source2 ? assets[item.source2] : src;
  if (item.scene === "hero") {
    return `
      <div class="halo compass-halo"><img src="${fileUrl(src)}" alt=""></div>
      ${phone(src, "phone-hero")}
      <div class="readout"><b>185° S</b><span>${locale === "zh" ? "方位参考" : "Direction reference"}</span></div>`;
  }
  if (item.scene === "single") {
    return `
      ${phone(src, "phone-single")}
      <div class="instrument-card card-one"><b>182.5°</b><span>${locale === "zh" ? "地盘读数" : "Earth plate"}</span></div>
      <div class="instrument-card card-two"><b>190°</b><span>${locale === "zh" ? "空间参考" : "Space reference"}</span></div>
      <div class="gold-disc"></div>`;
  }
  if (item.scene === "grid") {
    const cells = locale === "zh" ? ["东", "南", "西", "北", "中", "宅"] : ["East", "South", "West", "North", "Center", "Home"];
    return `
      ${phone(src, "phone-grid")}
      <div class="grid-proof">${cells.map((cell) => `<span>${esc(cell)}</span>`).join("")}</div>
      <div class="note-card"><b>${locale === "zh" ? "一屏理顺" : "One clean view"}</b><span>${locale === "zh" ? "方位、年度与阶段线索集中呈现。" : "Direction, annual, and period cues stay together."}</span></div>`;
  }
  if (item.scene === "plan") {
    return `
      ${phone(src, "phone-plan")}
      <div class="plan-proof"><span></span><span></span><span></span><span></span><i></i></div>
      <div class="needle"></div>
      <div class="note-card plan-note"><b>${locale === "zh" ? "落到真实户型" : "Mapped to the plan"}</b><span>${locale === "zh" ? "中心、开口、房间关系一起看。" : "Center, opening, and room zones together."}</span></div>`;
  }
  if (item.scene === "rooms") {
    const rooms = locale === "zh" ? ["卧室", "书房", "客厅", "玄关"] : ["Bedroom", "Study", "Living", "Entry"];
    return `
      ${phone(src, "phone-rooms")}
      <div class="room-proof">${rooms.map((room, i) => `<span style="--i:${i}">${esc(room)}<i></i></span>`).join("")}</div>`;
  }
  return `
    ${phone(src, "phone-final-a")}
    ${phone(src2, "phone-final-b")}
    <div class="closing">
      <img src="${fileUrl(assets.icon)}" alt="">
      <b>${locale === "zh" ? "探觅·空间罗盘" : "TAME Space Compass"}</b>
      <span>${locale === "zh" ? "离线记录 · 本地保存 · 按需分享" : "Offline checks · Local records · Export when ready"}</span>
    </div>`;
}

function html(item, locale, index) {
  const bg = assets[item.bg];
  const langClass = locale === "zh" ? "zh" : "en";
  return `<!doctype html>
<html lang="${locale === "zh" ? "zh-Hans" : "en"}">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=${W}, height=${H}, initial-scale=1">
<style>
*{box-sizing:border-box}
html,body{margin:0;width:${W}px;height:${H}px;overflow:hidden}
body{font-family:-apple-system,BlinkMacSystemFont,"SF Pro Display","PingFang SC","Hiragino Sans GB","Noto Sans CJK SC",sans-serif;background:#f8f5ec}
.poster{position:relative;width:${W}px;height:${H}px;overflow:hidden;color:#111312;background:#f8f5ec}
.poster:before{content:"";position:absolute;inset:-32px;background:url("${fileUrl(bg)}") center/cover no-repeat;filter:saturate(.92) contrast(1.06);transform:scale(1.06)}
.poster:after{content:"";position:absolute;inset:0;background:radial-gradient(860px 720px at 82% 18%,rgba(205,174,102,.30),transparent 66%),radial-gradient(820px 760px at 12% 76%,rgba(255,255,255,.72),transparent 70%),linear-gradient(180deg,rgba(255,255,255,.86),rgba(247,242,230,.58) 45%,rgba(20,27,23,.06));}
.poster.dark{color:#fbf4e2;background:#0c1512}
.poster.dark:before{filter:saturate(.78) contrast(1.12) brightness(.72)}
.poster.dark:after{background:radial-gradient(900px 720px at 76% 20%,rgba(209,169,86,.30),transparent 70%),radial-gradient(760px 760px at 11% 76%,rgba(255,255,255,.10),transparent 72%),linear-gradient(180deg,rgba(8,15,13,.88),rgba(19,34,28,.63) 45%,rgba(6,10,9,.87))}
.grain{position:absolute;z-index:2;inset:0;opacity:.14;background-image:radial-gradient(rgba(18,16,12,.34) .55px,transparent .8px);background-size:7px 7px;mix-blend-mode:multiply}
.dark .grain{opacity:.18;background-image:radial-gradient(rgba(255,246,222,.36) .55px,transparent .8px);mix-blend-mode:screen}
.brand-watermark{position:absolute;z-index:3;right:-280px;top:-245px;width:930px;height:930px;background:url("${fileUrl(assets.icon)}") center/contain no-repeat;opacity:.075;filter:grayscale(1)}
.dark .brand-watermark{opacity:.12;filter:grayscale(1) invert(1)}
.orbit{position:absolute;z-index:3;border:1.5px solid rgba(171,143,79,.21);border-radius:50%}.orbit-a{right:-430px;top:300px;width:1210px;height:1210px}.orbit-b{left:-315px;bottom:380px;width:760px;height:760px}.dark .orbit{border-color:rgba(230,198,123,.22)}
.axis-h,.axis-v{position:absolute;z-index:3;background:rgba(60,52,36,.13)}.axis-h{height:1px;left:86px;right:86px;top:1398px}.axis-v{width:1px;top:150px;bottom:212px;left:50%}.dark .axis-h,.dark .axis-v{background:rgba(241,225,178,.18)}
.brand{position:absolute;z-index:24;left:88px;top:80px;display:flex;align-items:center;gap:18px}.brand img{width:58px;height:58px;border-radius:16px;box-shadow:0 18px 42px rgba(31,25,16,.18)}.brand b,.brand span{display:block}.brand b{font-size:24px;color:#111312}.brand span{margin-top:5px;font-size:17px;font-weight:650;color:#656861}.dark .brand b{color:#fbf4e2}.dark .brand span{color:#d8cfba}
.copy{position:absolute;z-index:20;left:88px;top:214px;width:850px}.sequence{display:flex;align-items:center;gap:22px;margin-bottom:28px;color:#b8934f;font-size:28px;font-weight:850}.sequence i{display:block;width:116px;height:2px;background:#b8934f}.eyebrow{margin-bottom:34px;color:#8b7140;font-size:24px;font-weight:850}.dark .sequence,.dark .eyebrow{color:#d7b76d}.dark .sequence i{background:#d7b76d}
h1{margin:0;color:#101210;font-size:98px;line-height:1.01;font-weight:860;letter-spacing:0}.en h1{font-size:80px;line-height:1.04}h1 span{display:block}p{margin:30px 0 0;max-width:720px;color:#60645f;font-size:31px;line-height:1.43;font-weight:560}.dark h1,.dark p{color:#fbf4e2}.dark p{color:#e8deca}
.badges{display:flex;flex-wrap:wrap;gap:14px;margin-top:34px}.badges span{display:inline-flex;align-items:center;height:54px;padding:0 20px;border-radius:999px;background:rgba(255,255,255,.72);border:1px solid rgba(160,140,92,.28);box-shadow:0 14px 38px rgba(54,47,32,.09);color:#6e5a35;font-size:20px;font-weight:760}.dark .badges span{background:rgba(255,248,225,.13);border-color:rgba(235,198,111,.26);color:#f0dfb8}
.metric{position:absolute;z-index:24;right:88px;top:704px;width:330px;min-height:136px;padding:25px 28px;border-radius:28px;background:rgba(255,255,255,.72);border:1px solid rgba(255,255,255,.84);box-shadow:0 34px 80px rgba(24,31,27,.16);backdrop-filter:blur(18px)}.metric small{display:block;color:#68706b;font-size:18px;font-weight:760}.metric b{display:block;margin-top:10px;color:#111312;font-size:35px;line-height:1.08}.dark .metric{background:rgba(18,26,23,.72);border-color:rgba(229,196,116,.25)}.dark .metric small{color:#d5c9ac}.dark .metric b{color:#fbf4e2}
footer{position:absolute;z-index:25;left:88px;bottom:82px;max-width:660px;color:rgba(17,19,18,.56);font-size:20px;line-height:1.45;font-weight:650}.dark footer{color:rgba(255,246,222,.66)}
.device{position:absolute;z-index:15;width:520px;height:1126px;border-radius:70px;padding:18px;background:linear-gradient(90deg,#090a09,#485048 5%,#151716 12%,#090a09 88%,#777366 96%,#161816);box-shadow:inset 0 0 0 2px rgba(255,255,255,.16),inset 22px 0 38px rgba(255,255,255,.09),inset -22px 0 38px rgba(0,0,0,.70),0 52px 130px rgba(0,0,0,.31);filter:drop-shadow(0 64px 82px rgba(6,14,10,.22))}.device-metal{position:absolute;inset:-8px;border-radius:78px;background:linear-gradient(100deg,rgba(255,255,255,.22),transparent 16%,transparent 82%,rgba(255,255,255,.28));pointer-events:none}.screen{position:relative;z-index:3;width:100%;height:100%;border-radius:52px;overflow:hidden;background:#fff}.screen img{width:100%;height:100%;display:block;object-fit:cover}.island{position:absolute;z-index:5;left:50%;top:28px;width:154px;height:45px;transform:translateX(-50%);border-radius:999px;background:#050505;box-shadow:inset 0 0 0 1px rgba(255,255,255,.08)}.island i{position:absolute;right:24px;top:15px;width:14px;height:14px;border-radius:50%;background:radial-gradient(circle at 35% 35%,#405869,#040506 70%)}.side{position:absolute;background:linear-gradient(180deg,#474d47,#111412);box-shadow:0 2px 0 rgba(255,255,255,.10) inset}.side-left{left:-10px;top:226px;width:10px;height:104px;border-radius:10px 0 0 10px}.side-left:after{content:"";position:absolute;left:0;top:156px;width:10px;height:104px;border-radius:10px 0 0 10px;background:inherit}.side-right{right:-9px;top:338px;width:9px;height:150px;border-radius:0 10px 10px 0}.glass{position:absolute;z-index:6;inset:18px;border-radius:52px;background:linear-gradient(112deg,rgba(255,255,255,.28),transparent 20%,transparent 70%,rgba(255,255,255,.10)),linear-gradient(16deg,rgba(255,255,255,0),rgba(255,255,255,.16) 46%,rgba(255,255,255,0) 58%);mix-blend-mode:screen;pointer-events:none}
.phone-hero{right:140px;bottom:208px;transform:rotate(-4.8deg)}.phone-single{right:150px;bottom:182px;transform:rotate(3.5deg)}.phone-grid{right:132px;bottom:180px;transform:rotate(-4.2deg)}.phone-plan{right:154px;bottom:168px;transform:rotate(3.2deg)}.phone-rooms{right:142px;bottom:180px;transform:rotate(-4.2deg)}.phone-final-a{right:130px;bottom:186px;transform:rotate(-4.4deg)}.phone-final-b{left:120px;bottom:265px;transform:rotate(4.4deg) scale(.78);transform-origin:left bottom}
.halo{position:absolute;z-index:13;border-radius:50%;box-shadow:0 54px 130px rgba(0,0,0,.28),inset 0 0 0 2px rgba(255,244,210,.35)}.compass-halo{left:120px;bottom:620px;width:600px;height:600px;padding:30px;background:radial-gradient(circle at 34% 26%,#fff7d9,#d6b66c 22%,#4d473a 66%,#191b19 100%)}.compass-halo img{width:100%;height:100%;object-fit:cover;border-radius:50%}.readout{position:absolute;z-index:23;left:154px;bottom:585px;width:490px;padding:28px 34px;border-radius:26px;background:rgba(18,24,21,.78);border:1px solid rgba(220,185,106,.44);box-shadow:0 28px 70px rgba(0,0,0,.24);backdrop-filter:blur(14px);color:#fbf4e2}.readout b{font-size:46px}.readout span{display:block;margin-top:8px;color:#d9ceb6;font-size:24px;font-weight:720}
.instrument-card{position:absolute;z-index:23;left:92px;width:360px;padding:30px 34px;border-radius:30px;background:rgba(255,250,236,.75);border:1px solid rgba(222,190,118,.48);box-shadow:0 28px 88px rgba(31,25,14,.19);backdrop-filter:blur(18px)}.instrument-card b{display:block;color:#151614;font-size:44px}.instrument-card span{display:block;margin-top:12px;color:#656862;font-size:22px;font-weight:760}.card-one{bottom:1130px}.card-two{bottom:875px}.gold-disc{position:absolute;z-index:24;left:385px;bottom:762px;width:88px;height:88px;border-radius:50%;background:radial-gradient(circle at 35% 30%,#fff8dc,#deb75f 34%,#72531f 78%);box-shadow:0 18px 54px rgba(82,55,12,.30)}
.grid-proof{position:absolute;z-index:22;left:92px;bottom:1110px;display:grid;grid-template-columns:repeat(3,152px);gap:13px}.grid-proof span{height:132px;border-radius:9px;display:flex;align-items:center;justify-content:center;border:1px solid rgba(72,61,38,.20);color:#151614;font-size:32px;font-weight:860}.grid-proof span:nth-child(3n+1){background:#eee2bb}.grid-proof span:nth-child(3n+2){background:#dcebe2}.grid-proof span:nth-child(3n){background:#ead7d4}
.note-card{position:absolute;z-index:23;left:92px;bottom:742px;width:486px;padding:32px 36px;border-radius:30px;background:rgba(255,255,255,.68);border:1px solid rgba(190,164,96,.34);box-shadow:0 28px 80px rgba(43,38,25,.14);backdrop-filter:blur(18px)}.note-card b{display:block;color:#ad8e4e;font-size:30px}.note-card span{display:block;margin-top:13px;color:#62645f;font-size:23px;line-height:1.35;font-weight:700}
.plan-proof{position:absolute;z-index:20;left:96px;bottom:1010px;width:520px;height:520px;display:grid;grid-template-columns:1fr 1fr;grid-template-rows:1fr 1fr;border:2px solid rgba(61,55,39,.52);box-shadow:0 28px 80px rgba(38,31,16,.16)}.plan-proof span{border:1px solid rgba(61,55,39,.36)}.plan-proof span:nth-child(1){background:#dcebe2}.plan-proof span:nth-child(2){background:#eee1bb}.plan-proof span:nth-child(3){background:#dfe9f2}.plan-proof span:nth-child(4){background:#ead7d4}.plan-proof i{position:absolute;left:50%;top:50%;width:28px;height:28px;border-radius:50%;background:#151614;transform:translate(-50%,-50%);box-shadow:0 0 0 14px rgba(177,42,38,.10)}.needle{position:absolute;z-index:23;left:348px;bottom:1390px;width:8px;height:410px;background:#b32927;box-shadow:0 16px 32px rgba(135,25,22,.22)}.needle:before{content:"";position:absolute;left:50%;top:-54px;transform:translateX(-50%);border-left:32px solid transparent;border-right:32px solid transparent;border-bottom:74px solid #b32927}.plan-note{left:585px;bottom:1210px}
.room-proof{position:absolute;z-index:22;left:92px;bottom:1120px;display:flex;flex-direction:column;gap:25px}.room-proof span{position:relative;width:370px;padding:28px 32px;border-radius:24px;background:#fff;border:1px solid rgba(190,164,96,.28);box-shadow:0 18px 54px rgba(43,38,25,.11);font-size:31px;font-weight:850;color:#151614;transform:translateX(calc(var(--i) * 22px))}.room-proof span:nth-child(1){background:#dceee4}.room-proof span:nth-child(2){background:#efe8c8}.room-proof span:nth-child(3){background:#dfe9f3}.room-proof span:nth-child(4){background:#ead7d4}.room-proof i{position:absolute;right:26px;top:50%;width:68px;height:2px;background:#b8934f}
.closing{position:absolute;z-index:25;left:88px;top:935px;width:600px;color:#fbf4e2}.closing img{width:92px;height:92px;border-radius:25px;box-shadow:0 22px 60px rgba(0,0,0,.28);margin-bottom:22px}.closing b{display:block;font-size:36px}.closing span{display:block;margin-top:12px;color:#ded2bb;font-size:23px}
</style>
</head>
<body>
<main class="poster ${item.mood} ${langClass}">
  <div class="grain"></div>
  <div class="brand-watermark"></div>
  <div class="orbit orbit-a"></div>
  <div class="orbit orbit-b"></div>
  <div class="axis-h"></div>
  <div class="axis-v"></div>
  ${brand(locale)}
  ${copyBlock(item, locale, index)}
  ${scene(item, locale)}
</main>
</body>
</html>`;
}

function renderShot(htmlPath, outPath) {
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
    "--virtual-time-budget=3000",
    `--user-data-dir=${profile}`,
    `--window-size=${W},${H}`,
    `--screenshot=${outPath}`,
    fileUrl(htmlPath),
  ];
  try {
    execFileSync(chromeBin, args, { stdio: "ignore", timeout: 12000 });
  } catch (error) {
    if (!validPng(outPath)) throw error;
  } finally {
    try {
      execFileSync("pkill", ["-f", profile], { stdio: "ignore" });
    } catch {}
  }
}

function rgbNormalize(files) {
  const script = `
from PIL import Image
from pathlib import Path
for file in ${JSON.stringify(files)}:
    p = Path(file)
    im = Image.open(p).convert("RGB")
    im.save(p)
`;
  execFileSync("python3", ["-c", script], { stdio: "ignore" });
}

function contactSheet(files, outPath) {
  const script = `
from PIL import Image, ImageDraw
from pathlib import Path
files = ${JSON.stringify(files)}
out = Path(${JSON.stringify(outPath)})
thumb_w = 360
thumb_h = round(thumb_w * ${H} / ${W})
gap = 22
label_h = 36
sheet = Image.new("RGB", (thumb_w * 3 + gap * 4, (thumb_h + label_h) * 2 + gap * 3), "#ebe7dc")
draw = ImageDraw.Draw(sheet)
for i, file in enumerate(files):
    im = Image.open(file).convert("RGB").resize((thumb_w, thumb_h), Image.Resampling.LANCZOS)
    x = gap + (i % 3) * (thumb_w + gap)
    y = gap + (i // 3) * (thumb_h + label_h + gap)
    sheet.paste(im, (x, y))
    draw.text((x, y + thumb_h + 10), Path(file).name, fill="#32302a")
out.parent.mkdir(parents=True, exist_ok=True)
sheet.save(out, quality=92)
`;
  execFileSync("python3", ["-c", script], { stdio: "ignore" });
}

function buildLocale(locale, dir, onlyIndex = null) {
  mkdirp(dir);
  const outputs = [];
  copy[locale].forEach((item, index) => {
    if (onlyIndex !== null && index !== onlyIndex) {
      outputs.push(path.join(dir, finalNames[index]));
      return;
    }
    const htmlPath = path.join(htmlDir, `${locale}-${String(index + 1).padStart(2, "0")}.html`);
    const outPath = path.join(dir, finalNames[index]);
    fs.writeFileSync(htmlPath, html(item, locale, index));
    renderShot(htmlPath, outPath);
    outputs.push(outPath);
  });
  rgbNormalize(outputs);
  return outputs;
}

function main() {
  [htmlDir, sheetDir, zhDir, enDir, chromeProfileRoot].forEach(mkdirp);
  Object.entries(assets).forEach(([key, value]) => {
    if (!fs.existsSync(value)) throw new Error(`Missing asset ${key}: ${value}`);
  });
  if (!fs.existsSync(chromeBin)) throw new Error(`Missing Chrome binary: ${chromeBin}`);

  const target = process.argv[2] || "all";
  const onlyIndex = process.argv[3] ? Number(process.argv[3]) - 1 : null;
  const zh = target === "all" || target === "zh" ? buildLocale("zh", zhDir, onlyIndex) : finalNames.map((name) => path.join(zhDir, name));
  const en = target === "all" || target === "en" ? buildLocale("en", enDir, onlyIndex) : finalNames.map((name) => path.join(enDir, name));
  if (zh.every((file) => fs.existsSync(file))) contactSheet(zh, path.join(sheetDir, "zh-Hans-contactsheet.jpg"));
  if (en.every((file) => fs.existsSync(file))) contactSheet(en, path.join(sheetDir, "en-US-contactsheet.jpg"));

  console.log(`Wrote ${zh.length} zh-Hans screenshots: ${zhDir}`);
  console.log(`Wrote ${en.length} en-US screenshots: ${enDir}`);
  console.log(`Contact sheet: ${path.join(sheetDir, "zh-Hans-contactsheet.jpg")}`);
  console.log(`Contact sheet: ${path.join(sheetDir, "en-US-contactsheet.jpg")}`);
}

main();
