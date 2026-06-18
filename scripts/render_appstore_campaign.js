#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const { execFileSync } = require("child_process");

const root = path.resolve(__dirname, "..");
const outRoot = path.join(root, "AppStoreAssets");
const campaignDir = path.join(outRoot, "generated-marketing", "campaign-v9");
const zhDir = path.join(outRoot, "zh-Hans-campaign-v9");
const enDir = path.join(outRoot, "en-US-campaign-v9");
const chromeBin = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const chromeProfileRoot = path.join(root, "build", "chrome-appstore-render-profile");
const W = 1284;
const H = 2778;

const assets = {
  icon: "/Users/pengpeng/Downloads/下载.png",
  compass: path.join(root, "VerificationShots", "compass_red_pointer_arrow_unified.png"),
  compassMarked: path.join(root, "VerificationShots", "compass_pointer_to_marked_ring.png"),
  overviewZh: path.join(root, "VerificationShots", "overview-nine-palace-2026-05-22.png"),
  overviewEn: path.join(root, "VerificationShots", "en-US", "flying-star-demo-2.png"),
  analysisZh: path.join(root, "VerificationShots", "analysis-yanggong-entry-2026-05-22.png"),
  analysisEn: path.join(root, "VerificationShots", "en-US", "annual-demo-3.png"),
  roomZh: path.join(root, "VerificationShots", "yanggong-fenjin-clean.png"),
  roomEn: path.join(root, "AppStoreAssets", "en-US", "05-bazhai.png"),
  reportZh: path.join(root, "VerificationShots", "overview-graphical-entry-2026-05-22.png"),
  reportEn: path.join(root, "AppStoreAssets", "en-US", "06-record-share.png"),
};

function mkdirp(p) {
  fs.mkdirSync(p, { recursive: true });
}

function fileUrl(p) {
  return `file://${p.split(path.sep).map(encodeURIComponent).join("/")}`;
}

function htmlEscape(s) {
  return String(s).replace(/[&<>"']/g, (c) => ({
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "'": "&#39;",
  }[c]));
}

const copy = {
  zh: [
    ["拿起手机", "看懂空间方向", "罗盘、户型与记录集中在一个工具"],
    ["红针清晰", "现场测向更安心", "关键方向一眼确认，细节留给刻度"],
    ["九宫可视化", "布局不再靠想象", "把方位关系放到同一张图里"],
    ["导入户型图", "空间关系马上成形", "中心点、开口与房间分区直观呈现"],
    ["每个房间", "都有清晰参考", "卧室、书房、客厅分开整理"],
    ["生成报告", "复盘沟通更轻松", "离线保存，需要时再分享"],
  ],
  en: [
    ["Open The App", "Read The Room Direction", "Compass, floor plan, and records in one tool"],
    ["Clear Red Needle", "Check Direction On Site", "Key orientation stays easy to read"],
    ["Visual Nine-Grid", "See Layout At A Glance", "Keep spatial references on one map"],
    ["Import A Plan", "Align Rooms With Direction", "Center point, openings, and room zones together"],
    ["Room By Room", "Keep Notes Organized", "Bedroom, study, and living areas separated"],
    ["Create Reports", "Review And Share Calmly", "Offline records ready when needed"],
  ],
};

function frameData(locale, frame) {
  const isZh = locale === "zh";
  const c = copy[locale][frame - 1];
  const common = {
    locale,
    n: String(frame).padStart(2, "0"),
    eyebrow: isZh ? "TAME Space Compass / 探觅·空间罗盘" : "TAME Space Compass",
    titleA: c[0],
    titleB: c[1],
    sub: c[2],
  };
  const map = {
    1: { ...common, kind: "hero", shot: assets.compassMarked, alt: assets.compass, icon: assets.icon },
    2: { ...common, kind: "instrument", shot: assets.compass, alt: assets.compassMarked },
    3: { ...common, kind: "grid", shot: isZh ? assets.overviewZh : assets.overviewEn },
    4: { ...common, kind: "plan", shot: isZh ? assets.analysisZh : assets.analysisEn },
    5: { ...common, kind: "rooms", shot: isZh ? assets.roomZh : assets.roomEn },
    6: { ...common, kind: "reports", shot: isZh ? assets.reportZh : assets.reportEn, alt: isZh ? assets.analysisZh : assets.analysisEn },
  };
  return map[frame];
}

