#!/usr/bin/env python3
"""Render art-directed App Store screenshots for TAME Space Compass.

This is the campaign renderer: every frame gets its own composition and focal
point. The goal is closer to a vertical product ad than a wrapped screenshot.
"""

from __future__ import annotations

import math
import random
from dataclasses import dataclass
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont, ImageOps


ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "AppStoreAssets"
SHOTS = ROOT / "VerificationShots"
ICON = ROOT / "Design" / "app-icon-original-geomancy-1024.png"

OUT_ZH = ASSETS / "zh-Hans-art-directed-v1"
OUT_EN = ASSETS / "en-US-art-directed-v1"
CONTACT = ASSETS / "generated-marketing" / "art-directed-v1"

W, H = 1284, 2778
PAPER = (253, 251, 246)
PAPER_2 = (238, 235, 225)
INK = (18, 19, 18)
MUTED = (88, 91, 86)
GREEN = (31, 61, 51)
GREEN_DARK = (18, 30, 26)
GOLD = (184, 150, 82)
GOLD_SOFT = (218, 190, 122)
RED = (183, 42, 38)
BLUEGRAY = (214, 226, 235)
MINT = (213, 233, 221)
BLUSH = (232, 207, 200)

FONT_ZH = "/System/Library/Fonts/Hiragino Sans GB.ttc"
FONT_ZH_SERIF = "/System/Library/Fonts/Supplemental/Songti.ttc"
FONT_EN = "/System/Library/Fonts/SFNS.ttf"

FINAL_NAMES = [
    "01-dual-compass.png",
    "02-opening-reference.png",
    "03-flying-star.png",
    "04-floor-plan-heatmap.png",
    "05-bazhai.png",
    "06-record-share.png",
]


@dataclass(frozen=True)
class Frame:
    key: str
    title: tuple[str, str]
    sub: str
    tag: str
    proof: str
    source: Path
    alt: Path | None = None


def font(locale: str, size: int, weight: str = "regular", serif: bool = False) -> ImageFont.FreeTypeFont:
    if locale == "zh" and serif:
        index = 1 if weight in {"bold", "heavy"} else 3
        return ImageFont.truetype(FONT_ZH_SERIF, size, index=index)
    if locale == "zh":
        index = 2 if weight in {"bold", "heavy"} else 0
        return ImageFont.truetype(FONT_ZH, size, index=index)
    return ImageFont.truetype(FONT_EN, size)


def load(path: Path) -> Image.Image:
    return Image.open(path).convert("RGB")


def lerp(a: int, b: int, t: float) -> int:
    return int(a + (b - a) * t)


def gradient(size: tuple[int, int], top: tuple[int, int, int], bottom: tuple[int, int, int]) -> Image.Image:
    w, h = size
    img = Image.new("RGB", size, top)
    px = img.load()
    for y in range(h):
        t = y / max(1, h - 1)
        c = tuple(lerp(top[i], bottom[i], t) for i in range(3))
        for x in range(w):
            px[x, y] = c
    return img.convert("RGBA")


def mask_round(size: tuple[int, int], radius: int) -> Image.Image:
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, size[0] - 1, size[1] - 1), radius=radius, fill=255)
    return mask


def noise(img: Image.Image, seed: int, strength: int = 10) -> None:
    random.seed(seed)
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    for _ in range(7500):
        x = random.randrange(img.width)
        y = random.randrange(img.height)
        alpha = random.randrange(2, strength)
        color = (255, 255, 255, alpha) if random.random() < 0.42 else (0, 0, 0, alpha)
        d.point((x, y), fill=color)
    img.alpha_composite(layer)


