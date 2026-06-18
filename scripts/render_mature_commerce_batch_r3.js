#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const { spawnSync } = require("child_process");

const root = path.resolve(__dirname, "..");
const outRoot = path.join(root, "AppStoreAssets");
const campaign = "mature-commerce-r3-full";
const htmlDir = path.join(outRoot, "generated-marketing", campaign, "html");
const sheetDir = path.join(outRoot, "generated-marketing", campaign);
const zhDir = path.join(outRoot, "zh-Hans-mature-commerce-r3");
const enDir = path.join(outRoot, "en-US-mature-commerce-r3");
const chromeProfileRoot = path.join(root, "build", "chrome-appstore-render-profile", campaign);
const chromeBin = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const W = 1284;
const H = 2778;

const assets = {
  icon: path.join(root, "Design", "app-icon-original-geomancy-1024.png"),
  bgSilver: path.join(root, "AppStoreAssets", "background-source", "03-silver-flow.jpg"),
  bgChrome: path.join(root, "AppStoreAssets", "background-source", "09-chrome-sphere.jpg"),
  bgGlass: path.join(root, "AppStoreAssets", "background-source", "07-glass-forest-bubble.jpg"),
  compassZh: path.join(root, "VerificationShots", "compass_pointer_to_marked_ring.png"),
  compassEn: path.join(root, "VerificationShots", "compass_red_pointer_arrow_unified.png"),
  gridZh: path.join(root, "VerificationShots", "overview-nine-palace-2026-05-22.png"),
  gridEn: path.join(root, "VerificationShots", "en-US", "flying-star-demo-2.png"),
  planZh: path.join(root, "VerificationShots", "analysis-yanggong-entry-2026-05-22.png"),
  planEn: path.join(root, "VerificationShots", "en-US", "annual-demo-3.png"),
  roomZh: path.join(root, "VerificationShots", "yanggong-fenjin-clean.png"),
  roomEn: path.join(root, "VerificationShots", "en-US", "annual-demo-3.png"),
  reportZh: path.join(root, "VerificationShots", "overview-graphical-entry-2026-05-22.png"),
  reportEn: path.join(root, "VerificationShots", "en-US", "annual-demo-3.png"),
};

const names = [
  "01-core-orientation.png",
  "02-steady-compass.png",
  "03-layout-clarity.png",
  "04-plan-alignment.png",
  "05-room-review.png",
  "06-local-report.png",
];

