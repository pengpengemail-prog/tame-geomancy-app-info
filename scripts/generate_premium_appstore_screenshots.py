#!/usr/bin/env python3
"""Generate premium App Store screenshot posters for TAME Space Compass.

The output is deterministic and uses real verification screenshots as the UI
body layer. It intentionally avoids Figma/UI clicking so screenshot iteration
can be repeated quickly from the command line.
"""

from __future__ import annotations

import math
import os
import random
from pathlib import Path
from typing import Iterable

from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageOps


ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "AppStoreAssets"
SHOTS = ROOT / "VerificationShots"
OUT_ZH = ASSETS / "zh-Hans-premium-v3"
OUT_EN = ASSETS / "en-US-premium-v3"
CONTACT_DIR = ASSETS / "generated-marketing" / "premium-v3"

W, H = 1284, 2778
BG = (248, 247, 243)
PAPER = (253, 252, 249)
INK = (15, 17, 18)
MUTED = (99, 101, 101)
GOLD = (186, 157, 93)
GOLD_DARK = (151, 126, 72)
LINE = (223, 215, 199)
GREEN = (47, 70, 61)
RED = (186, 49, 42)
BLUE = (214, 224, 232)
PINK = (234, 216, 214)


FONTS = {
    "zh_bold": "/System/Library/Fonts/STHeiti Medium.ttc",
    "zh_regular": "/System/Library/Fonts/STHeiti Light.ttc",
    "en_bold": "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
    "en_regular": "/System/Library/Fonts/Supplemental/Arial.ttf",
}


def font(locale: str, size: int, weight: str = "regular") -> ImageFont.FreeTypeFont:
    key = ("zh_" if locale == "zh" else "en_") + ("bold" if weight == "bold" else "regular")
    return ImageFont.truetype(FONTS[key], size)


def ensure_dirs() -> None:
    for d in [OUT_ZH, OUT_EN, CONTACT_DIR]:
        d.mkdir(parents=True, exist_ok=True)


def load(path: Path) -> Image.Image:
    return Image.open(path).convert("RGB")