def shadow_layer(size: tuple[int, int], shape: str = "round", radius: int = 40, opacity: int = 70, blur: int = 36) -> Image.Image:
    w, h = size
    layer = Image.new("RGBA", (w + blur * 4, h + blur * 4), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    box = (blur * 2, blur * 2, blur * 2 + w, blur * 2 + h)
    if shape == "ellipse":
        d.ellipse(box, fill=(0, 0, 0, opacity))
    else:
        d.rounded_rectangle(box, radius=radius, fill=(0, 0, 0, opacity))
    return layer.filter(ImageFilter.GaussianBlur(blur))


def paste_shadow(base: Image.Image, layer: Image.Image, xy: tuple[int, int], opacity: int = 70, blur: int = 38) -> None:
    x, y = xy
    shadow = shadow_layer(layer.size, radius=48, opacity=opacity, blur=blur)
    base.alpha_composite(shadow, (x - blur * 2 + 18, y - blur * 2 + 28))
    base.alpha_composite(layer, xy)


def stage(seed: int, variant: str) -> Image.Image:
    outer = gradient((W, H), (27, 32, 30), (11, 14, 13))
    px, py, pw, ph = 42, 36, W - 84, H - 150
    if variant == "mist":
        panel = gradient((pw, ph), (253, 251, 246), (226, 230, 221))
    elif variant == "warm":
        panel = gradient((pw, ph), (253, 251, 246), (233, 226, 210))
    else:
        panel = gradient((pw, ph), (249, 250, 244), (218, 227, 218))

    outer.paste(panel, (px, py), mask_round((pw, ph), 62))
    d = ImageDraw.Draw(outer)
    d.rounded_rectangle((px, py, px + pw, py + ph), radius=62, outline=(255, 255, 255, 58), width=2)
    d.rounded_rectangle((px + 3, py + 3, px + pw - 3, py + ph - 3), radius=59, outline=(0, 0, 0, 58), width=1)

    motif = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    md = ImageDraw.Draw(motif)
    ring = (31, 61, 51, 36)
    for idx, r in enumerate((1180, 860, 560, 350)):
        cx = W - 58 + idx * 28
        cy = 825 + idx * 260
        md.ellipse((cx - r // 2, cy - r // 2, cx + r // 2, cy + r // 2), outline=ring, width=2)
    for offset in range(-620, 920, 110):
        md.line((84, 1860 + offset, 1040, 1060 + offset), fill=(31, 61, 51, 15), width=1)
    outer.alpha_composite(motif)

    bottom = Image.new("RGBA", (W, 520), (0, 0, 0, 0))
    bd = ImageDraw.Draw(bottom)
    for y in range(520):
        alpha = int(66 * (y / 519) ** 1.7)
        bd.line((0, y, W, y), fill=(28, 33, 30, alpha))
    outer.alpha_composite(bottom, (0, H - 520))
    noise(outer, seed, 9)
    return outer


def brand(img: Image.Image, locale: str) -> None:
    d = ImageDraw.Draw(img)
    x, y = 92, 72
    if ICON.exists():
        icon = load(ICON).resize((70, 70), Image.Resampling.LANCZOS).convert("RGBA")
        icon = rounded_img(icon, 17)
        img.alpha_composite(icon, (x, y))
    text = "探觅·空间罗盘工具" if locale == "zh" else "TAME Space Compass"
    d.text((x + 92, y + 15), text, font=font(locale, 34 if locale == "zh" else 30, "bold"), fill=GREEN_DARK)


def headline(img: Image.Image, frame: Frame, locale: str, index: int) -> None:
    d = ImageDraw.Draw(img)
    x, y = 96, 190
    d.text((x, y), f"{index + 1:02d}", font=font("en", 23, "bold"), fill=GOLD)
    d.line((x + 52, y + 17, x + 170, y + 17), fill=GOLD, width=2)
    y += 70
    title_font = font(locale, 84 if locale == "zh" else 72, "bold", serif=(locale == "zh"))
    line_h = 96 if locale == "zh" else 82
    for line in frame.title:
        d.text((x, y), line, font=title_font, fill=INK)
        y += line_h
    y += 8
    draw_wrap(d, frame.sub, (x, y), font(locale, 31 if locale == "zh" else 28, "bold"), MUTED, 950, 42)


def draw_wrap(
    d: ImageDraw.ImageDraw,
    text: str,
    xy: tuple[int, int],
    f: ImageFont.FreeTypeFont,
    fill: tuple[int, int, int],
    max_w: int,
    line_h: int,
) -> int:
    x, y = xy
    if any("\u4e00" <= ch <= "\u9fff" for ch in text):
        tokens, sep = list(text), ""
    else:
        tokens, sep = text.split(), " "
    line = ""
    for token in tokens:
        probe = token if not line else line + sep + token
        if d.textbbox((0, 0), probe, font=f)[2] <= max_w:
            line = probe
        else:
            d.text((x, y), line, font=f, fill=fill)
            y += line_h
            line = token
    if line:
        d.text((x, y), line, font=f, fill=fill)
        y += line_h
    return y


def rounded_img(img: Image.Image, radius: int) -> Image.Image:
    out = Image.new("RGBA", img.size, (0, 0, 0, 0))
    out.paste(img, (0, 0), mask_round(img.size, radius))
    return out


def phone_crop(img: Image.Image) -> Image.Image:
    target = 1206 / 2622
    w, h = img.size
    ratio = w / h
    if ratio > target:
        nw = int(h * target)
        left = (w - nw) // 2
        return img.crop((left, 0, left + nw, h))
    if ratio < target:
        nh = int(w / target)
        top = max(0, (h - nh) // 2)
        return img.crop((0, top, w, top + nh))
    return img


def phone(src: Image.Image, width: int, angle: float = 0) -> Image.Image:
    src = phone_crop(src)
    screen_w = width - 48
    screen_h = int(screen_w * 2622 / 1206)
    screen = ImageOps.fit(src, (screen_w, screen_h), Image.Resampling.LANCZOS).convert("RGBA")
    radius = max(58, width // 8)
    body = Image.new("RGBA", (width, screen_h + 50), (0, 0, 0, 0))
    d = ImageDraw.Draw(body)
    d.rounded_rectangle((0, 0, width, screen_h + 50), radius=radius + 22, fill=(18, 18, 17))
    d.rounded_rectangle((14, 12, width - 14, screen_h + 38), radius=radius + 10, fill=(45, 43, 38))
    d.rounded_rectangle((24, 24, width - 24, screen_h + 24), radius=radius, fill=PAPER)
    body.paste(screen, (24, 24), mask_round((screen_w, screen_h), radius - 8))
    d.rounded_rectangle((width // 2 - 86, 38, width // 2 + 86, 76), radius=999, fill=(0, 0, 0))
    shine = Image.new("RGBA", body.size, (0, 0, 0, 0))
    sd = ImageDraw.Draw(shine)
    sd.polygon([(55, 40), (160, 40), (width - 110, screen_h + 20), (width - 255, screen_h + 20)], fill=(255, 255, 255, 27))
    body.alpha_composite(shine)
    if angle:
        body = body.rotate(angle, resample=Image.Resampling.BICUBIC, expand=True)
    return body


def reflect(base: Image.Image, layer: Image.Image, xy: tuple[int, int], height: int = 420, strength: int = 48) -> None:
    x, y = xy
    paste_shadow(base, layer, xy, 62, 34)
    r = ImageOps.flip(layer).crop((0, 0, layer.width, min(height, layer.height)))
    alpha = r.getchannel("A")
    fade = Image.new("L", r.size, 0)
    fd = ImageDraw.Draw(fade)
    for row in range(r.height):
        fd.line((0, row, r.width, row), fill=int(strength * (1 - row / max(1, r.height - 1)) ** 1.7))
    r.putalpha(ImageChops.multiply(alpha, fade))
    base.alpha_composite(r, (x, y + layer.height - 88))


def compass_disc(src: Image.Image, size: int, alpha: int = 255) -> Image.Image:
    src = phone_crop(src)
    w, h = src.size
    crop = src.crop((int(w * 0.03), int(h * 0.20), int(w * 0.97), int(h * 0.70)))
    crop = ImageOps.fit(crop, (size, size), Image.Resampling.LANCZOS).convert("RGBA")
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).ellipse((0, 0, size - 1, size - 1), fill=alpha)
    crop.putalpha(mask)
    return crop


def disc_object(src: Image.Image, size: int, needle: bool = True) -> Image.Image:
    obj = Image.new("RGBA", (size + 160, size + 190), (0, 0, 0, 0))
    d = ImageDraw.Draw(obj)
    cx, cy = 80 + size // 2, 70 + size // 2
    d.ellipse((cx - size // 2 + 24, cy - size // 2 + 38, cx + size // 2 + 24, cy + size // 2 + 38), fill=(0, 0, 0, 72))
    disc = compass_disc(src, size, 248)
    obj.alpha_composite(disc, (80, 70))
    d.ellipse((80, 70, 80 + size, 70 + size), outline=(232, 197, 119, 190), width=5)
    if needle:
        d.line((cx, cy + size * 0.34, cx, cy - size * 0.35), fill=RED, width=max(8, size // 70))
        d.polygon([(cx, cy - size * 0.48), (cx - size * 0.055, cy - size * 0.30), (cx + size * 0.055, cy - size * 0.30)], fill=RED)
        d.ellipse((cx - 34, cy - 34, cx + 34, cy + 34), fill=GREEN_DARK, outline=GOLD_SOFT, width=4)
    return obj


def floor_plate(scale: float = 1.0) -> Image.Image:
    w, h = int(850 * scale), int(560 * scale)
    obj = Image.new("RGBA", (w + 260, h + 260), (0, 0, 0, 0))
    d = ImageDraw.Draw(obj)
    ox, oy = 130, 100
    p1 = (ox + int(80 * scale), oy + int(250 * scale))
    p2 = (ox + int(535 * scale), oy + int(60 * scale))
    p3 = (ox + int(820 * scale), oy + int(220 * scale))
    p4 = (ox + int(340 * scale), oy + int(470 * scale))
    floor = [p1, p2, p3, p4]
    d.polygon([(x + 38, y + 52) for x, y in floor], fill=(0, 0, 0, 72))
    d.polygon(floor, fill=(231, 225, 208), outline=(83, 75, 52, 180))
    for i, color in enumerate([MINT, (236, 226, 190), BLUEGRAY, BLUSH]):
        t1 = i / 4
        t2 = (i + 1) / 4
        a = (int(p1[0] + (p2[0] - p1[0]) * t1), int(p1[1] + (p2[1] - p1[1]) * t1))
        b = (int(p1[0] + (p2[0] - p1[0]) * t2), int(p1[1] + (p2[1] - p1[1]) * t2))
        c = (int(p4[0] + (p3[0] - p4[0]) * t2), int(p4[1] + (p3[1] - p4[1]) * t2))
        e = (int(p4[0] + (p3[0] - p4[0]) * t1), int(p4[1] + (p3[1] - p4[1]) * t1))
        d.polygon([a, b, c, e], fill=color + (210,), outline=(110, 100, 70, 70))
    wall = [p2, p3, (p3[0], p3[1] - int(115 * scale)), (p2[0], p2[1] - int(96 * scale))]
    d.polygon(wall, fill=(238, 235, 224), outline=(160, 143, 95, 110))
    return obj


def metric_card(locale: str) -> Image.Image:
    card = Image.new("RGBA", (565, 168), (0, 0, 0, 0))
    d = ImageDraw.Draw(card)
    d.rounded_rectangle((8, 12, 556, 162), radius=34, fill=(0, 0, 0, 72))
    d.rounded_rectangle((0, 0, 548, 150), radius=34, fill=(31, 34, 30, 244), outline=(220, 188, 111, 150), width=2)
    d.text((226, 18), "185° S", font=font("en", 43, "bold"), fill=GOLD_SOFT)
    items = [("空间方位", "南"), ("地盘读数", "185°"), ("本地记录", "已保存")] if locale == "zh" else [("Facing", "South"), ("Plate", "185°"), ("Record", "Saved")]
    for i, (a, b) in enumerate(items):
        x = 42 + i * 162
        d.text((x, 78), a, font=font(locale, 22, "bold"), fill=(205, 199, 177))
        d.text((x, 112), b, font=font(locale, 25, "bold"), fill=PAPER)
    return card


def grid_tiles() -> Image.Image:
    obj = Image.new("RGBA", (565, 565), (0, 0, 0, 0))
    d = ImageDraw.Draw(obj)
    cell = 162
    colors = [(232, 220, 181), MINT, BLUSH, (235, 226, 190), MINT, BLUSH, (232, 220, 181), MINT, BLUSH]
    for i in range(9):
        x = (i % 3) * (cell + 16)
        y = (i // 3) * (cell + 16)
        d.rounded_rectangle((x + 6, y + 12, x + cell + 6, y + cell + 12), radius=22, fill=(0, 0, 0, 34))
        d.rounded_rectangle((x, y, x + cell, y + cell), radius=22, fill=colors[i], outline=(255, 255, 255, 110), width=2)
        d.text((x + 64, y + 48), str(i + 1), font=font("en", 46, "bold"), fill=INK)
    return obj


def room_chips(locale: str) -> Image.Image:
    labels = ["卧室", "书房", "客厅", "玄关"] if locale == "zh" else ["Bedroom", "Study", "Living", "Entry"]
    colors = [MINT, (237, 229, 191), BLUEGRAY, BLUSH]
    obj = Image.new("RGBA", (460, 520), (0, 0, 0, 0))
    d = ImageDraw.Draw(obj)
    positions = [(28, 18), (72, 142), (20, 270), (86, 395)]
    for i, label in enumerate(labels):
        x, y = positions[i]
        d.rounded_rectangle((x + 8, y + 14, x + 390, y + 104), radius=24, fill=(0, 0, 0, 28))
        d.rounded_rectangle((x, y, x + 382, y + 88), radius=24, fill=colors[i], outline=(255, 255, 255, 120), width=2)
        d.text((x + 32, y + 25), label, font=font(locale, 30, "bold"), fill=INK)
        d.line((x + 250, y + 44, x + 330, y + 44), fill=GOLD, width=4)
    return obj


def proof(img: Image.Image, frame: Frame, locale: str) -> None:
    d = ImageDraw.Draw(img)
    x, y = 96, H - 155
    if ICON.exists():
        icon = rounded_img(load(ICON).resize((70, 70), Image.Resampling.LANCZOS).convert("RGBA"), 18)
        img.alpha_composite(icon, (x, y))
    d.text((x + 92, y + 24), frame.proof, font=font(locale, 24, "bold"), fill=(236, 232, 215))


def synthetic_en(kind: str) -> Image.Image:
    # Use the existing renderer's final upload-style screenshots as product texture
    # only when a real English simulator capture is unavailable.
    mapping = {
        "plan": ASSETS / "en-US/04-floor-plan-heatmap.png",
        "rooms": ASSETS / "en-US/05-bazhai.png",
        "records": ASSETS / "en-US/06-record-share.png",
    }
    return load(mapping[kind])


def source(frame: Frame, locale: str, alt: bool = False) -> Image.Image:
    if locale == "en" and frame.key in {"plan", "rooms", "records"}:
        key = "plan" if alt and frame.key == "records" else frame.key
        return synthetic_en(key)
    return load(frame.alt if alt and frame.alt else frame.source)


def render(frame: Frame, locale: str, index: int, out: Path) -> None:
    variant = ["mist", "sage", "warm", "mist", "sage", "warm"][index]
    img = stage(index + (20 if locale == "en" else 0), variant)
    brand(img, locale)
    headline(img, frame, locale, index)

    main = source(frame, locale)
    alt = source(frame, locale, True)

    if frame.key == "hero":
        plate = floor_plate(0.83)
        img.alpha_composite(plate, (80, 1210))
        disc = disc_object(alt, 650)
        paste_shadow(img, disc, (270, 900), 72, 40)
        card = metric_card(locale)
        paste_shadow(img, card, (360, 1908), 50, 26)
        ImageDraw.Draw(img).text((405, 2358), "开启空间判断之旅" if locale == "zh" else "Start with a clearer spatial read", font=font(locale, 36, "bold"), fill=GOLD)
    elif frame.key == "compass":
        bg_disc = compass_disc(alt, 920, 58)
        img.alpha_composite(bg_disc, (80, 800))
        p = phone(main, 760, -2)
        reflect(img, p, (285, 635), 450, 38)
        paste_shadow(img, metric_card(locale), (210, 1785), 38, 22)
    elif frame.key == "grid":
        tiles = grid_tiles()
        paste_shadow(img, tiles, (120, 870), 42, 28)
        p = phone(main, 585, 3.5)
        reflect(img, p, (620, 730), 410, 34)
    elif frame.key == "plan":
        plate = floor_plate(0.82)
        img.alpha_composite(plate, (40, 1080))
        d = ImageDraw.Draw(img)
        d.line((430, 930, 430, 1468), fill=RED, width=9)
        d.polygon([(430, 860), (384, 970), (476, 970)], fill=RED)
        d.ellipse((396, 1418, 464, 1486), fill=GREEN_DARK, outline=GOLD_SOFT, width=4)
        d.text((178, 1685), "立极点" if locale == "zh" else "CENTER", font=font(locale, 30, "bold"), fill=GOLD)
        p = phone(main, 620, -4)
        reflect(img, p, (560, 835), 390, 30)
    elif frame.key == "rooms":
        chips = room_chips(locale)
        img.alpha_composite(chips, (118, 890))
        p = phone(main, 660, 4.5)
        reflect(img, p, (525, 735), 430, 34)
    else:
        p1 = phone(alt, 460, -7)
        reflect(img, p1, (108, 1050), 350, 30)
        p2 = phone(main, 580, 4.5)
        reflect(img, p2, (625, 760), 430, 34)
        d = ImageDraw.Draw(img)
        d.rounded_rectangle((140, 2200, 660, 2325), radius=32, fill=(255, 255, 255, 225), outline=(218, 190, 120), width=2)
        d.text((180, 2241), "本地保存，按需分享" if locale == "zh" else "Local first. Share when ready.", font=font(locale, 30, "bold"), fill=GOLD)

    proof(img, frame, locale)
    out.parent.mkdir(parents=True, exist_ok=True)
    img.convert("RGB").save(out, "PNG", optimize=True)


def frames(locale: str) -> list[Frame]:
    if locale == "zh":
        return [
            Frame("hero", ("精准测向", "一眼定局"), "双盘罗盘、户型参考与本地记录，专为现场空间判断而生。", "核心价值", "双盘测向 / 户型参考 / 本地报告", SHOTS / "compass_pointer_to_marked_ring.png", SHOTS / "compass_red_pointer_arrow_unified.png"),
            Frame("compass", ("专业罗盘", "稳定定位"), "红针锁定主方向，角度、刻度与参考信息保持同一视线。", "现场测向", "182.5° 地盘读数   190.0° 空间参考", SHOTS / "compass_red_pointer_arrow_unified.png", SHOTS / "compass_pointer_to_marked_ring.png"),
            Frame("grid", ("格局参考", "清晰归位"), "把方位、年度与阶段信息集中查看，复杂关系一屏整理。", "九宫布局", "九宫 / 年度 / 阶段", SHOTS / "overview-nine-palace-2026-05-22.png"),
            Frame("plan", ("空间关系", "直接看图"), "导入户型，标记中心点、开口与功能区，关系更直观。", "户型叠加", "中心点 / 开口 / 功能区", SHOTS / "analysis-yanggong-entry-2026-05-22.png"),
            Frame("rooms", ("卧室书房", "分开判断"), "卧室、书房、客厅、玄关各自成组，复盘更稳定。", "空间分组", "卧室 / 书房 / 客厅 / 玄关", SHOTS / "yanggong-fenjin-clean.png"),
            Frame("records", ("生成报告", "从容分享"), "测向、户型与备注保存在本机，需要沟通时再生成报告。", "本地记录", "本地保存 / 按需分享", SHOTS / "overview-graphical-entry-2026-05-22.png", SHOTS / "analysis-yanggong-entry-2026-05-22.png"),
        ]
    return [
        Frame("hero", ("Precise Direction", "Clear Spatial Reads"), "Dual compass, floor-plan references, and local records for spatial field work.", "Core value", "Dual compass / Plans / Local reports", SHOTS / "compass_pointer_to_marked_ring.png", SHOTS / "compass_red_pointer_arrow_unified.png"),
        Frame("compass", ("Professional", "Compass Positioning"), "A red needle keeps the main direction visible while details stay structured.", "On-site reading", "182.5° Earth plate   190.0° Space reference", SHOTS / "compass_red_pointer_arrow_unified.png", SHOTS / "compass_pointer_to_marked_ring.png"),
        Frame("grid", ("Complex Layouts", "Made Legible"), "Bring direction, annual, and period references into one calm visual system.", "Nine-grid layouts", "Grid / Annual / Period", SHOTS / "en-US/flying-star-demo-2.png"),
        Frame("plan", ("Map Direction", "To Real Rooms"), "Import a plan, place the center point, and align openings with room zones.", "Plan alignment", "Center / Opening / Room zones", ASSETS / "en-US/04-floor-plan-heatmap.png"),
        Frame("rooms", ("Judge Each Space", "Separately"), "Keep bedrooms, studies, living areas, and entries organized for review.", "Room groups", "Bedroom / Study / Living / Entry", ASSETS / "en-US/05-bazhai.png"),
        Frame("records", ("Create Reports", "Share Calmly"), "Compass checks, plans, and notes stay on device until you choose to share.", "Local records", "Local first / Share when needed", ASSETS / "en-US/06-record-share.png", ASSETS / "en-US/04-floor-plan-heatmap.png"),
    ]


def contact_sheet(paths: list[Path], out: Path) -> None:
    thumb_w = 360
    thumb_h = int(thumb_w * H / W)
    gap = 22
    sheet = Image.new("RGB", (thumb_w * 3 + gap * 4, thumb_h * 2 + gap * 3), (231, 229, 221))
    for idx, path in enumerate(paths):
        im = Image.open(path).convert("RGB").resize((thumb_w, thumb_h), Image.Resampling.LANCZOS)
        x = gap + (idx % 3) * (thumb_w + gap)
        y = gap + (idx // 3) * (thumb_h + gap)
        sheet.paste(im, (x, y))
    out.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(out, "JPEG", quality=92)


def validate(paths: list[Path]) -> list[str]:
    issues: list[str] = []
    for path in paths:
        im = Image.open(path)
        if im.size != (W, H):
            issues.append(f"{path}: expected {W}x{H}, got {im.size}")
        if im.mode in {"RGBA", "LA"} or "transparency" in im.info:
            issues.append(f"{path}: alpha present")
    return issues


def main() -> int:
    for directory in (OUT_ZH, OUT_EN, CONTACT):
        directory.mkdir(parents=True, exist_ok=True)

    required = [ICON]
    for locale in ("zh", "en"):
        for frame in frames(locale):
            required.append(frame.source)
            if frame.alt:
                required.append(frame.alt)
    missing = [path for path in required if not path.exists()]
    if missing:
        print("Missing assets:")
        for path in missing:
            print(f"- {path}")
        return 1

    zh_paths: list[Path] = []
    en_paths: list[Path] = []
    for locale, out_dir, bucket in (("zh", OUT_ZH, zh_paths), ("en", OUT_EN, en_paths)):
        for idx, frame in enumerate(frames(locale)):
            out = out_dir / FINAL_NAMES[idx]
            render(frame, locale, idx, out)
            bucket.append(out)

    contact_sheet(zh_paths, CONTACT / "zh-contactsheet.jpg")
    contact_sheet(en_paths, CONTACT / "en-contactsheet.jpg")

    issues = validate(zh_paths + en_paths)
    if issues:
        print("\n".join(issues))
        return 1
    print(f"Wrote {len(zh_paths)} zh-Hans screenshots to {OUT_ZH}")
    print(f"Wrote {len(en_paths)} en-US screenshots to {OUT_EN}")
    print(f"Contact sheets: {CONTACT / 'zh-contactsheet.jpg'}")
    print(f"                {CONTACT / 'en-contactsheet.jpg'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
