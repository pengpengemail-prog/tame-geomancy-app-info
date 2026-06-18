#!/usr/bin/env python3

from __future__ import annotations

import json
import pathlib
import re
import sys
from importlib.machinery import SourceFileLoader


ROOT = pathlib.Path("/Users/pengpeng/Desktop/codex工作区/TAMEGeomancy").resolve()
OPS_PATH = ROOT / "scripts/asc_tame_ops.py"
ops = SourceFileLoader("asc_tame_ops", str(OPS_PATH)).load_module()

APP_ID = "6768040370"
VERSION_STRING = "1.0"
SUPPORT_URL = "https://pengpengemail-prog.github.io/tame-geomancy-app-info/support.html"
PRIVACY_URL = "https://pengpengemail-prog.github.io/tame-geomancy-app-info/privacy-policy.html"
MARKETING_URL = "https://pengpengemail-prog.github.io/tame-geomancy-app-info/"
EULA_URL = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
KEY_PATH = pathlib.Path("/Users/pengpeng/Desktop/ApiKey_L6Y9VYEJFJYS.p8")

EN_METADATA = {
    "name": "TAME Space Compass",
    "subtitle": "Feng Shui Compass & Floor Plan",
    "promotionalText": "Check orientation, place a nine-grid overlay, and turn floor plan notes into private shareable reference reports. Works offline.",
    "keywords": "feng shui,luopan,compass,bagua,flying star,floor plan,home layout,orientation,interior,rooms",
    "description": """A calmer feng shui compass for orientation and floor plan reference.

TAME Space Compass brings a luopan-inspired compass, floor plan overlay, and nine-grid reference tools into one private offline app. It is designed for homeowners, interior designers, and traditional-culture enthusiasts who want a cleaner way to organize spatial references without exaggerated claims.

Key Features
- Dual-ring compass with Earth plate and space plate
- Orientation reference for doors, balconies, and windows
- Year and period overview
- Bagua, flying star, and nine-grid charts for layout review
- Floor plan import with center point placement and 3x3 heatmap overlay
- Local history, notes, and shareable report cards

Why It Stands Out
- Works fully offline
- Keeps data private on device
- Designed for quick on-site reference
- Uses calm, review-safe language

Premium Access
TAME Space Compass Premium unlocks report sharing and save-to-Photos features. Restore Purchases is available inside Settings > Premium Access.

Important
This app is provided for traditional-culture and spatial-reference use only. It is not scientific advice and does not make medical, financial, wealth, destiny, or guaranteed-outcome claims.

Terms of Use (EULA): {eula}""".format(eula=EULA_URL),
    "whatsNew": "",
}

ZH_METADATA = {
    "name": "探觅·空间罗盘",
    "subtitle": "风水罗盘与户型坐向参考",
    "promotionalText": "看坐向、定立极、叠九宫，把罗盘与户型图整理成清晰的空间参考报告。离线运行，记录可保存分享。",
    "keywords": "风水,罗盘,堪舆,指南针,坐向,户型图,九宫,飞星,八宅,阳宅,布局,方位,量房,家居,空间",
    "description": """把风水罗盘、户型坐向与九宫参考放进一部手机里。

探觅·空间罗盘是一款离线空间参考工具，适合看房、量房、家居布局复盘、风水罗盘学习与室内设计沟通。你可以查看坐向，导入户型图，设置立极点，叠加九宫网格，并保存成可分享的参考报告。

核心功能
- 双盘罗盘：地盘正针与空间盘同屏显示，固定 7.5 度偏移
- 坐向与开口参考：查看大门、阳台与主窗的方向信息
- 周期参考：支持阶段切换与年份对照
- 九宫布局：查看飞星、八宅与年度参考信息
- 户型图分析：导入图片、设置立极点、叠加九宫热力图
- 空间建议：查看房间分组与布局参考
- 历史记录：保存分析、编辑备注、生成参考报告卡

为什么选择探觅·空间罗盘
- 全程离线运行，数据留在本地
- 页面简洁，重点信息更集中
- 适合在看房、量房、复盘布局时快速使用
- 结论表达克制，避免夸张承诺

高级解锁
探觅·空间罗盘高级解锁用于解锁报告分享与保存到相册能力。恢复购买入口位于“设置 > 高级解锁”。

适合谁使用
- 空间观察用户
- 室内设计师
- 房屋业主
- 需要整理户型参考信息的使用者

说明
本 App 内容仅为传统文化、民俗文化与空间参考，不构成科学依据、专业建议或个人结果承诺。

使用条款（EULA）：{eula}""".format(eula=EULA_URL),
}