def rounded_mask(size: tuple[int, int], radius: int) -> Image.Image:
    mask = Image.new("L", size, 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle((0, 0, size[0] - 1, size[1] - 1), radius=radius, fill=255)
    return mask


def paste_rounded(base: Image.Image, img: Image.Image, xy: tuple[int, int], radius: int) -> None:
    mask = rounded_mask(img.size, radius)
    base.paste(img, xy, mask)


def draw_paper_background(draw: ImageDraw.ImageDraw, seed: int, dark_anchor: str = "none") -> None:
    random.seed(seed)
    draw.rectangle((0, 0, W, H), fill=BG)

    # Subtle paper grain.
    for _ in range(8500):
        x = random.randrange(W)
        y = random.randrange(H)
        v = random.choice([-5, -4, -3, 3, 4, 5])
        c = tuple(max(0, min(255, BG[i] + v)) for i in range(3))
        draw.point((x, y), fill=c)

    # Thin geometric compass/plan motifs, kept quiet.
    for r, alpha_c in [(620, (232, 226, 211)), (440, (239, 232, 216)), (250, (228, 219, 199))]:
        cx, cy = 1010, 560
        draw.ellipse((cx - r, cy - r, cx + r, cy + r), outline=alpha_c, width=3)
    for deg in range(0, 360, 30):
        cx, cy = 1010, 560
        a = math.radians(deg)
        r1, r2 = 180, 620
        draw.line(
            (cx + math.cos(a) * r1, cy + math.sin(a) * r1, cx + math.cos(a) * r2, cy + math.sin(a) * r2),
            fill=(235, 229, 215),
            width=2,
        )

    if dark_anchor == "left":
        draw.rectangle((0, 1768, 330, H), fill=GREEN)
        draw.arc((-280, 1620, 620, 2520), 270, 90, fill=(73, 95, 85), width=3)
    elif dark_anchor == "bottom":
        draw.rectangle((0, 2205, W, H), fill=GREEN)
        draw.line((120, 2260, 1160, 2260), fill=(106, 124, 113), width=2)
    elif dark_anchor == "right":
        draw.rectangle((1020, 0, W, H), fill=GREEN)
        draw.line((1065, 130, 1065, 2560), fill=(79, 98, 89), width=2)


def draw_copy(
    draw: ImageDraw.ImageDraw,
    locale: str,
    frame_no: str,
    kicker: str,
    title: str,
    sub: str,
    x: int,
    y: int,
    max_width: int,
    dark: bool = False,
) -> int:
    fg = PAPER if dark else INK
    muted = (216, 211, 200) if dark else MUTED
    accent = (220, 191, 126) if dark else GOLD

    draw.text((x, y), frame_no, fill=accent, font=font(locale, 28, "bold"))
    draw.line((x + 62, y + 20, x + 178, y + 20), fill=accent, width=2)
    y += 70
    draw.text((x, y), kicker, fill=accent, font=font(locale, 24, "bold"))
    y += 54
    y = draw_wrapped(draw, title, x, y, max_width, font(locale, 72 if locale == "zh" else 64, "bold"), fg, 1.05)
    y += 28
    y = draw_wrapped(draw, sub, x, y, max_width, font(locale, 31 if locale == "zh" else 29, "regular"), muted, 1.28)
    return y


def wrap_line(
    draw: ImageDraw.ImageDraw,
    text: str,
    max_width: int,
    fnt: ImageFont.FreeTypeFont,
) -> list[str]:
    if any("\u4e00" <= ch <= "\u9fff" for ch in text):
        tokens = list(text)
        sep = ""
    else:
        tokens = text.split(" ")
        sep = " "

    lines: list[str] = []
    line = ""
    for token in tokens:
        probe = token if not line else line + sep + token
        if draw.textbbox((0, 0), probe, font=fnt)[2] <= max_width:
            line = probe
        else:
            if line:
                lines.append(line)
            line = token
    if line:
        lines.append(line)

    return lines


def draw_wrapped(
    draw: ImageDraw.ImageDraw,
    text: str,
    x: int,
    y: int,
    max_width: int,
    fnt: ImageFont.FreeTypeFont,
    fill: tuple[int, int, int],
    line_factor: float = 1.2,
) -> int:
    if not text:
        return y
    lines: list[str] = []
    for hard_line in text.splitlines():
        lines.extend(wrap_line(draw, hard_line, max_width, fnt) or [""])

    line_h = int(fnt.size * line_factor)
    for line in lines:
        draw.text((x, y), line, fill=fill, font=fnt)
        y += line_h
    return y


def crop_to_phone_ratio(img: Image.Image) -> Image.Image:
    # Keep the real UI body, trimming a little horizontal simulator whitespace if present.
    target = 1206 / 2622
    w, h = img.size
    ratio = w / h
    if ratio > target:
        nw = int(h * target)
        x = (w - nw) // 2
        img = img.crop((x, 0, x + nw, h))
    elif ratio < target:
        nh = int(w / target)
        y = max(0, (h - nh) // 2)
        img = img.crop((0, y, w, y + nh))
    return img


def phone_mockup(
    src: Image.Image,
    width: int,
    rotate: float = 0,
    shadow: bool = True,
    ring: tuple[int, int, int] = (24, 24, 22),
) -> Image.Image:
    src = crop_to_phone_ratio(src)
    screen_w = width
    screen_h = int(width * 2622 / 1206)
    screen = ImageOps.fit(src, (screen_w, screen_h), Image.Resampling.LANCZOS)
    pad = max(22, width // 22)
    radius = max(44, width // 9)
    outer = Image.new("RGBA", (screen_w + pad * 2, screen_h + pad * 2), (0, 0, 0, 0))

    d = ImageDraw.Draw(outer)
    if shadow:
        sh = Image.new("RGBA", outer.size, (0, 0, 0, 0))
        sd = ImageDraw.Draw(sh)
        sd.rounded_rectangle((pad, pad, pad + screen_w, pad + screen_h), radius=radius, fill=(0, 0, 0, 80))
        sh = sh.filter(ImageFilter.GaussianBlur(max(20, width // 18)))
        outer.alpha_composite(sh, (0, max(10, width // 20)))

    d.rounded_rectangle((pad - 8, pad - 8, pad + screen_w + 8, pad + screen_h + 8), radius=radius + 12, fill=ring)
    d.rounded_rectangle((pad, pad, pad + screen_w, pad + screen_h), radius=radius, fill=PAPER)
    mask = rounded_mask((screen_w, screen_h), radius - 6)
    outer.paste(screen.convert("RGBA"), (pad, pad), mask)

    # Very light glass edge, not over the UI text.
    d.rounded_rectangle((pad + 9, pad + 9, pad + screen_w - 9, pad + screen_h - 9), radius=radius - 18, outline=(255, 255, 255, 88), width=3)

    if rotate:
        outer = outer.rotate(rotate, resample=Image.Resampling.BICUBIC, expand=True)
    return outer


def paste_shadowed(base: Image.Image, layer: Image.Image, xy: tuple[int, int]) -> None:
    base.alpha_composite(layer, xy)


def compass_detail(src: Image.Image, size: int, alpha: int = 210) -> Image.Image:
    # Crop the compass area from the real screen and use it as a product proof detail.
    src = crop_to_phone_ratio(src)
    w, h = src.size
    box = (int(w * 0.06), int(h * 0.24), int(w * 0.94), int(h * 0.72))
    detail = ImageOps.fit(src.crop(box), (size, size), Image.Resampling.LANCZOS)
    mask = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(mask)
    d.ellipse((0, 0, size - 1, size - 1), fill=alpha)
    detail = detail.convert("RGBA")
    detail.putalpha(mask)
    return detail


def draw_floorplan_graphic(draw: ImageDraw.ImageDraw, x: int, y: int, scale: float = 1.0) -> None:
    cell = int(132 * scale)
    colors = [(223, 236, 226), (241, 236, 206), (232, 238, 245), (238, 220, 218)]
    coords = [(0, 0), (cell, 0), (0, cell), (cell, cell)]
    for i, (cx, cy) in enumerate(coords):
        draw.rounded_rectangle((x + cx, y + cy, x + cx + cell, y + cy + cell), radius=2, fill=colors[i], outline=(178, 171, 154), width=2)
    draw.line((x + cell, y, x + cell, y + cell * 2), fill=(92, 83, 74), width=3)
    draw.line((x, y + cell, x + cell * 2, y + cell), fill=(92, 83, 74), width=3)
    cx = x + cell
    cy = y + cell
    draw.ellipse((cx - 22, cy - 22, cx + 22, cy + 22), fill=INK)
    draw.line((cx, cy - int(150 * scale), cx, cy + int(42 * scale)), fill=RED, width=max(3, int(7 * scale)))
    draw.polygon([(cx, cy - int(165 * scale)), (cx - int(18 * scale), cy - int(118 * scale)), (cx + int(18 * scale), cy - int(118 * scale))], fill=RED)


def draw_ring_metric(draw: ImageDraw.ImageDraw, cx: int, cy: int, r: int, label: str, value: str, locale: str) -> None:
    draw.ellipse((cx - r, cy - r, cx + r, cy + r), outline=LINE, width=4)
    draw.arc((cx - r, cy - r, cx + r, cy + r), -90, 190, fill=GOLD, width=14)
    draw.text((cx - r + 26, cy - 36), label, fill=MUTED, font=font(locale, 26, "regular"))
    draw.text((cx - r + 26, cy + 2), value, fill=INK, font=font(locale, 40, "bold"))


def save_rgb(img: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    img.convert("RGB").save(path, "PNG", optimize=True)


def frame_canvas(seed: int, anchor: str = "none") -> tuple[Image.Image, ImageDraw.ImageDraw]:
    canvas = Image.new("RGBA", (W, H), BG + (255,))
    draw = ImageDraw.Draw(canvas)
    draw_paper_background(draw, seed, anchor)
    return canvas, draw


def make_frames(locale: str, out_dir: Path) -> list[Path]:
    is_zh = locale == "zh"
    copy = [
        ("01", "TAME Space Compass / 探觅·空间罗盘" if is_zh else "TAME Space Compass", "把空间方位\n变成清晰判断" if is_zh else "Turn Orientation\nInto Clear Decisions", "双盘罗盘、户型参考、本地报告" if is_zh else "Dual compass, floor-plan notes, local reports"),
        ("02", "双盘罗盘" if is_zh else "Dual Compass", "现场测向\n同屏对照" if is_zh else "Measure On Site\nWith Two Plates", "地盘与空间盘同步显示，快速确认坐向" if is_zh else "Earth and space plates stay visible in one view"),
        ("03", "九宫布局" if is_zh else "Nine-Grid Layouts", "格局参考\n不用重新记" if is_zh else "Read Layouts\nWithout Rework", "九宫、飞星与年度参考集中查看" if is_zh else "Grid, period, and annual references stay together"),
        ("04", "户型叠加" if is_zh else "Plan Overlay", "空间关系\n直接看图" if is_zh else "See Spatial\nRelations Clearly", "导入户型，标记立极点与功能区" if is_zh else "Import a plan, place the center, mark key rooms"),
        ("05", "房间分组" if is_zh else "Room Groups", "不同空间\n分开判断" if is_zh else "Separate Notes\nBy Room Type", "卧室、书房、客厅各自成组" if is_zh else "Bedrooms, studies, and living rooms stay organized"),
        ("06", "记录报告" if is_zh else "Records", "生成可分享\n参考报告" if is_zh else "Save And Share\nReference Reports", "本地记录，便于复盘和交接" if is_zh else "Private local records for later review"),
    ]

    compass = load(SHOTS / "compass_red_pointer_arrow_unified.png")
    compass_marked = load(SHOTS / "compass_pointer_to_marked_ring.png")
    overview = load(SHOTS / ("overview-nine-palace-2026-05-22.png" if is_zh else "en-US/flying-star-demo-2.png"))
    analysis = load(SHOTS / ("analysis-yanggong-entry-2026-05-22.png" if is_zh else "en-US/annual-demo-3.png"))
    bazhai = load(SHOTS / "yanggong-fenjin-clean.png") if is_zh else load(ASSETS / "en-US" / "05-bazhai.png")
    records = load(SHOTS / "overview-graphical-entry-2026-05-22.png") if is_zh else load(ASSETS / "en-US" / "06-record-share.png")

    paths: list[Path] = []

    # 01 hero: editorial poster, large real compass detail plus device.
    img, d = frame_canvas(1, "bottom")
    detail = compass_detail(compass_marked, 1030, 188)
    img.alpha_composite(detail, (-185, 760))
    draw_copy(d, locale, *copy[0], x=92, y=122, max_width=850)
    d.rectangle((92, 518, 328, 526), fill=GOLD)
    d.text((92, 558), "坐向  /  空间盘  /  九宫参考" if is_zh else "Orientation / Space Plate / Layout Notes", fill=MUTED, font=font(locale, 26, "regular"))
    p = phone_mockup(compass_marked, 590, rotate=-4)
    paste_shadowed(img, p, (612, 720))
    d.text((88, 2362), "01", fill=(218, 190, 129), font=font(locale, 34, "bold"))
    d.text((88, 2418), "工具不是玄学堆字，而是一套现场空间仪表。" if is_zh else "A field instrument for reading spatial orientation.", fill=(229, 225, 215), font=font(locale, 29, "regular"))
    out = out_dir / "01.png"
    save_rgb(img, out)
    paths.append(out)

    # 02: full device workflow with side instrument metrics.
    img, d = frame_canvas(2, "right")
    draw_copy(d, locale, *copy[1], x=86, y=124, max_width=560)
    p = phone_mockup(compass, 640, rotate=0)
    paste_shadowed(img, p, (72, 760))
    draw_ring_metric(d, 965, 910, 128, "地盘" if is_zh else "Earth", "182.5°", locale)
    draw_ring_metric(d, 965, 1230, 128, "纳气" if is_zh else "Naqi", "190.0°", locale)
    d.line((952, 1515, 1118, 1515), fill=GOLD, width=6)
    d.text((865, 1575), "红针 > 灰针" if is_zh else "Red pointer leads", fill=PAPER, font=font(locale, 34, "bold"))
    d.text((865, 1630), "主针突出，读数更直接" if is_zh else "Main direction stays visually dominant", fill=(219, 218, 210), font=font(locale, 25, "regular"))
    out = out_dir / "02.png"
    save_rgb(img, out)
    paths.append(out)

    # 03: grid proof, compact device with enlarged nine-grid graphic.
    img, d = frame_canvas(3, "left")
    draw_copy(d, locale, *copy[2], x=92, y=126, max_width=610)
    p = phone_mockup(overview, 545, rotate=3)
    paste_shadowed(img, p, (615, 660))
    x0, y0, cell = 118, 1120, 170
    nums = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
    cols = [(239, 231, 199), (222, 236, 226), (237, 218, 216)] * 3
    for i, n in enumerate(nums):
        x = x0 + (i % 3) * (cell + 14)
        y = y0 + (i // 3) * (cell + 14)
        d.rounded_rectangle((x, y, x + cell, y + cell), radius=8, fill=cols[i], outline=(204, 196, 178), width=2)
        d.text((x + 74, y + 58), n, fill=INK, font=font(locale, 42, "bold"))
    d.text((118, 1718), "九宫 / 年度 / 阶段" if is_zh else "Grid / Annual / Period", fill=MUTED, font=font(locale, 30, "regular"))
    out = out_dir / "03.png"
    save_rgb(img, out)
    paths.append(out)

    # 04: floor plan overlay, more graphic and less text.
    img, d = frame_canvas(4, "none")
    draw_copy(d, locale, *copy[3], x=90, y=124, max_width=620)
    draw_floorplan_graphic(d, 110, 960, 1.85)
    d.line((430, 1250, 720, 1035), fill=GOLD, width=4)
    d.rounded_rectangle((720, 920, 1150, 1115), radius=28, fill=PAPER, outline=LINE, width=3)
    d.text((762, 960), "立极点" if is_zh else "Center point", fill=GOLD_DARK, font=font(locale, 28, "bold"))
    d.text((762, 1010), "方向与房间关系同步标记" if is_zh else "Direction and room relation marked together", fill=MUTED, font=font(locale, 24, "regular"))
    p = phone_mockup(analysis, 610, rotate=-2)
    paste_shadowed(img, p, (560, 1188))
    out = out_dir / "04.png"
    save_rgb(img, out)
    paths.append(out)

    # 05: grouped spaces, horizontal information architecture.
    img, d = frame_canvas(5, "right")
    draw_copy(d, locale, *copy[4], x=84, y=124, max_width=620)
    labels = ["卧室", "书房", "客厅", "玄关"] if is_zh else ["Bedroom", "Study", "Living", "Entry"]
    colors = [(220, 236, 226), (239, 235, 207), (222, 230, 240), (236, 218, 216)]
    for i, label in enumerate(labels):
        y = 850 + i * 160
        d.rounded_rectangle((88, y, 546, y + 96), radius=26, fill=colors[i], outline=(214, 208, 194), width=2)
        d.text((126, y + 28), label, fill=INK, font=font(locale, 32, "bold"))
        d.line((420, y + 48, 505, y + 48), fill=GOLD if i == 0 else (180, 179, 170), width=4)
    p = phone_mockup(bazhai, 610, rotate=-5)
    paste_shadowed(img, p, (545, 648))
    out = out_dir / "05.png"
    save_rgb(img, out)
    paths.append(out)

    # 06: report/records, darker ending frame for trust and continuity.
    img, d = frame_canvas(6, "bottom")
    draw_copy(d, locale, *copy[5], x=88, y=124, max_width=670)
    p1 = phone_mockup(records, 560, rotate=4)
    p2 = phone_mockup(analysis, 455, rotate=-6, ring=(28, 28, 25))
    paste_shadowed(img, p2, (66, 980))
    paste_shadowed(img, p1, (548, 710))
    d.text((88, 2292), "隐私与控制" if is_zh else "Privacy and control", fill=(221, 192, 130), font=font(locale, 32, "bold"))
    d.text((88, 2352), "记录保存在本地，需要时再生成分享卡。" if is_zh else "Records stay local until you choose to share.", fill=(226, 224, 214), font=font(locale, 28, "regular"))
    out = out_dir / "06.png"
    save_rgb(img, out)
    paths.append(out)

    return paths


def make_contact_sheet(paths: list[Path], out: Path) -> None:
    thumb_w = 360
    thumb_h = int(thumb_w * H / W)
    gap = 22
    sheet = Image.new("RGB", (thumb_w * 3 + gap * 4, thumb_h * 2 + gap * 3), (232, 231, 226))
    for i, p in enumerate(paths):
        im = Image.open(p).convert("RGB").resize((thumb_w, thumb_h), Image.Resampling.LANCZOS)
        x = gap + (i % 3) * (thumb_w + gap)
        y = gap + (i // 3) * (thumb_h + gap)
        sheet.paste(im, (x, y))
    sheet.save(out, "JPEG", quality=92)


def validate(paths: Iterable[Path]) -> list[str]:
    issues: list[str] = []
    for p in paths:
        im = Image.open(p)
        if im.size != (W, H):
            issues.append(f"{p}: size {im.size}")
        if im.mode in ("RGBA", "LA") or ("transparency" in im.info):
            issues.append(f"{p}: alpha present")
    return issues


def main() -> int:
    ensure_dirs()
    zh = make_frames("zh", OUT_ZH)
    en = make_frames("en", OUT_EN)
    make_contact_sheet(zh, CONTACT_DIR / "zh-contactsheet.jpg")
    make_contact_sheet(en, CONTACT_DIR / "en-contactsheet.jpg")
    issues = validate(zh + en)
    if issues:
        print("\n".join(issues))
        return 1
    print(f"Wrote {len(zh)} zh-Hans screenshots to {OUT_ZH}")
    print(f"Wrote {len(en)} en-US screenshots to {OUT_EN}")
    print(f"Contact sheets: {CONTACT_DIR / 'zh-contactsheet.jpg'}")
    print(f"                {CONTACT_DIR / 'en-contactsheet.jpg'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
