#!/usr/bin/env node

const path = require("path");
const fs = require("fs");
const { execFileSync } = require("child_process");

const root = path.resolve(__dirname, "..");
const html = path.join(root, "AppStoreAssets", "new-standard-sample", "zh-01-new-standard.html");
const out = path.join(root, "AppStoreAssets", "new-standard-sample", "zh-01-new-standard.png");
const chromeBin = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const profile = path.join(root, "build", "chrome-appstore-render-profile", "new-standard-sample");

function fileUrl(file) {
  return `file://${path.resolve(file).split(path.sep).map(encodeURIComponent).join("/")}`;
}

fs.mkdirSync(path.dirname(out), { recursive: true });
fs.mkdirSync(profile, { recursive: true });

execFileSync(chromeBin, [
  "--headless=new",
  "--hide-scrollbars",
  "--disable-gpu",
  "--force-device-scale-factor=1",
  "--no-first-run",
  "--no-default-browser-check",
  `--user-data-dir=${profile}`,
  "--window-size=1284,2778",
  "--run-all-compositor-stages-before-draw",
  "--virtual-time-budget=3000",
  `--screenshot=${out}`,
  fileUrl(html),
], { stdio: "inherit", timeout: 60000 });

console.log(out);