function renderPage(data) {
  const isZh = data.locale === "zh";
  const bodyClass = `${data.kind} ${isZh ? "zh" : "en"}`;
  const titleA = htmlEscape(data.titleA);
  const titleB = htmlEscape(data.titleB);
  const sub = htmlEscape(data.sub);
  const eyebrow = htmlEscape(data.eyebrow);
  const shot = fileUrl(data.shot);
  const alt = data.alt ? fileUrl(data.alt) : shot;
  const icon = fileUrl(data.icon || assets.icon);
  const labels = isZh
    ? ["方位", "空间盘", "九宫", "记录"]
    : ["Facing", "Space", "Grid", "Records"];
  const rooms = isZh ? ["卧室", "书房", "客厅", "玄关"] : ["Bedroom", "Study", "Living", "Entry"];

  return `<!doctype html>
<html lang="${isZh ? "zh-Hans" : "en"}">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=${W}, height=${H}, initial-scale=1" />
<style>
@font-face{font-family:Heiti;src:local("STHeiti");}
*{box-sizing:border-box}
body{margin:0;width:${W}px;height:${H}px;overflow:hidden;background:#f7f5ee;font-family:${isZh ? "Heiti" : "Arial"}, -apple-system, BlinkMacSystemFont, sans-serif;color:#101112;letter-spacing:0}
.frame{position:relative;width:${W}px;height:${H}px;overflow:hidden;background:#f8f5ed}
.frame:before{content:"";position:absolute;inset:0;background:
 radial-gradient(900px 560px at 18% 24%, rgba(255,255,255,.92), rgba(255,255,255,0) 70%),
 radial-gradient(880px 720px at 92% 8%, rgba(214,196,156,.22), rgba(214,196,156,0) 70%),
 linear-gradient(145deg,#fbfaf5 0%,#f3efe3 55%,#e7dfce 100%);}
.frame:after{content:"";position:absolute;inset:0;background-image:url('${icon}');background-repeat:no-repeat;background-size:940px 940px;background-position:calc(100% + 310px) -240px;opacity:.055;filter:grayscale(1) contrast(1.1)}
.grain{position:absolute;inset:0;opacity:.13;background-image:radial-gradient(#000 0.45px, transparent .6px);background-size:6px 6px;mix-blend-mode:multiply}
.orb{position:absolute;border-radius:50%;border:2px solid rgba(23,26,24,.1)}
.orb.o1{width:1180px;height:1180px;right:-420px;top:120px}
.orb.o2{width:740px;height:740px;left:-260px;bottom:340px}
.axis{position:absolute;left:0;right:0;top:0;bottom:0;pointer-events:none}
.axis:before{content:"";position:absolute;left:118px;right:118px;top:1260px;height:1px;background:rgba(15,17,18,.08)}
.axis:after{content:"";position:absolute;top:160px;bottom:220px;left:50%;width:1px;background:rgba(15,17,18,.055)}
.copy{position:absolute;z-index:8;left:86px;top:96px;width:760px}
.seq{display:flex;gap:28px;align-items:center;color:#b99c5e;font-weight:700;font-size:28px;margin-bottom:26px}
.seq:after{content:"";display:block;width:118px;height:2px;background:#b99c5e}
.eyebrow{font-size:${isZh ? 25 : 23}px;color:#a98c50;font-weight:700;margin-bottom:44px}
.title{font-weight:900;line-height:.98;font-size:${isZh ? 82 : 72}px;max-width:790px}
.title span{display:block}
.sub{margin-top:30px;max-width:690px;font-size:${isZh ? 31 : 29}px;line-height:1.34;color:#646667;font-weight:500}
.brand-strip{position:absolute;z-index:9;left:86px;bottom:118px;display:flex;gap:22px;align-items:center}
.mini-icon{width:82px;height:82px;border-radius:22px;box-shadow:0 16px 42px rgba(20,20,18,.16)}
.brand-strip .name{font-size:26px;font-weight:800;color:#111}
.brand-strip .tone{font-size:22px;color:#6b6c68;margin-top:8px}
.phone{position:absolute;z-index:5;width:560px;padding:22px;border-radius:86px;background:#151512;box-shadow:0 44px 100px rgba(28,24,14,.30), inset 0 0 0 2px rgba(255,255,255,.12)}
.phone:before{content:"";position:absolute;left:50%;top:34px;transform:translateX(-50%);width:178px;height:38px;border-radius:22px;background:#050505;z-index:3}
.phone:after{content:"";position:absolute;inset:30px;border-radius:66px;border:2px solid rgba(255,255,255,.38);pointer-events:none;z-index:4}
.phone img{display:block;width:100%;border-radius:64px;background:#fbfaf6}
.phone.tiltL{transform:rotate(-5deg)}
.phone.tiltR{transform:rotate(4deg)}
.glass{position:absolute;inset:22px;border-radius:68px;background:linear-gradient(105deg,rgba(255,255,255,.30),rgba(255,255,255,0) 32%,rgba(255,255,255,.10) 58%,rgba(255,255,255,0));mix-blend-mode:screen;pointer-events:none;z-index:5}
.disc{position:absolute;z-index:2;border-radius:50%;background:url('${alt}') center 38%/cover no-repeat;filter:saturate(.92) contrast(1.04);opacity:.78;box-shadow:inset 0 0 0 2px rgba(255,255,255,.5), inset 0 0 100px rgba(255,255,255,.88)}
.metal{position:absolute;border-radius:50%;background:radial-gradient(circle at 35% 28%,#fff7d6 0,#e5c575 18%,#956c25 48%,#fff0b0 66%,#7a571c 100%);box-shadow:0 16px 38px rgba(83,58,15,.28),inset 0 0 16px rgba(255,255,255,.55)}
.rule-card{position:absolute;z-index:6;border:1px solid rgba(191,171,126,.55);border-radius:28px;background:rgba(255,255,255,.68);backdrop-filter:blur(14px);box-shadow:0 28px 80px rgba(44,39,28,.12)}
.metric{padding:26px 28px}
.metric b{display:block;font-size:34px}.metric span{display:block;margin-top:8px;font-size:22px;color:#777}
.gridGraphic{position:absolute;z-index:6;display:grid;grid-template-columns:repeat(3,144px);grid-template-rows:repeat(3,144px);gap:12px}
.gridGraphic div{display:flex;align-items:center;justify-content:center;border:1px solid rgba(113,101,76,.24);border-radius:8px;font-size:40px;font-weight:800}
.gridGraphic div:nth-child(3n+1){background:#efe6c7}.gridGraphic div:nth-child(3n+2){background:#dfeee4}.gridGraphic div:nth-child(3n){background:#efd9d6}
.planGraphic{position:absolute;z-index:6;width:445px;height:445px;display:grid;grid-template-columns:1fr 1fr;grid-template-rows:1fr 1fr;border:2px solid rgba(65,57,44,.48)}
.planGraphic div{border:1px solid rgba(65,57,44,.42)}.planGraphic div:nth-child(1){background:#dcece2}.planGraphic div:nth-child(2){background:#f0e8c8}.planGraphic div:nth-child(3){background:#dde8f2}.planGraphic div:nth-child(4){background:#ead4d1}
.redNeedle{position:absolute;z-index:7;width:8px;height:360px;background:#b6322e;box-shadow:0 10px 22px rgba(140,26,22,.22)}
.redNeedle:before{content:"";position:absolute;left:50%;top:-52px;transform:translateX(-50%);width:0;height:0;border-left:32px solid transparent;border-right:32px solid transparent;border-bottom:70px solid #b6322e}
.redNeedle:after{content:"";position:absolute;left:50%;top:332px;transform:translateX(-50%);width:50px;height:50px;border-radius:50%;background:#111}
.roomChips{position:absolute;z-index:7;display:flex;flex-direction:column;gap:26px}.roomChips div{width:360px;padding:28px 32px;border-radius:22px;background:rgba(255,255,255,.64);border:1px solid rgba(190,180,154,.52);font-size:30px;font-weight:800;box-shadow:0 18px 54px rgba(48,42,27,.10)}
.roomChips div:nth-child(1){background:#dceee4}.roomChips div:nth-child(2){background:#efe9c9}.roomChips div:nth-child(3){background:#dfe9f3}.roomChips div:nth-child(4){background:#ead7d4}
.darkPanel{position:absolute;z-index:4;background:#233d34;color:#f5f1e5}
.darkPanel:before{content:"";position:absolute;inset:0;background:linear-gradient(135deg,rgba(255,255,255,.08),rgba(255,255,255,0));}
.darkText{position:absolute;z-index:8;color:#f6f1e2}.darkText h3{font-size:34px;margin:0 0 18px;color:#d9bd79}.darkText p{font-size:26px;line-height:1.35;margin:0;color:#ece7d6}
.hero:before{background:radial-gradient(720px 540px at 66% 38%,rgba(255,255,255,.94),rgba(255,255,255,0) 72%),linear-gradient(155deg,#f9f7f0 0,#eee6d8 100%)}.hero .copy{top:82px;width:860px}.hero .disc{width:1180px;height:1180px;left:-360px;top:690px}.hero .phone{right:54px;top:742px;width:610px}.hero .brand-strip{bottom:106px}.hero .metal{left:440px;top:1190px;width:104px;height:104px}.hero .darkPanel{display:none}.hero .title{font-size:${isZh ? 88 : 78}px}
.instrument:before{background:linear-gradient(90deg,#f9f7ef 0 58%,#233d34 58% 100%)}.instrument .phone{left:92px;top:735px;width:690px}.instrument .copy{width:620px}.instrument .rule-card.m1{right:88px;top:820px;width:300px;height:158px}.instrument .rule-card.m2{right:88px;top:1060px;width:300px;height:158px}.instrument .darkPanel{display:none}.instrument .darkText{right:72px;top:1430px;width:268px}.instrument .metal{right:198px;top:1325px;width:78px;height:78px}
.grid:before{background:linear-gradient(120deg,#f9f7f0 0 48%,#ece2d3 48% 100%)}.grid .phone{right:18px;top:680px;width:565px}.grid .gridGraphic{left:112px;top:1005px;grid-template-columns:repeat(3,162px);grid-template-rows:repeat(3,162px)}.grid .darkPanel{display:none}.grid .rule-card{left:112px;top:1686px;width:470px;height:142px;padding:34px}.grid .rule-card b{font-size:31px}
.plan:before{background:radial-gradient(720px 520px at 22% 52%,rgba(255,255,255,.90),rgba(255,255,255,0) 72%),linear-gradient(160deg,#fbfaf6 0,#ebe2d4 100%)}.plan .phone{right:48px;top:1160px;width:640px}.plan .planGraphic{left:108px;top:970px;width:480px;height:480px}.plan .redNeedle{left:344px;top:795px;height:420px}.plan .rule-card{left:610px;top:945px;width:470px;padding:30px}.plan .rule-card b{font-size:30px}.plan .rule-card span{font-size:23px;color:#6e6f6d}
.rooms:before{background:linear-gradient(90deg,#f9f7ef 0 62%,#233d34 62% 100%)}.rooms .phone{right:52px;top:710px;width:610px}.rooms .roomChips{left:92px;top:920px}.rooms .darkPanel{display:none}.rooms .copy{left:86px;width:620px}.rooms .brand-strip .name,.rooms .brand-strip .tone{color:#141512}
.reports:before{background:radial-gradient(740px 560px at 68% 34%,rgba(255,255,255,.9),rgba(255,255,255,0) 70%),linear-gradient(165deg,#243d34 0 46%,#f8f5ed 46% 100%)}.reports .copy{color:#f7f1e4}.reports .copy .title,.reports .copy .sub{color:#f7f1e4}.reports .phone.one{right:88px;top:720px;width:545px}.reports .phone.two{left:96px;top:1080px;width:450px}.reports .darkPanel{display:none}.reports .darkText{left:92px;bottom:210px;width:760px}.reports .brand-strip .name,.reports .brand-strip .tone{color:#f5f1e5}

/* Campaign v7: stronger poster art direction with distinct frame families. */
.hero{background:#203b33}.hero:before{background:radial-gradient(740px 620px at 68% 42%,rgba(249,244,226,.18),rgba(249,244,226,0) 70%),linear-gradient(145deg,#172b25 0,#27483e 100%)}.hero:after{background-size:1160px 1160px;background-position:calc(100% + 260px) 110px;opacity:.12;filter:grayscale(1) invert(1) contrast(1.25)}.hero .copy,.hero .title,.hero .sub{color:#f7f1e4}.hero .eyebrow,.hero .seq{color:#d7b970}.hero .seq:after{background:#d7b970}.hero .disc{width:1160px;height:1160px;left:-360px;top:800px;opacity:.36;filter:saturate(.6) contrast(1.06) brightness(1.12)}.hero .phone{right:54px;top:780px;width:625px}.hero .brand-strip .name,.hero .brand-strip .tone{color:#f7f1e4}.hero .brand-strip{bottom:108px}.hero .metal{left:425px;top:1286px;width:112px;height:112px}
.instrument{background:#f8f5ed}.instrument:before{background:radial-gradient(720px 560px at 36% 58%,rgba(255,255,255,.9),rgba(255,255,255,0) 70%),linear-gradient(110deg,#fbfaf5 0,#ede5d6 100%)}.instrument .phone{left:72px;top:700px;width:710px}.instrument .rule-card.m1{right:86px;top:800px}.instrument .rule-card.m2{right:86px;top:1056px}.instrument .darkText{right:70px;top:1410px;color:#233d34}.instrument .darkText h3{color:#aa8847}.instrument .darkText p{color:#4f5d56}.instrument .metal{right:204px;top:1302px}
.grid{background:#f8f5ed}.grid:before{background:linear-gradient(150deg,#f9f7f0 0 54%,#273f36 54% 100%)}.grid .copy{width:720px}.grid .phone{right:98px;top:790px;width:500px}.grid .gridGraphic{left:110px;top:965px;grid-template-columns:repeat(3,176px);grid-template-rows:repeat(3,176px)}.grid .rule-card{left:108px;top:1698px}.grid .brand-strip .name,.grid .brand-strip .tone{color:#f7f1e4}
.plan{background:#f8f5ed}.plan:before{background:radial-gradient(860px 560px at 25% 49%,rgba(255,255,255,.93),rgba(255,255,255,0) 72%),linear-gradient(160deg,#fbfaf6 0,#eee4d6 100%)}.plan .copy{width:780px}.plan .phone{right:72px;top:1110px;width:590px}.plan .planGraphic{left:104px;top:940px;width:520px;height:520px}.plan .redNeedle{left:360px;top:760px;height:465px}.plan .rule-card{left:628px;top:920px}
.rooms{background:#f8f5ed}.rooms:before{background:linear-gradient(130deg,#f9f7ef 0 50%,#efe5d6 50% 100%)}.rooms .copy{left:86px;width:705px}.rooms .phone{right:68px;top:750px;width:585px}.rooms .roomChips{left:92px;top:960px}.rooms .roomChips div{width:330px}
.reports{background:#213c34}.reports:before{background:radial-gradient(760px 580px at 70% 40%,rgba(251,246,226,.25),rgba(251,246,226,0) 70%),linear-gradient(148deg,#152b25 0,#27463c 100%)}.reports:after{opacity:.10;filter:grayscale(1) invert(1) contrast(1.3)}.reports .copy{color:#f7f1e4;width:730px}.reports .copy .title,.reports .copy .sub{color:#f7f1e4}.reports .phone.one{right:86px;top:760px;width:565px}.reports .phone.two{left:86px;top:1085px;width:470px}.reports .darkText{left:90px;bottom:214px}.reports .brand-strip .name,.reports .brand-strip .tone{color:#f5f1e5}
</style>
</head>
<body>
<main class="frame ${bodyClass}">
  <div class="grain"></div><div class="orb o1"></div><div class="orb o2"></div><div class="axis"></div>
  <section class="copy">
    <div class="seq">${data.n}</div>
    <div class="eyebrow">${eyebrow}</div>
    <div class="title"><span>${titleA}</span><span>${titleB}</span></div>
    <div class="sub">${sub}</div>
  </section>
  ${renderKind(data, { shot, alt, labels, rooms, isZh })}
  <section class="brand-strip"><img class="mini-icon" src="${icon}" /><div><div class="name">TAME Space Compass</div><div class="tone">${isZh ? "精密空间参考工具" : "Precision spatial reference"}</div></div></section>
</main>
</body>
</html>`;
}