const copy = {
  zh: [
    ["罗盘坐向 · 户型参考", ["看清坐向", "一眼定局"], "把罗盘读数、户型落点与现场记录，整理成清晰的空间参考图。", ["离线使用", "本地保存", "一次性解锁"], "现场测向", "坐向、刻度、空间关系同屏确认", "当前方位参考", "185° S", "compassZh", "hero"],
    ["现场读数", ["专业罗盘", "稳定定位"], "红针、刻度、角度与参考信息同屏呈现，现场测向更稳。", ["红针读数", "双盘参考", "精密刻度"], "双盘结构", "地盘与空间参考一起看", "读数结构", "182.5° / 190°", "compassZh", "single"],
    ["格局整理", ["格局参考", "清晰归位"], "把方位、年度与阶段线索集中整理，复杂空间也能快速复盘。", ["九宫视图", "年度参考", "阶段整理"], "一屏理顺", "方位、年度、阶段集中呈现", "参考维度", "方位 / 年度 / 阶段", "gridZh", "grid"],
    ["户型关系", ["户型落点", "直接看图"], "中心点、开口与功能区落到真实户型里，现场判断更直观。", ["立极点", "开口方向", "功能区"], "平面落点", "中心、开口、房间关系一起看", "空间锚点", "中心 / 开口 / 房间", "planZh", "plan"],
    ["空间分组", ["卧室书房", "分开判断"], "每个房间独立记录，现场复盘和后续整理都更有秩序。", ["卧室", "书房", "客厅"], "按房间整理", "不同空间分开记录", "记录方式", "Room by room", "roomZh", "rooms"],
    ["记录与报告", ["本地保存", "按需分享"], "测向、户型和备注留在本机，需要沟通时再生成清晰报告。", ["无需登录", "本地记录", "报告导出"], "隐私优先", "离线记录，本地保存", "报告能力", "Local-first", "reportZh", "report"],
  ],
  en: [
    ["Compass direction · Plan reference", ["See Direction", "At A Glance"], "Organize compass readings, room positions, and field notes into one clear spatial reference.", ["Offline use", "Local records", "One-time unlock"], "On-site reading", "Direction, scale, and space in one view", "Current reference", "185° S", "compassEn", "hero"],
    ["Field reading", ["A Steady", "Field Compass"], "Needle, scale, angle, and reference notes stay together while you read.", ["Needle read", "Dual reference", "Clear scale"], "Dual structure", "Earth and spatial references together", "Reading structure", "182.5° / 190°", "compassEn", "single"],
    ["Layout review", ["Organize Layouts", "With Clarity"], "Keep direction, annual, and period references in one calm review screen.", ["Grid view", "Annual reference", "Period notes"], "One clean view", "Direction, year, and period together", "Reference layers", "Direction / Year / Period", "gridEn", "grid"],
    ["Plan relationship", ["Map Direction", "To Real Rooms"], "Place center points, openings, and room zones directly on a floor plan.", ["Center point", "Opening", "Room zones"], "Mapped to plan", "Center, opening, and room zones together", "Spatial anchors", "Center / Opening / Rooms", "planEn", "plan"],
    ["Room groups", ["Review Each", "Room Separately"], "Keep bedroom, study, living, and entry notes organized by space.", ["Bedroom", "Study", "Living"], "Room by room", "Different spaces stay separate", "Record mode", "Room by room", "roomEn", "rooms"],
    ["Records and reports", ["Save Locally", "Share When Ready"], "Compass checks, plans, and notes stay on device until you choose to export.", ["No login", "Local records", "Report export"], "Privacy first", "Offline checks, local records", "Report export", "Local-first", "reportEn", "report"],
  ],
};