def extract_submission_review_notes(path: pathlib.Path) -> str:
    text = path.read_text(encoding="utf-8")
    match = re.search(r"## 当前提交用审核备注（API 同步版）\s+(.*?)\s+## 推荐审核备注", text, flags=re.S)
    if match:
        notes = match.group(1).strip()
        if len(notes.encode("utf-8")) > 4000:
            raise RuntimeError("Submission review notes exceed ASC 4000-byte limit")
        return notes
    match = re.search(r"### 中文版\s+(.*?)\s+### English Version", text, flags=re.S)
    if not match:
        raise RuntimeError("Could not locate submission review notes block")
    notes = match.group(1).strip()
    if len(notes.encode("utf-8")) > 4000:
        raise RuntimeError("Review notes exceed ASC 4000-byte limit")
    return notes


def main() -> int:
    client = ops.ASCClient(KEY_PATH, None, None)
    app = ops.find_app(client, "com.tame.geomancy")
    if not app:
        raise RuntimeError("App com.tame.geomancy not found in ASC")
    versions = ops.list_versions(client, app["id"], VERSION_STRING)
    if not versions:
        raise RuntimeError(f"Version {VERSION_STRING} not found for app")
    version = versions[0]

    app_info_payload = client.request(
        "GET",
        f"/v1/apps/{app['id']}/appInfos",
        params={
            "include": "appInfoLocalizations",
            "limit[appInfoLocalizations]": "50",
            "fields[appInfos]": "appInfoLocalizations",
            "fields[appInfoLocalizations]": "locale,name,subtitle,privacyPolicyUrl",
        },
    )
    app_info = app_info_payload["data"][0]
    app_info_localizations = [item for item in app_info_payload.get("included", []) if item.get("type") == "appInfoLocalizations"]

    version_payload = client.request(
        "GET",
        f"/v1/apps/{app['id']}/appStoreVersions",
        params={
            "filter[platform]": "IOS",
            "filter[versionString]": VERSION_STRING,
            "include": "appStoreVersionLocalizations,appStoreReviewDetail",
            "limit[appStoreVersionLocalizations]": "50",
            "fields[appStoreVersions]": "appStoreVersionLocalizations,appStoreReviewDetail,versionString",
            "fields[appStoreVersionLocalizations]": "locale,description,keywords,marketingUrl,promotionalText,supportUrl,whatsNew",
            "fields[appStoreReviewDetails]": "notes",
        },
    )
    version_data = version_payload["data"][0]
    version_localizations = [item for item in version_payload.get("included", []) if item.get("type") == "appStoreVersionLocalizations"]
    review_detail = next((item for item in version_payload.get("included", []) if item.get("type") == "appStoreReviewDetails"), None)

    zh_app_loc = ops.first_data({"data": [item for item in app_info_localizations if item.get("attributes", {}).get("locale") == "zh-Hans"]})
    en_app_loc = ops.first_data({"data": [item for item in app_info_localizations if item.get("attributes", {}).get("locale") == "en-US"]})
    zh_version_loc = ops.first_data({"data": [item for item in version_localizations if item.get("attributes", {}).get("locale") == "zh-Hans"]})
    en_version_loc = ops.first_data({"data": [item for item in version_localizations if item.get("attributes", {}).get("locale") == "en-US"]})

    actions = []

    if zh_app_loc:
        resp = client.request(
            "PATCH",
            f"/v1/appInfoLocalizations/{zh_app_loc['id']}",
            data={
                "data": {
                    "type": "appInfoLocalizations",
                    "id": zh_app_loc["id"],
                    "attributes": {
                        "name": ZH_METADATA["name"],
                        "subtitle": ZH_METADATA["subtitle"],
                        "privacyPolicyUrl": PRIVACY_URL,
                    },
                }
            },
        )
        actions.append({"kind": "appInfoLocalization", "locale": "zh-Hans", "id": resp["data"]["id"]})

    if zh_version_loc:
        resp = client.request(
            "PATCH",
            f"/v1/appStoreVersionLocalizations/{zh_version_loc['id']}",
            data={
                "data": {
                    "type": "appStoreVersionLocalizations",
                    "id": zh_version_loc["id"],
                    "attributes": {
                        "description": ZH_METADATA["description"],
                        "keywords": ZH_METADATA["keywords"],
                        "marketingUrl": MARKETING_URL,
                        "promotionalText": ZH_METADATA["promotionalText"],
                        "supportUrl": SUPPORT_URL,
                    },
                }
            },
        )
        actions.append({"kind": "appStoreVersionLocalization", "locale": "zh-Hans", "id": resp["data"]["id"]})

    if en_app_loc:
        resp = client.request(
            "PATCH",
            f"/v1/appInfoLocalizations/{en_app_loc['id']}",
            data={
                "data": {
                    "type": "appInfoLocalizations",
                    "id": en_app_loc["id"],
                    "attributes": {
                        "name": EN_METADATA["name"],
                        "subtitle": EN_METADATA["subtitle"],
                        "privacyPolicyUrl": PRIVACY_URL,
                    },
                }
            },
        )
        actions.append({"kind": "appInfoLocalization", "locale": "en-US", "id": resp["data"]["id"]})
    else:
        resp = client.request(
            "POST",
            "/v1/appInfoLocalizations",
            data={
                "data": {
                    "type": "appInfoLocalizations",
                    "attributes": {
                        "locale": "en-US",
                        "name": EN_METADATA["name"],
                        "subtitle": EN_METADATA["subtitle"],
                        "privacyPolicyUrl": PRIVACY_URL,
                    },
                    "relationships": {
                        "appInfo": {"data": {"type": "appInfos", "id": app_info["id"]}}
                    },
                }
            },
        )
        actions.append({"kind": "appInfoLocalization", "locale": "en-US", "id": resp["data"]["id"]})

    if en_version_loc:
        resp = client.request(
            "PATCH",
            f"/v1/appStoreVersionLocalizations/{en_version_loc['id']}",
            data={
                "data": {
                    "type": "appStoreVersionLocalizations",
                    "id": en_version_loc["id"],
                    "attributes": {
                        "description": EN_METADATA["description"],
                        "keywords": EN_METADATA["keywords"],
                        "marketingUrl": MARKETING_URL,
                        "promotionalText": EN_METADATA["promotionalText"],
                        "supportUrl": SUPPORT_URL,
                    },
                }
            },
        )
        actions.append({"kind": "appStoreVersionLocalization", "locale": "en-US", "id": resp["data"]["id"]})
    else:
        resp = client.request(
            "POST",
            "/v1/appStoreVersionLocalizations",
            data={
                "data": {
                    "type": "appStoreVersionLocalizations",
                    "attributes": {
                        "locale": "en-US",
                        "description": EN_METADATA["description"],
                        "keywords": EN_METADATA["keywords"],
                        "marketingUrl": MARKETING_URL,
                        "promotionalText": EN_METADATA["promotionalText"],
                        "supportUrl": SUPPORT_URL,
                    },
                    "relationships": {
                        "appStoreVersion": {"data": {"type": "appStoreVersions", "id": version_data["id"]}}
                    },
                }
            },
        )
        actions.append({"kind": "appStoreVersionLocalization", "locale": "en-US", "id": resp["data"]["id"]})

    review_notes = extract_submission_review_notes(ROOT / "APP_REVIEW_NOTES.md")
    if review_detail:
        resp = client.request(
            "PATCH",
            f"/v1/appStoreReviewDetails/{review_detail['id']}",
            data={
                "data": {
                    "type": "appStoreReviewDetails",
                    "id": review_detail["id"],
                    "attributes": {"notes": review_notes},
                }
            },
        )
        actions.append({"kind": "appStoreReviewDetails", "locale": "review", "id": resp["data"]["id"]})

    print(json.dumps({"status": "ok", "actions": actions}, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(str(exc), file=sys.stderr)
        raise SystemExit(1)