function phone(src, cls = "") {
  return `<div class="phone ${cls}"><img src="${src}" /><div class="glass"></div></div>`;
}

function renderKind(data, ctx) {
  const { shot, alt, labels, rooms, isZh } = ctx;
  if (data.kind === "hero") {
    return `<div class="disc"></div><div class="metal"></div>${phone(shot, "tiltL")}<div class="darkPanel"></div>`;
  }
  if (data.kind === "instrument") {
  return `${phone(shot)}<div class="rule-card metric m1"><b>182.5°</b><span>${isZh ? "当前方位" : "Current heading"}</span></div><div class="rule-card metric m2"><b>190.0°</b><span>${isZh ? "空间参考" : "Spatial reference"}</span></div><div class="darkPanel"></div><div class="metal"></div><div class="darkText"><h3>${isZh ? "现场更好读" : "Easy on site"}</h3><p>${isZh ? "主方向突出，角度与参考信息分层呈现。" : "The main direction stands out while details stay structured."}</p></div>`;
  }
  if (data.kind === "grid") {
    return `${phone(shot, "tiltR")}<div class="gridGraphic">${[1,2,3,4,5,6,7,8,9].map(n=>`<div>${n}</div>`).join("")}</div><div class="darkPanel"></div><div class="rule-card"><b>${isZh ? "方位关系 / 周期参考" : "Direction map / Period reference"}</b></div>`;
  }
  if (data.kind === "plan") {
    return `${phone(shot, "tiltL")}<div class="planGraphic"><div></div><div></div><div></div><div></div></div><div class="redNeedle"></div><div class="rule-card"><b>${isZh ? "选择中心点" : "Set the center"}</b><br><span>${isZh ? "让户型图与方向参考对齐" : "Align the plan with direction references"}</span></div>`;
  }
  if (data.kind === "rooms") {
    return `${phone(shot, "tiltR")}<div class="darkPanel"></div><div class="roomChips">${rooms.map(r=>`<div>${r}</div>`).join("")}</div>`;
  }
  return `${phone(shot, "one tiltR")}${phone(alt, "two tiltL")}<div class="darkPanel"></div><div class="darkText"><h3>${isZh ? "本地保存" : "Saved locally"}</h3><p>${isZh ? "测向、户型与备注留在设备里，需要时再生成分享卡。" : "Compass checks, plans, and notes stay on device until you share."}</p></div>`;
}