function mkdirp(p) { fs.mkdirSync(p, { recursive: true }); }
function fileUrl(file) { return `file://${path.resolve(file).split(path.sep).map(encodeURIComponent).join("/")}`; }
function esc(v) { return String(v).replace(/[&<>"']/g, c => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c])); }
function validPng(file) {
  if (!fs.existsSync(file) || fs.statSync(file).size < 100000) return false;
  const fd = fs.openSync(file, "r");
  const b = Buffer.alloc(8);
  fs.readSync(fd, b, 0, 8, 0); fs.closeSync(fd);
  return b.toString("hex") === "89504e470d0a1a0a";
}

function scene(key, type, locale) {
  const src = assets[key];
  const rooms = locale === "zh" ? ["卧室", "书房", "客厅", "玄关"] : ["Bedroom", "Study", "Living", "Entry"];
  const cells = locale === "zh" ? ["东", "南", "西", "北", "中", "宅"] : ["East", "South", "West", "North", "Center", "Home"];
  const phone = `<div class="device"><div class="screen"><img src="${fileUrl(src)}"></div><div class="island"></div><div class="glass"></div></div>`;
  if (type === "grid") return `${phone}<div class="grid-cells">${cells.map(c => `<span>${esc(c)}</span>`).join("")}</div>`;
  if (type === "plan") return `${phone}<div class="plan"><span></span><span></span><span></span><span></span><i></i></div><div class="needle"></div>`;
  if (type === "rooms") return `${phone}<div class="rooms">${rooms.map((r, i) => `<span style="--i:${i}">${esc(r)}<i></i></span>`).join("")}</div>`;
  if (type === "report") return `${phone}<div class="mini-device"><div class="screen"><img src="${fileUrl(src)}"></div><div class="island"></div><div class="glass"></div></div>`;
  return `${phone}<div class="compass-object"><img src="${fileUrl(src)}"></div>`;
}

function html(item, locale, index) {
  const [kicker, title, sub, chips, featureSmall, featureText, metricSmall, metricText, sourceKey, type] = item;
  const en = locale === "en";
  const titleHtml = title.map(t => `<span>${esc(t)}</span>`).join("");
  const bg = type === "plan" || type === "grid" ? assets.bgChrome : assets.bgSilver;
  return `<!doctype html><html lang="${en ? "en" : "zh-Hans"}"><head><meta charset="utf-8"><meta name="viewport" content="width=${W}, height=${H}, initial-scale=1"><style>
*{box-sizing:border-box}html,body{margin:0;width:${W}px;height:${H}px;overflow:hidden;background:#f5f2e9}body{font-family:-apple-system,BlinkMacSystemFont,"SF Pro Display","PingFang SC","Hiragino Sans GB",sans-serif}.poster{position:relative;width:${W}px;height:${H}px;overflow:hidden;background:#f5f2e9;color:#111312}.poster:before{content:"";position:absolute;inset:-28px;background:url("${fileUrl(bg)}") center/cover no-repeat;filter:saturate(.82) contrast(1.04) brightness(1.03);transform:scale(1.06)}.poster:after{content:"";position:absolute;inset:0;background:radial-gradient(780px 640px at 70% 19%,rgba(210,180,112,.22),transparent 70%),radial-gradient(720px 620px at 19% 66%,rgba(255,255,255,.76),transparent 72%),linear-gradient(180deg,rgba(255,255,255,.91),rgba(247,242,229,.62) 43%,rgba(12,18,15,.09))}.grain{position:absolute;z-index:2;inset:0;opacity:.10;background-image:radial-gradient(rgba(18,16,12,.28) .55px,transparent .75px);background-size:7px 7px;mix-blend-mode:multiply}.top{position:absolute;z-index:24;left:82px;right:82px;top:78px;display:flex;align-items:center;justify-content:space-between}.brand{display:flex;align-items:center;gap:16px}.brand img{width:58px;height:58px;border-radius:17px;box-shadow:0 16px 42px rgba(31,25,16,.16)}.brand b,.brand span{display:block}.brand b{font-size:23px;color:#111312}.brand span{margin-top:5px;color:#65665f;font-size:16px;font-weight:650}.tag{height:46px;padding:0 20px;border-radius:999px;background:rgba(17,19,18,.86);color:#f9efd7;display:inline-flex;align-items:center;font-size:18px;font-weight:800;box-shadow:0 18px 44px rgba(0,0,0,.16)}.copy{position:absolute;z-index:22;left:82px;top:208px;width:900px}.kicker{margin-bottom:28px;color:#a98646;font-size:24px;font-weight:850}h1{margin:0;color:#0f1110;font-size:${en ? 88 : 112}px;line-height:${en ? 1.02 : .98};font-weight:900;letter-spacing:0}h1 span{display:block}.sub{margin-top:26px;max-width:760px;color:#535852;font-size:${en ? 29 : 31}px;line-height:1.38;font-weight:620}.chips{display:flex;gap:14px;margin-top:32px}.chips span{height:50px;padding:0 18px;border-radius:999px;background:rgba(255,255,255,.76);border:1px solid rgba(151,126,74,.22);box-shadow:0 14px 38px rgba(55,48,34,.08);display:inline-flex;align-items:center;color:#6c5630;font-size:19px;font-weight:780}.product-stage{position:absolute;z-index:5;left:0;right:0;bottom:0;height:1840px;background:radial-gradient(760px 520px at 56% 66%,rgba(255,255,255,.96),rgba(255,255,255,.36) 48%,transparent 76%),linear-gradient(180deg,transparent 0%,rgba(14,22,18,.08) 56%,rgba(7,11,10,.22))}.platform{position:absolute;z-index:8;left:148px;right:110px;bottom:188px;height:430px;border-radius:50%;background:radial-gradient(ellipse at center,rgba(38,44,39,.24),rgba(213,196,150,.18) 38%,transparent 72%);filter:blur(1px)}.device{position:absolute;z-index:16;right:${type === "report" ? 86 : 106}px;bottom:230px;width:${type === "report" ? 610 : 655}px;height:${type === "report" ? 1320 : 1418}px;border-radius:84px;padding:22px;background:linear-gradient(90deg,#0a0b0a,#5b625a 5%,#171917 12%,#090a09 88%,#827a67 96%,#151715);box-shadow:inset 0 0 0 2px rgba(255,255,255,.18),inset 28px 0 46px rgba(255,255,255,.12),inset -28px 0 46px rgba(0,0,0,.72),0 68px 160px rgba(0,0,0,.30);transform:rotate(-3.6deg);transform-origin:50% 100%}.device:before{content:"";position:absolute;inset:-10px;border-radius:96px;background:linear-gradient(112deg,rgba(255,255,255,.30),transparent 19%,transparent 82%,rgba(255,255,255,.30));pointer-events:none}.device:after{content:"";position:absolute;left:-12px;top:300px;width:12px;height:128px;border-radius:12px 0 0 12px;background:linear-gradient(180deg,#626a61,#121512);box-shadow:0 178px 0 #151816}.screen{position:relative;z-index:3;width:100%;height:100%;border-radius:62px;overflow:hidden;background:#fff}.screen img{display:block;width:100%;height:100%;object-fit:cover}.island{position:absolute;z-index:6;left:50%;top:34px;width:190px;height:55px;transform:translateX(-50%);border-radius:999px;background:#050505}.island:after{content:"";position:absolute;right:29px;top:18px;width:16px;height:16px;border-radius:50%;background:radial-gradient(circle at 35% 35%,#405869,#040506 70%)}.glass{position:absolute;z-index:7;inset:22px;border-radius:62px;background:linear-gradient(118deg,rgba(255,255,255,.36),transparent 22%,transparent 68%,rgba(255,255,255,.12)),linear-gradient(18deg,transparent,rgba(255,255,255,.16) 48%,transparent 58%);mix-blend-mode:screen;pointer-events:none}.compass-object{position:absolute;z-index:18;left:74px;bottom:468px;width:520px;height:520px;border-radius:50%;padding:24px;background:radial-gradient(circle at 34% 26%,#fff7dc,#d8b967 24%,#5c523e 66%,#151715 100%);box-shadow:0 48px 120px rgba(28,31,27,.28),inset 0 0 0 2px rgba(255,244,210,.46);transform:rotate(2deg)}.compass-object img{width:100%;height:100%;object-fit:cover;border-radius:50%}.readout{position:absolute;z-index:20;left:84px;bottom:390px;width:430px;padding:28px 32px;border-radius:28px;background:rgba(12,18,15,.91);border:1px solid rgba(204,169,87,.48);box-shadow:0 30px 76px rgba(0,0,0,.24);color:#fff7e7}.readout small{display:block;color:#cfc0a0;font-size:20px;font-weight:760}.readout b{display:block;margin-top:8px;font-size:50px;line-height:1;font-weight:900}.feature{position:absolute;z-index:21;right:78px;top:730px;width:330px;padding:26px 28px;border-radius:28px;background:rgba(255,255,255,.84);border:1px solid rgba(255,255,255,.86);box-shadow:0 30px 78px rgba(27,33,29,.14);backdrop-filter:blur(18px)}.feature small{display:block;color:#8b7140;font-size:18px;font-weight:850}.feature b{display:block;margin-top:8px;color:#101210;font-size:${en ? 28 : 31}px;line-height:1.08;font-weight:880}.line-art{position:absolute;z-index:4;right:-300px;bottom:625px;width:1080px;height:1080px;border:1px solid rgba(169,139,75,.17);border-radius:50%}.line-art:before,.line-art:after{content:"";position:absolute;inset:126px;border-radius:50%;border:1px solid rgba(18,24,21,.08);transform:rotate(18deg) scaleX(1.26)}.line-art:after{inset:296px;border-color:rgba(169,139,75,.16);transform:rotate(-32deg) scaleX(1.5)}.grid-cells{position:absolute;z-index:19;left:90px;bottom:720px;display:grid;grid-template-columns:repeat(2,150px);gap:12px}.grid-cells span{height:126px;border-radius:12px;background:#fff;border:1px solid rgba(169,139,75,.22);box-shadow:0 14px 38px rgba(55,48,34,.09);display:flex;align-items:center;justify-content:center;font-size:28px;font-weight:850}.plan{position:absolute;z-index:19;left:78px;bottom:630px;width:460px;height:460px;display:grid;grid-template-columns:1fr 1fr;border:2px solid rgba(61,55,39,.42);box-shadow:0 28px 80px rgba(38,31,16,.16)}.plan span{border:1px solid rgba(61,55,39,.30)}.plan span:nth-child(1){background:#dcebe2}.plan span:nth-child(2){background:#eee1bb}.plan span:nth-child(3){background:#dfe9f2}.plan span:nth-child(4){background:#ead7d4}.plan i{position:absolute;left:50%;top:50%;width:26px;height:26px;border-radius:50%;background:#151614;transform:translate(-50%,-50%)}.needle{position:absolute;z-index:20;left:304px;bottom:980px;width:8px;height:360px;background:#b32927}.needle:before{content:"";position:absolute;left:50%;top:-52px;transform:translateX(-50%);border-left:30px solid transparent;border-right:30px solid transparent;border-bottom:72px solid #b32927}.rooms{position:absolute;z-index:20;left:82px;bottom:735px;display:flex;flex-direction:column;gap:20px}.rooms span{position:relative;width:340px;padding:24px 28px;border-radius:22px;background:#fff;border:1px solid rgba(190,164,96,.25);box-shadow:0 16px 45px rgba(43,38,25,.10);font-size:29px;font-weight:850;transform:translateX(calc(var(--i) * 20px))}.rooms span:nth-child(1){background:#dceee4}.rooms span:nth-child(2){background:#efe8c8}.rooms span:nth-child(3){background:#dfe9f3}.rooms span:nth-child(4){background:#ead7d4}.rooms i{position:absolute;right:24px;top:50%;width:60px;height:2px;background:#b8934f}.mini-device{position:absolute;z-index:15;left:118px;bottom:410px;width:370px;height:800px;border-radius:55px;padding:14px;background:#111;transform:rotate(4deg);box-shadow:0 48px 120px rgba(0,0,0,.28)}.mini-device .screen{border-radius:42px}.mini-device .island{top:22px;width:112px;height:34px}.mini-device .glass{inset:14px;border-radius:42px}footer{position:absolute;z-index:25;left:82px;bottom:72px;color:rgba(16,18,17,.54);font-size:20px;font-weight:650}
</style></head><body><main class="poster"><div class="grain"></div><div class="top"><div class="brand"><img src="${fileUrl(assets.icon)}"><div><b>${en ? "TAME Space Compass" : "探觅·空间罗盘"}</b><span>${en ? "Spatial reference tool" : "TAME Space Compass"}</span></div></div><div class="tag">${en ? "Local records · Report export" : "本地记录 · 报告导出"}</div></div><section class="copy"><div class="kicker">${esc(kicker)}</div><h1>${titleHtml}</h1><p class="sub">${esc(sub)}</p><div class="chips">${chips.map(c => `<span>${esc(c)}</span>`).join("")}</div></section><div class="product-stage"></div><div class="platform"></div><div class="line-art"></div><aside class="feature"><small>${esc(featureSmall)}</small><b>${esc(featureText)}</b></aside>${scene(sourceKey, type, locale)}<div class="readout"><small>${esc(metricSmall)}</small><b>${esc(metricText)}</b></div><footer>${en ? "For spatial and cultural reference only. No outcome is promised." : "仅作空间与民俗文化参考，不承诺现实结果。"}</footer></main></body></html>`;
}

function render(htmlPath, outPath) {
  const profile = path.join(chromeProfileRoot, outPath.replace(/[^a-zA-Z0-9]+/g, "-"));
  fs.rmSync(profile, { recursive: true, force: true }); fs.rmSync(outPath, { force: true }); mkdirp(profile);
  const args = ["--headless=new","--disable-gpu","--disable-background-networking","--disable-component-update","--disable-default-apps","--disable-extensions","--disable-sync","--no-first-run","--no-default-browser-check","--hide-scrollbars","--allow-file-access-from-files","--force-device-scale-factor=1","--run-all-compositor-stages-before-draw","--virtual-time-budget=3000",`--user-data-dir=${profile}`,`--window-size=${W},${H}`,`--screenshot=${outPath}`,fileUrl(htmlPath)];
  const r = spawnSync(chromeBin, args, { stdio: "ignore", timeout: 16000 });
  try { spawnSync("pkill", ["-f", profile], { stdio: "ignore" }); } catch {}
  if (!validPng(outPath)) throw new Error(String(r.error || r.status || "Chrome failed"));
}

function contact(files, out) {
  const py = `
from PIL import Image, ImageDraw
from pathlib import Path
files=${JSON.stringify(files)}
out=Path(${JSON.stringify(out)})
tw=360; th=round(tw*2778/1284); gap=22; lh=36
sheet=Image.new("RGB",(tw*3+gap*4,(th+lh)*2+gap*3),"#ebe7dc")
d=ImageDraw.Draw(sheet)
for i,f in enumerate(files):
    im=Image.open(f).convert("RGB").resize((tw,th),Image.Resampling.LANCZOS)
    x=gap+(i%3)*(tw+gap); y=gap+(i//3)*(th+lh+gap)
    sheet.paste(im,(x,y)); d.text((x,y+th+10),Path(f).name,fill="#32302a")
out.parent.mkdir(parents=True,exist_ok=True); sheet.save(out,quality=92)
`;
  spawnSync("python3", ["-c", py], { stdio: "ignore" });
}

function build(locale, dir) {
  mkdirp(dir);
  const outs = [];
  copy[locale].forEach((item, i) => {
    const h = path.join(htmlDir, `${locale}-${String(i + 1).padStart(2, "0")}.html`);
    const o = path.join(dir, names[i]);
    fs.writeFileSync(h, html(item, locale, i));
    render(h, o);
    outs.push(o);
  });
  spawnSync("python3", ["-c", `from PIL import Image\\nfor f in ${JSON.stringify(outs)}: Image.open(f).convert("RGB").save(f)`], { stdio: "ignore" });
  return outs;
}

function main() {
  [htmlDir, sheetDir, zhDir, enDir, chromeProfileRoot].forEach(mkdirp);
  Object.values(assets).forEach(f => { if (!fs.existsSync(f)) throw new Error(`Missing ${f}`); });
  const target = process.argv[2] || "all";
  const zh = target === "all" || target === "zh" ? build("zh", zhDir) : names.map(n => path.join(zhDir, n));
  const en = target === "all" || target === "en" ? build("en", enDir) : names.map(n => path.join(enDir, n));
  if (zh.every(fs.existsSync)) contact(zh, path.join(sheetDir, "zh-Hans-contactsheet.jpg"));
  if (en.every(fs.existsSync)) contact(en, path.join(sheetDir, "en-US-contactsheet.jpg"));
  console.log(`zh: ${zhDir}`);
  console.log(`en: ${enDir}`);
  console.log(`sheets: ${sheetDir}`);
}

main();