function writeHtml(locale, frame) {
  const data = frameData(locale, frame);
  const html = renderPage(data);
  const file = path.join(campaignDir, `${locale}-${String(frame).padStart(2, "0")}.html`);
  fs.writeFileSync(file, html);
  return file;
}

function runShot(htmlPath, outPath) {
  const url = fileUrl(htmlPath);
  const profile = path.join(chromeProfileRoot, outPath.replace(/[^a-zA-Z0-9]+/g, "-"));
  fs.rmSync(profile, { recursive: true, force: true });
  mkdirp(profile);
  fs.rmSync(outPath, { force: true });
  const args = chromeArgs(profile, `${W},${H}`, outPath, url);
  try {
    execFileSync(chromeBin, args, { stdio: "ignore", timeout: 7000 });
  } catch (error) {
    if (!validPng(outPath)) {
      throw error;
    }
  } finally {
    cleanupChromeProfile(profile);
  }
}

function contactSheet(files, outPath) {
  const html = `<!doctype html><meta charset="utf-8"><style>
body{margin:0;background:#e8e6df}.sheet{display:grid;grid-template-columns:repeat(3,360px);gap:22px;padding:22px}
img{width:360px;height:${Math.round(360 * H / W)}px;object-fit:cover;display:block}
</style><div class="sheet">${files.map(f=>`<img src="${fileUrl(f)}">`).join("")}</div>`;
  const htmlPath = outPath.replace(/\.jpg$/, ".html");
  fs.writeFileSync(htmlPath, html);
  const profile = path.join(chromeProfileRoot, outPath.replace(/[^a-zA-Z0-9]+/g, "-"));
  fs.rmSync(profile, { recursive: true, force: true });
  mkdirp(profile);
  fs.rmSync(outPath, { force: true });
  const args = chromeArgs(profile, "1126,1610", outPath, fileUrl(htmlPath));
  try {
    execFileSync(chromeBin, args, { stdio: "ignore", timeout: 7000 });
  } catch (error) {
    if (!validPng(outPath) && !fs.existsSync(outPath)) {
      throw error;
    }
  } finally {
    cleanupChromeProfile(profile);
  }
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
  const st = fs.statSync(file);
  if (st.size < 100000) return false;
  const fd = fs.openSync(file, "r");
  const buf = Buffer.alloc(24);
  fs.readSync(fd, buf, 0, 24, 0);
  fs.closeSync(fd);
  return buf.toString("hex", 0, 8) === "89504e470d0a1a0a";
}

function cleanupChromeProfile(profile) {
  try {
    execFileSync("pkill", ["-f", profile], { stdio: "ignore" });
  } catch {}
}

function main() {
  [campaignDir, zhDir, enDir].forEach(mkdirp);
  const outputs = { zh: [], en: [] };
  for (const locale of ["zh", "en"]) {
    const dir = locale === "zh" ? zhDir : enDir;
    for (let frame = 1; frame <= 6; frame++) {
      const html = writeHtml(locale, frame);
      const out = path.join(dir, `${String(frame).padStart(2, "0")}.png`);
      runShot(html, out);
      outputs[locale].push(out);
    }
  }
  contactSheet(outputs.zh, path.join(campaignDir, "zh-contactsheet.jpg"));
  contactSheet(outputs.en, path.join(campaignDir, "en-contactsheet.jpg"));
  console.log(`Wrote ${outputs.zh.length} zh screenshots to ${zhDir}`);
  console.log(`Wrote ${outputs.en.length} en screenshots to ${enDir}`);
  console.log(`Contact sheets in ${campaignDir}`);
}

main();
