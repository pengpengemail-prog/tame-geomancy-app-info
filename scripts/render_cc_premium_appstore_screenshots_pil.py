#!/usr/bin/env python3
"""Render cc-design-inspired App Store screenshots for TAME Space Compass.

This renderer is intentionally deterministic and local. It uses the cc-design
art direction selected for this app, but relies on Pillow for production output
because headless Chrome is too slow for the current 12-image batch.
"""

from __future__ import annotations

import math
import random
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont, ImageOps


ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "AppStoreAssets"
SHOTS = ROOT / "VerificationShots"

OUT_ZH = ASSETS / "zh-Hans-cc-premium-v5"
OUT_EN = ASSETS / "en-US-cc-premium-v5"
CONTACT = ASSETS / "generated-marketing" / "cc-premium-v5"

W, H = 1284, 2778

BG = (248, 246, 238)
PAPER = (253, 251, 246)
INK = (18, 19, 18)
MUTED = (96, 98, 94)
GOLD = (176, 144, 80)
GOLD_SOFT = (213, 185, 111)
GREEN = (31, 61, 51)
GREEN_DARK = (19, 38, 32)
RED = (182, 50, 46)
LINE = (218, 207, 185)

FONT_ZH = "/System/Library/Fonts/Hiragino Sans GB.ttc"
FONT_EN = "/System/Library/Fonts/SFNS.ttf"
FONT_ZH_SERIF = "/System/Library/Fonts/Supplemental/Songti.ttc"

ICON = ROOT / "Design" / "app-icon-original-geomancy-1024.png"

FINAL_NAMES = [
    "01-dual-compass.png",
    "02-opening-reference.png",
    "03-flying-star.png",
    "04-floor-plan-heatmap.png",
    "05-bazhai.png",
    "06-record-share.png",
]


@dataclass(frozen=True)
class Shot:
    kind: str
    eyebrow: str
    title: tuple[str, str]
    sub: str
    proof: str
    source: Path
    alt: Path | None = None
    dark: bool = False
    warm: bool = False


def fnt(locale: str, size: int, weight: str = "regular", serif: bool = False) -> ImageFont.FreeTypeFont:
    if serif:
        index = 1 if weight in {"bold", "heavy"} else 3
        return ImageFont.truetype(FONT_ZH_SERIF, size, index=index)
    if locale == "zh":
        index = 2 if weight in {"bold", "heavy"} else 0
        return ImageFont.truetype(FONT_ZH, size, index=index)
    return ImageFont.truetype(FONT_EN, size)


def load(path: Path) -> Image.Image:
    return Image.open(path).convert("RGB")


def ensure_dirs() -> None:
    for directory in [OUT_ZH, OUT_EN, CONTACT]:
        directory.mkdir(parents=True, exist_ok=True)


def lerp(a: int, b: int, t: float) -> int:
    return int(a + (b - a) * t)


def background(seed: int, *, dark: bool, warm: bool) -> Image.Image:
    random.seed(seed)
    if dark:
        top = GREEN_DARK
        bottom = GREEN
    elif warm:
        top = (253, 251, 246)
        bottom = (235, 225, 207)
    else:
        top = (253, 251, 246)
        bottom = (239, 233, 220)

    img = Image.new("RGB", (W, H), top)
    px = img.load()
    glow_x = int(W * (0.74 if seed % 2 else 0.22))
    glow_y = int(H * (0.20 if dark else 0.15))
    for y in range(H):
        t = y / (H - 1)
        for x in range(W):
            base = tuple(lerp(top[i], bottom[i], t) for i in range(3))
            glow = math.exp(-(((x - glow_x) / 610) ** 2 + ((y - glow_y) / 530) ** 2))
            if dark:
                add = (22 * glow, 20 * glow, 10 * glow)
            else:
                add = (24 * glow, 20 * glow, 10 * glow)
            px[x, y] = tuple(min(255, int(base[i] + add[i])) for i in range(3))

    out = img.convert("RGBA")
    d = ImageDraw.Draw(out)
    ring_color = (240, 229, 198, 38) if dark else (40, 38, 32, 20)
    gold_line = (216, 184, 112, 92) if dark else (176, 144, 80, 54)
    for idx, r in enumerate((1260, 860, 430)):
        if idx == 0:
            cx, cy = W - 42, 740
        elif idx == 1:
            cx, cy = -120, H - 690
        else:
            cx, cy = W - 300, H - 560
        d.ellipse((cx - r // 2, cy - r // 2, cx + r // 2, cy + r // 2), outline=gold_line if idx == 0 else ring_color, width=2)

    axis = (242, 232, 203, 42) if dark else (25, 25, 22, 18)
    d.line((96, 1340, W - 96, 1340), fill=axis, width=1)
    d.line((W // 2, 176, W // 2, H - 220), fill=axis, width=1)

    if ICON.exists():
        icon = load(ICON).resize((980, 980), Image.Resampling.LANCZOS).convert("RGBA")
        if dark:
            icon = ImageOps.invert(icon.convert("RGB")).convert("RGBA")
            icon.putalpha(24)
        else:
            icon = ImageOps.grayscale(icon).convert("RGBA")
            icon.putalpha(18)
        out.alpha_composite(icon, (W - 700, -250))

    grain = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    gd = ImageDraw.Draw(grain)
    for _ in range(9000):
        x = random.randrange(W)
        y = random.randrange(H)
        a = random.randrange(5, 13)
        color = (255, 255, 255, a) if dark and random.random() < 0.45 else (18, 16, 12, a)
        gd.point((x, y), fill=color)
    out.alpha_composite(grain)
    return out


def wrap_text(draw: ImageDraw.ImageDraw, text: str, font: ImageFont.FreeTypeFont, width: int) -> list[str]:
    if any("\u4e00" <= ch <= "\u9fff" for ch in text):
        tokens = list(text)
        sep = ""
    else:
        tokens = text.split()
        sep = " "

    lines: list[str] = []
    current = ""
    for token in tokens:
        probe = token if not current else current + sep + token
        if draw.textbbox((0, 0), probe, font=font)[2] <= width:
            current = probe
        else:
            if current:
                lines.append(current)
            current = token
    if current:
        lines.append(current)
    return lines


def draw_wrapped(
    draw: ImageDraw.ImageDraw,
    text: str,
    xy: tuple[int, int],
    font: ImageFont.FreeTypeFont,
    fill: tuple[int, int, int],
    width: int,
    line_h: int,
) -> int:
    x, y = xy
    for line in wrap_text(draw, text, font, width):
        draw.text((x, y), line, font=font, fill=fill)
        y += line_h
    return y


def draw_copy(img: Image.Image, shot: Shot, locale: str, number: str) -> None:
    d = ImageDraw.Draw(img)
    title_color = PAPER if shot.dark else INK
    sub_color = (237, 230, 207) if shot.dark else MUTED
    accent = GOLD_SOFT if shot.dark else GOLD
    x, y = 120, 112
    d.text((x, y), number, font=fnt(locale, 27, "bold"), fill=accent)
    d.line((x + 62, y + 19, x + 186, y + 19), fill=accent, width=2)
    y += 74
    d.text((x, y), shot.eyebrow, font=fnt(locale, 25 if locale == "zh" else 23, "bold"), fill=accent)
    y += 82
    title_size = 94 if locale == "zh" else 78
    if shot.kind == "hero":
        title_size = 100 if locale == "zh" else 84
    title_font = fnt(locale, title_size, "heavy")
    line_h = int(title_size * 1.02)
    for line in shot.title:
        d.text((x, y), line, font=title_font, fill=title_color)
        y += line_h
    y += 30
    sub_font = fnt(locale, 32 if locale == "zh" else 30, "regular")
    draw_wrapped(d, shot.sub, (x, y), sub_font, sub_color, 770, int(sub_font.size * 1.38))


def rounded_mask(size: tuple[int, int], radius: int) -> Image.Image:
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, size[0] - 1, size[1] - 1), radius=radius, fill=255)
    return mask


def crop_to_phone_ratio(img: Image.Image) -> Image.Image:
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


def phone_mockup(src: Image.Image, width: int, rotate: float = 0) -> Image.Image:
    src = crop_to_phone_ratio(src)
    screen_w = width - 44
    screen_h = int(screen_w * 2622 / 1206)
    screen = ImageOps.fit(src, (screen_w, screen_h), Image.Resampling.LANCZOS)
    radius = max(54, width // 9)
    phone = Image.new("RGBA", (width, screen_h + 44), (0, 0, 0, 0))

    shadow = Image.new("RGBA", (width + 220, screen_h + 264), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle((110, 92, 110 + width, 92 + screen_h + 44), radius=radius + 24, fill=(28, 23, 13, 72))
    shadow = shadow.filter(ImageFilter.GaussianBlur(44))

    d = ImageDraw.Draw(phone)
    d.rounded_rectangle((0, 0, width, screen_h + 44), radius=radius + 20, fill=(18, 18, 17))
    d.rounded_rectangle((22, 22, width - 22, screen_h + 22), radius=radius, fill=PAPER)
    mask = rounded_mask((screen_w, screen_h), radius - 8)
    phone.paste(screen.convert("RGBA"), (22, 22), mask)
    d.rounded_rectangle((30, 30, width - 30, screen_h + 14), radius=radius - 18, outline=(255, 255, 255, 92), width=3)
    d.rounded_rectangle((width // 2 - 90, 34, width // 2 + 90, 72), radius=999, fill=(3, 3, 3))
    glass = Image.new("RGBA", phone.size, (0, 0, 0, 0))
    gd = ImageDraw.Draw(glass)
    gd.polygon(
        [(48, 36), (160, 36), (width - 72, screen_h + 18), (width - 225, screen_h + 18)],
        fill=(255, 255, 255, 34),
    )
    phone.alpha_composite(glass)

    combined = Image.new("RGBA", shadow.size, (0, 0, 0, 0))
    combined.alpha_composite(shadow)
    combined.alpha_composite(phone, (110, 82))
    if rotate:
        combined = combined.rotate(rotate, resample=Image.Resampling.BICUBIC, expand=True)
    return combined


def paste(base: Image.Image, layer: Image.Image, xy: tuple[int, int]) -> None:
    base.alpha_composite(layer, xy)


def compass_disc(src: Image.Image, size: int, alpha: int) -> Image.Image:
    src = crop_to_phone_ratio(src)
    w, h = src.size
    crop = src.crop((int(w * 0.04), int(h * 0.22), int(w * 0.96), int(h * 0.74)))
    crop = ImageOps.fit(crop, (size, size), Image.Resampling.LANCZOS).convert("RGBA")
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).ellipse((0, 0, size - 1, size - 1), fill=alpha)
    crop.putalpha(mask)
    return crop


def draw_metric(img: Image.Image, xy: tuple[int, int], value: str, label: str, locale: str) -> None:
    x, y = xy
    card = Image.new("RGBA", (300, 150), (0, 0, 0, 0))
    cd = ImageDraw.Draw(card)
    cd.rounded_rectangle((0, 0, 299, 149), radius=28, fill=(255, 255, 255, 198), outline=(176, 151, 95, 108), width=1)
    cd.text((32, 30), value, font=fnt(locale, 38, "bold"), fill=INK)
    cd.text((32, 88), label, font=fnt(locale, 22, "bold"), fill=(112, 114, 108))
    shadow = Image.new("RGBA", (380, 230), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle((40, 30, 339, 179), radius=28, fill=(39, 33, 20, 36))
    shadow = shadow.filter(ImageFilter.GaussianBlur(26))
    img.alpha_composite(shadow, (x - 40, y - 20))
    img.alpha_composite(card, xy)


def draw_grid(img: Image.Image, xy: tuple[int, int], cell: int = 162) -> None:
    d = ImageDraw.Draw(img)
    x0, y0 = xy
    colors = [(239, 230, 199), (220, 235, 226), (234, 215, 212)] * 3
    for i in range(9):
        x = x0 + (i % 3) * (cell + 13)
        y = y0 + (i // 3) * (cell + 13)
        d.rounded_rectangle((x, y, x + cell, y + cell), radius=8, fill=colors[i], outline=(180, 162, 111), width=1)
        text = str(i + 1)
        box = d.textbbox((0, 0), text, font=fnt("en", 42, "bold"))
        d.text((x + (cell - box[2]) / 2, y + 54), text, font=fnt("en", 42, "bold"), fill=INK)


def draw_plan(img: Image.Image, xy: tuple[int, int], size: int = 520) -> None:
    d = ImageDraw.Draw(img)
    x, y = xy
    colors = [(220, 235, 226), (240, 231, 198), (223, 233, 242), (234, 214, 212)]
    for i, color in enumerate(colors):
        cx = x + (i % 2) * (size // 2)
        cy = y + (i // 2) * (size // 2)
        d.rectangle((cx, cy, cx + size // 2, cy + size // 2), fill=color, outline=(74, 66, 48), width=1)
    d.rectangle((x, y, x + size, y + size), outline=(74, 66, 48), width=2)


def draw_needle(img: Image.Image, x: int, y: int, height: int = 440) -> None:
    d = ImageDraw.Draw(img)
    d.rectangle((x - 4, y, x + 4, y + height), fill=RED)
    d.polygon([(x, y - 56), (x - 34, y + 20), (x + 34, y + 20)], fill=RED)
    d.ellipse((x - 27, y + height - 60, x + 27, y + height - 6), fill=INK)


def draw_note(img: Image.Image, xy: tuple[int, int], title: str, body: str, locale: str, width: int = 470) -> None:
    x, y = xy
    card = Image.new("RGBA", (width, 170), (0, 0, 0, 0))
    cd = ImageDraw.Draw(card)
    cd.rounded_rectangle((0, 0, width - 1, 169), radius=30, fill=(255, 255, 255, 205), outline=(176, 151, 95, 108), width=1)
    cd.text((34, 30), title, font=fnt(locale, 31, "bold"), fill=GOLD)
    draw_wrapped(cd, body, (34, 78), fnt(locale, 24, "bold"), (103, 105, 99), width - 68, 32)
    shadow = Image.new("RGBA", (width + 90, 250), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle((45, 28, 45 + width, 198), radius=30, fill=(39, 33, 20, 32))
    shadow = shadow.filter(ImageFilter.GaussianBlur(28))
    img.alpha_composite(shadow, (x - 45, y - 24))
    img.alpha_composite(card, xy)


def draw_room_list(img: Image.Image, locale: str) -> None:
    labels = ["卧室", "书房", "客厅", "玄关"] if locale == "zh" else ["Bedroom", "Study", "Living", "Entry"]
    colors = [(220, 238, 228), (239, 233, 201), (223, 233, 243), (234, 215, 212)]
    d = ImageDraw.Draw(img)
    for i, label in enumerate(labels):
        x, y = 120, 940 + i * 126
        d.rounded_rectangle((x, y, x + 360, y + 86), radius=22, fill=colors[i], outline=(176, 151, 95), width=1)
        d.text((x + 32, y + 24), label, font=fnt(locale, 30, "bold"), fill=INK)
        d.line((x + 242, y + 43, x + 320, y + 43), fill=GOLD, width=4)


def draw_proof(img: Image.Image, shot: Shot, locale: str) -> None:
    d = ImageDraw.Draw(img)
    color = (239, 231, 210) if shot.dark else (95, 97, 92)
    x, y = 120, H - 160
    if ICON.exists():
        icon = load(ICON).resize((76, 76), Image.Resampling.LANCZOS)
        icon = rounded_image(icon, 22)
        shadow = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
        sd = ImageDraw.Draw(shadow)
        sd.rounded_rectangle((26, 18, 102, 94), radius=22, fill=(28, 22, 12, 46))
        shadow = shadow.filter(ImageFilter.GaussianBlur(16))
        img.alpha_composite(shadow, (x - 26, y - 18))
        img.alpha_composite(icon, (x, y))
    d.text((x + 100, y + 22), shot.proof, font=fnt(locale, 25, "bold"), fill=color)


def rounded_image(img: Image.Image, radius: int) -> Image.Image:
    img = img.convert("RGBA")
    mask = rounded_mask(img.size, radius)
    out = Image.new("RGBA", img.size, (0, 0, 0, 0))
    out.paste(img, (0, 0), mask)
    return out


def draw_app_status(draw: ImageDraw.ImageDraw, width: int, locale: str) -> None:
    draw.text((78, 62), "09:41", font=fnt(locale, 44, "bold"), fill=INK)
    draw.rounded_rectangle((width // 2 - 112, 48, width // 2 + 112, 98), radius=999, fill=(4, 4, 4))
    draw.rounded_rectangle((width - 170, 64, width - 84, 100), radius=14, outline=INK, width=4)
    draw.rounded_rectangle((width - 158, 74, width - 104, 90), radius=8, fill=INK)
    draw.rectangle((width - 80, 76, width - 72, 88), fill=INK)


def draw_app_card(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], radius: int = 38) -> None:
    draw.rounded_rectangle(box, radius=radius, fill=PAPER, outline=(224, 210, 176), width=2)


def draw_app_pill(draw: ImageDraw.ImageDraw, xy: tuple[int, int], text: str, locale: str, width: int = 280) -> None:
    x, y = xy
    draw.rounded_rectangle((x, y, x + width, y + 72), radius=999, fill=(255, 255, 255), outline=(218, 198, 152), width=2)
    text_box = draw.textbbox((0, 0), text, font=fnt(locale, 30, "bold"))
    draw.text((x + (width - text_box[2]) / 2, y + 19), text, font=fnt(locale, 30, "bold"), fill=INK)


def draw_app_metric(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], number: str, label: str, value: str, locale: str) -> None:
    x1, y1, x2, y2 = box
    draw.rounded_rectangle(box, radius=28, fill=(255, 254, 250), outline=(224, 210, 176), width=2)
    draw.text((x1 + 32, y1 + 22), number, font=fnt(locale, 25, "bold"), fill=GOLD)
    draw.text((x1 + 32, y1 + 64), label, font=fnt(locale, 26, "bold"), fill=MUTED)
    draw.text((x1 + 32, y1 + 104), value, font=fnt(locale, 33, "bold"), fill=INK)


def draw_app_bottom_nav(draw: ImageDraw.ImageDraw, width: int, height: int, locale: str, active: int = 1) -> None:
    labels = ["Overview", "Compass", "Analysis", "Records", "Settings"]
    x0 = 72
    y = height - 178
    step = (width - 144) / 5
    for idx, label in enumerate(labels):
        cx = int(x0 + step * idx + step / 2)
        color = GOLD if idx == active else (84, 84, 82)
        if idx == 0:
            draw.rounded_rectangle((cx - 20, y, cx + 20, y + 40), radius=9, outline=color, width=4)
        elif idx == 1:
            draw.ellipse((cx - 22, y - 1, cx + 22, y + 43), outline=color, width=4)
            draw.polygon([(cx + 11, y + 9), (cx - 5, y + 23), (cx - 2, y + 28), (cx + 16, y + 13)], fill=color)
        elif idx == 2:
            draw.line((cx - 24, y + 40, cx - 24, y + 12), fill=color, width=5)
            draw.line((cx, y + 40, cx, y + 4), fill=color, width=5)
            draw.line((cx + 24, y + 40, cx + 24, y + 20), fill=color, width=5)
        elif idx == 3:
            draw.line((cx - 24, y + 12, cx - 4, y + 12, cx + 2, y + 22, cx + 24, y + 22), fill=color, width=4)
            draw.rounded_rectangle((cx - 24, y + 20, cx + 26, y + 44), radius=6, outline=color, width=4)
        else:
            draw.ellipse((cx - 20, y, cx + 20, y + 40), outline=color, width=4)
            draw.ellipse((cx - 6, y + 14, cx + 6, y + 26), fill=color)
        label_box = draw.textbbox((0, 0), label, font=fnt(locale, 19, "bold"))
        draw.text((cx - label_box[2] / 2, y + 55), label, font=fnt(locale, 19, "bold"), fill=color)


def synthetic_en_screen(kind: str) -> Image.Image:
    width, height = 1206, 2622
    img = Image.new("RGB", (width, height), (252, 250, 245))
    d = ImageDraw.Draw(img)
    draw_app_status(d, width, "en")
    d.text((80, 160), "TAME", font=fnt("en", 30, "bold"), fill=INK)
    d.text((80, 205), "Space Compass", font=fnt("en", 24, "regular"), fill=MUTED)

    if kind == "plan":
        d.text((80, 310), "Floor Plan Analysis", font=fnt("en", 57, "bold"), fill=INK)
        draw_app_pill(d, (826, 306), "Grid +", "en", 286)
        y = 438
        metrics = [
            ("00.1", "Import Status", "Reference Layout"),
            ("00.2", "Center Point", "Placed"),
            ("00.3", "Facing", "South"),
            ("00.4", "Room Markers", "9"),
        ]
        for idx, (number, label, value) in enumerate(metrics):
            x = 80 + (idx % 2) * 520
            yy = y + (idx // 2) * 150
            draw_app_metric(d, (x, yy, x + 470, yy + 124), number, label, value, "en")
        d.text((80, 820), "9-Palace Overlay", font=fnt("en", 42, "bold"), fill=INK)
        draw_plan(img, (80, 900), 820)
        room_labels = [
            ("Door", 185, 1000, RED),
            ("Bath", 460, 1018, (170, 166, 154)),
            ("Kitchen", 780, 1016, RED),
            ("Study", 195, 1282, GREEN),
            ("Bed", 228, 1542, GREEN),
            ("Living", 560, 1530, GOLD),
            ("Balcony", 520, 1810, GREEN),
        ]
        for label, x, yy, color in room_labels:
            d.rounded_rectangle((x, yy, x + 150, yy + 56), radius=999, fill=PAPER, outline=color, width=4)
            tb = d.textbbox((0, 0), label, font=fnt("en", 24, "bold"))
            d.text((x + (150 - tb[2]) / 2, yy + 14), label, font=fnt("en", 24, "bold"), fill=color)
        d.ellipse((560, 1264, 646, 1350), fill=INK)
        d.text((588, 1285), "C", font=fnt("en", 30, "bold"), fill=PAPER)
        d.text((80, 1944), "Room Review", font=fnt("en", 42, "bold"), fill=INK)
        draw_app_metric(d, (80, 2018, 550, 2142), "01.1", "Stable Areas", "Living / Study", "en")
        draw_app_metric(d, (600, 2018, 1070, 2142), "01.2", "Needs Care", "Kitchen / Bath", "en")
        draw_wrapped(
            d,
            "Keep the center point, room markers, and direction-based notes together for on-site review.",
            (80, 2225),
            fnt("en", 35, "regular"),
            MUTED,
            980,
            48,
        )
        draw_app_pill(d, (275, 2370), "Save to local records", "en", 656)
        draw_app_bottom_nav(d, width, height, "en", 2)
    elif kind == "rooms":
        d.text((80, 310), "Eight-Sector Notes", font=fnt("en", 57, "bold"), fill=INK)
        draw_app_pill(d, (764, 306), "House + Profile", "en", 348)
        y = 438
        metrics = [
            ("00.1", "House Profile", "Li"),
            ("00.2", "Occupant Profile", "Xun"),
            ("00.3", "Group", "East Group"),
            ("00.4", "Match", "Aligned"),
        ]
        for idx, (number, label, value) in enumerate(metrics):
            x = 80 + (idx % 2) * 520
            yy = y + (idx // 2) * 150
            draw_app_metric(d, (x, yy, x + 470, yy + 124), number, label, value, "en")
        d.text((80, 820), "Room Suggestions", font=fnt("en", 42, "bold"), fill=INK)
        draw_plan(img, (80, 900), 820)
        labels = [
            ("SE", "Study", 100, 935, GREEN),
            ("S", "Living", 380, 935, GOLD),
            ("SW", "Bath", 690, 935, (170, 166, 154)),
            ("E", "Bedroom", 100, 1208, GREEN),
            ("C", "Balance", 390, 1208, GOLD_SOFT),
            ("W", "Storage", 700, 1208, (185, 181, 166)),
            ("NE", "Desk", 100, 1480, GOLD),
            ("N", "Quiet", 390, 1480, GREEN),
            ("NW", "Kitchen", 700, 1480, RED),
        ]
        for direction, room, x, yy, color in labels:
            d.text((x, yy), direction, font=fnt("en", 25, "bold"), fill=MUTED)
            d.text((x, yy + 60), room, font=fnt("en", 32, "bold"), fill=color)
        d.text((80, 1944), "Practical Reference", font=fnt("en", 42, "bold"), fill=INK)
        draw_app_card(d, (80, 2020, 1126, 2320), 36)
        draw_wrapped(
            d,
            "Separate bedroom, study, living, and entry notes so each space keeps its own context.",
            (136, 2090),
            fnt("en", 36, "bold"),
            INK,
            900,
            50,
        )
        draw_app_pill(d, (275, 2205), "Save eight-sector record", "en", 656)
        draw_app_bottom_nav(d, width, height, "en", 2)
    else:
        d.text((80, 310), "Save Records", font=fnt("en", 57, "bold"), fill=INK)
        d.text((80, 378), "Share Report Cards", font=fnt("en", 57, "bold"), fill=INK)
        y = 540
        for idx, title in enumerate(["Compass Reading", "Floor Plan Notes", "Room Review"]):
            draw_app_card(d, (80, y + idx * 300, 1126, y + idx * 300 + 238), 36)
            d.text((128, y + idx * 300 + 44), f"0{idx + 1}", font=fnt("en", 25, "bold"), fill=GOLD)
            d.text((128, y + idx * 300 + 92), title, font=fnt("en", 40, "bold"), fill=INK)
            draw_wrapped(
                d,
                "Saved locally. Ready when you choose to create a share card.",
                (128, y + idx * 300 + 150),
                fnt("en", 29, "regular"),
                MUTED,
                760,
                40,
            )
            draw_app_pill(d, (846, y + idx * 300 + 78), "Review", "en", 200)
        d.text((80, 1510), "Report Preview", font=fnt("en", 42, "bold"), fill=INK)
        draw_app_card(d, (80, 1590, 1126, 2200), 36)
        d.rounded_rectangle((150, 1670, 1056, 1762), radius=22, fill=(245, 241, 232), outline=(224, 210, 176), width=2)
        d.text((180, 1692), "TAME Space Compass", font=fnt("en", 30, "bold"), fill=INK)
        d.text((180, 1788), "Key readings", font=fnt("en", 34, "bold"), fill=INK)
        d.text((180, 1850), "182.5° Earth plate", font=fnt("en", 30, "regular"), fill=MUTED)
        d.text((180, 1902), "190.0° Space reference", font=fnt("en", 30, "regular"), fill=MUTED)
        draw_plan(img, (700, 1800), 280)
        draw_app_pill(d, (275, 2242), "Create share card", "en", 656)
        draw_app_bottom_nav(d, width, height, "en", 3)

    return img


def source_image(shot: Shot, locale: str, *, alt: bool = False) -> Image.Image:
    if locale == "en":
        target_kind = "plan" if alt and shot.kind == "records" else shot.kind
        if target_kind in {"plan", "rooms", "records"}:
            return synthetic_en_screen(target_kind)
    return load(shot.alt if alt and shot.alt else shot.source)


def vertical_gradient(size: tuple[int, int], top: tuple[int, int, int], bottom: tuple[int, int, int]) -> Image.Image:
    w, h = size
    img = Image.new("RGB", size, top)
    px = img.load()
    for y in range(h):
        t = y / max(1, h - 1)
        color = tuple(lerp(top[i], bottom[i], t) for i in range(3))
        for x in range(w):
            px[x, y] = color
    return img.convert("RGBA")


def draw_luxury_frame(style: str, seed: int) -> Image.Image:
    random.seed(seed)
    base = vertical_gradient((W, H), (31, 36, 34), (15, 19, 18))
    d = ImageDraw.Draw(base)
    px, py, pw, ph = 42, 36, W - 84, H - 150
    if style == "light":
        panel = vertical_gradient((pw, ph), (253, 251, 246), (229, 226, 215))
        line = (31, 61, 51, 34)
    else:
        panel = vertical_gradient((pw, ph), (248, 246, 238), (213, 219, 209))
        line = (31, 61, 51, 46)

    mask = rounded_mask((pw, ph), 58)
    base.paste(panel, (px, py), mask)
    d.rounded_rectangle((px, py, px + pw, py + ph), radius=58, outline=(255, 255, 255, 36), width=2)
    d.rounded_rectangle((px + 2, py + 2, px + pw - 2, py + ph - 2), radius=56, outline=(0, 0, 0, 52), width=1)

    motif = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    md = ImageDraw.Draw(motif)
    for i, r in enumerate((1200, 900, 650, 420)):
        cx = W - 120 + i * 35
        cy = 870 + i * 180
        md.ellipse((cx - r // 2, cy - r // 2, cx + r // 2, cy + r // 2), outline=line, width=2)
    for offset in range(-420, 780, 120):
        md.line((90, 1780 + offset, 1030, 980 + offset), fill=line, width=1)
    base.alpha_composite(motif)

    fade = Image.new("RGBA", (W, 650), (0, 0, 0, 0))
    fd = ImageDraw.Draw(fade)
    for y in range(650):
        a = int(58 * (y / 649) ** 1.8)
        fd.line((0, y, W, y), fill=(28, 33, 30, a))
    base.alpha_composite(fade, (0, H - 650))
    return base


def draw_brand_lockup(img: Image.Image, locale: str, style: str) -> None:
    d = ImageDraw.Draw(img)
    x, y = 94, 74
    if ICON.exists():
        icon = rounded_image(load(ICON).resize((72, 72), Image.Resampling.LANCZOS), 18)
        img.alpha_composite(icon, (x, y))
    color = INK if style == "light" else GREEN_DARK
    label = "探觅·空间罗盘工具" if locale == "zh" else "TAME Space Compass"
    d.text((x + 92, y + 14), label, font=fnt(locale, 34 if locale == "zh" else 31, "bold"), fill=color)


def draw_luxury_copy(img: Image.Image, shot: Shot, locale: str, index: int, style: str) -> None:
    d = ImageDraw.Draw(img)
    title_color = INK if style == "light" else GREEN_DARK
    sub_color = (54, 52, 46) if style == "light" else (54, 63, 56)
    accent = GOLD if style == "light" else GOLD
    x, y = 96, 184
    d.text((x, y), f"{index + 1:02d}", font=fnt("en", 24, "bold"), fill=accent)
    d.line((x + 54, y + 17, x + 168, y + 17), fill=accent, width=2)
    y += 74
    title_size = 83 if locale == "zh" else 78
    if shot.kind == "hero":
        title_size = 88 if locale == "zh" else 82
    title_font = fnt(locale, title_size, "heavy", serif=(locale == "zh"))
    for line in shot.title:
        d.text((x, y), line, font=title_font, fill=title_color)
        y += int(title_size * 1.08)
    y += 14
    draw_wrapped(d, shot.sub, (x, y), fnt(locale, 34 if locale == "zh" else 31, "bold"), sub_color, 980, 46)


def add_reflection(base: Image.Image, layer: Image.Image, xy: tuple[int, int], height: int = 520) -> None:
    x, y = xy
    base.alpha_composite(layer, xy)
    reflection = ImageOps.flip(layer)
    reflection = reflection.crop((0, 0, reflection.width, min(height, reflection.height)))
    alpha = reflection.getchannel("A")
    fade = Image.new("L", reflection.size, 0)
    fd = ImageDraw.Draw(fade)
    for row in range(reflection.height):
        a = int(86 * (1 - row / max(1, reflection.height - 1)) ** 1.8)
        fd.line((0, row, reflection.width, row), fill=a)
    reflection.putalpha(multiply_alpha(alpha, fade))
    base.alpha_composite(reflection, (x, y + layer.height - 96))


def multiply_alpha(a: Image.Image, b: Image.Image) -> Image.Image:
    return ImageChops.multiply(a, b)


def draw_isometric_room(base: Image.Image, xy: tuple[int, int], scale: float = 1.0) -> Image.Image:
    w, h = int(780 * scale), int(520 * scale)
    room = Image.new("RGBA", (w + 240, h + 260), (0, 0, 0, 0))
    d = ImageDraw.Draw(room)
    ox, oy = 120, 105
    floor = [
        (ox + int(90 * scale), oy + int(230 * scale)),
        (ox + int(520 * scale), oy + int(70 * scale)),
        (ox + int(760 * scale), oy + int(205 * scale)),
        (ox + int(315 * scale), oy + int(405 * scale)),
    ]
    d.polygon([(x + 28, y + 50) for x, y in floor], fill=(0, 0, 0, 86))
    d.polygon(floor, fill=(230, 224, 207), outline=(255, 255, 255, 140))
    d.line((floor[0], floor[1], floor[2], floor[3], floor[0]), fill=(82, 74, 51, 210), width=max(2, int(3 * scale)))
    wall_left = [floor[0], floor[3], (floor[3][0], floor[3][1] - int(112 * scale)), (floor[0][0], floor[0][1] - int(100 * scale))]
    wall_back = [floor[1], floor[2], (floor[2][0], floor[2][1] - int(110 * scale)), (floor[1][0], floor[1][1] - int(92 * scale))]
    d.polygon(wall_left, fill=(240, 237, 224), outline=(163, 145, 94, 150))
    d.polygon(wall_back, fill=(232, 229, 215), outline=(163, 145, 94, 150))
    for i in range(1, 4):
        t = i / 4
        x1 = int(floor[0][0] + (floor[1][0] - floor[0][0]) * t)
        y1 = int(floor[0][1] + (floor[1][1] - floor[0][1]) * t)
        x2 = int(floor[3][0] + (floor[2][0] - floor[3][0]) * t)
        y2 = int(floor[3][1] + (floor[2][1] - floor[3][1]) * t)
        d.line((x1, y1, x2, y2), fill=(140, 130, 100, 70), width=1)
    for i in range(1, 3):
        t = i / 3
        x1 = int(floor[0][0] + (floor[3][0] - floor[0][0]) * t)
        y1 = int(floor[0][1] + (floor[3][1] - floor[0][1]) * t)
        x2 = int(floor[1][0] + (floor[2][0] - floor[1][0]) * t)
        y2 = int(floor[1][1] + (floor[2][1] - floor[1][1]) * t)
        d.line((x1, y1, x2, y2), fill=(140, 130, 100, 70), width=1)
    d.rounded_rectangle((ox + int(210 * scale), oy + int(230 * scale), ox + int(390 * scale), oy + int(300 * scale)), radius=10, fill=(245, 241, 230), outline=(143, 127, 78))
    d.rounded_rectangle((ox + int(535 * scale), oy + int(185 * scale), ox + int(670 * scale), oy + int(250 * scale)), radius=10, fill=(245, 241, 230), outline=(143, 127, 78))
    return room


def draw_measure_card(base: Image.Image, xy: tuple[int, int], locale: str) -> None:
    x, y = xy
    d = ImageDraw.Draw(base)
    d.rounded_rectangle((x + 10, y + 16, x + 560, y + 178), radius=30, fill=(0, 0, 0, 84))
    d.rounded_rectangle((x, y, x + 550, y + 162), radius=30, fill=(36, 39, 34, 232), outline=(219, 188, 111, 130), width=2)
    title = "185° S" if locale == "zh" else "185° S"
    d.text((x + 210, y + 22), title, font=fnt("en", 44, "bold"), fill=(235, 210, 145))
    items = [("空间方位", "南"), ("地盘读数", "185°"), ("本地记录", "已保存")] if locale == "zh" else [("Facing", "South"), ("Plate", "185°"), ("Record", "Saved")]
    for i, (label, value) in enumerate(items):
        xx = x + 44 + i * 162
        d.text((xx, y + 82), label, font=fnt(locale, 22, "bold"), fill=(208, 201, 177))
        d.text((xx, y + 116), value, font=fnt(locale, 25, "bold"), fill=PAPER)


def draw_grid_overlay(base: Image.Image, xy: tuple[int, int], locale: str, dark: bool) -> None:
    x, y = xy
    cell = 160
    d = ImageDraw.Draw(base)
    colors = [(226, 215, 177), (205, 226, 212), (225, 199, 191)] * 3
    for i in range(9):
        xx = x + (i % 3) * (cell + 12)
        yy = y + (i // 3) * (cell + 12)
        d.rounded_rectangle((xx, yy, xx + cell, yy + cell), radius=20, fill=colors[i], outline=(255, 255, 255, 85), width=2)
        d.text((xx + 64, yy + 50), str(i + 1), font=fnt("en", 46, "bold"), fill=INK)


def render_shot(shot: Shot, locale: str, index: int, out: Path) -> None:
    style = "light" if index in {0, 2} else "dark"
    img = draw_luxury_frame(style, index + (10 if locale == "en" else 0))
    draw_brand_lockup(img, locale, style)
    draw_luxury_copy(img, shot, locale, index, style)
    source = source_image(shot, locale)
    alt = source_image(shot, locale, alt=True)

    if shot.kind == "hero":
        group = Image.new("RGBA", (1050, 1020), (0, 0, 0, 0))
        room = draw_isometric_room(group, (0, 0), 0.95)
        group.alpha_composite(room, (30, 245))
        disc = compass_disc(alt, 560, 242)
        disc_shadow = Image.new("RGBA", (700, 700), (0, 0, 0, 0))
        sd = ImageDraw.Draw(disc_shadow)
        sd.ellipse((80, 105, 640, 665), fill=(0, 0, 0, 92))
        disc_shadow = disc_shadow.filter(ImageFilter.GaussianBlur(24))
        group.alpha_composite(disc_shadow, (210, 150))
        group.alpha_composite(disc, (280, 220))
        gd = ImageDraw.Draw(group)
        gd.ellipse((280, 220, 840, 780), outline=(229, 196, 122, 180), width=4)
        gd.line((560, 250, 560, 748), fill=(158, 37, 32, 224), width=10)
        gd.polygon([(560, 195), (520, 285), (600, 285)], fill=(190, 48, 42, 230))
        gd.ellipse((530, 510, 590, 570), fill=(32, 34, 31), outline=(232, 203, 131), width=3)
        img.alpha_composite(group, (112, 860))
        draw_measure_card(img, (360, 1898), locale)
        ImageDraw.Draw(img).text((420, 2400), "开启空间判断之旅" if locale == "zh" else "Start with a clearer spatial read", font=fnt(locale, 38, "bold"), fill=GOLD if style == "light" else GOLD_SOFT)
    elif shot.kind == "compass":
        ring = compass_disc(alt, 860, 82)
        img.alpha_composite(ring, (210, 815))
        phone = phone_mockup(source, 720, 0)
        add_reflection(img, phone, (282, 665), 560)
        draw_coin(img, 850, 1540, 92)
    elif shot.kind == "grid":
        draw_grid_overlay(img, (118, 920), locale, style == "dark")
        phone = phone_mockup(source, 585, 2)
        add_reflection(img, phone, (575, 710), 520)
    elif shot.kind == "plan":
        room = draw_isometric_room(img, (0, 0), 0.72)
        img.alpha_composite(room, (72, 1050))
        d = ImageDraw.Draw(img)
        draw_needle(img, 444, 1000, 360)
        d.text((178, 1660), "CENTER" if locale == "en" else "立极点", font=fnt(locale, 30, "bold"), fill=GOLD_SOFT)
        phone = phone_mockup(source, 610, -2)
        add_reflection(img, phone, (560, 790), 500)
    elif shot.kind == "rooms":
        draw_room_list(img, locale)
        phone = phone_mockup(source, 640, 2.5)
        add_reflection(img, phone, (520, 710), 520)
    elif shot.kind == "records":
        phone_a = phone_mockup(alt, 460, -5)
        add_reflection(img, phone_a, (100, 1050), 430)
        phone_b = phone_mockup(source, 560, 3)
        add_reflection(img, phone_b, (610, 755), 520)
        d = ImageDraw.Draw(img)
        d.rounded_rectangle((112, 2220, 650, 2345), radius=34, fill=(255, 255, 255, 30), outline=(224, 197, 123, 80), width=1)
        d.text((152, 2254), "本地保存，按需分享" if locale == "zh" else "Local first. Share when ready.", font=fnt(locale, 32, "bold"), fill=(236, 218, 166))

    draw_proof(img, shot, locale)
    out.parent.mkdir(parents=True, exist_ok=True)
    img.convert("RGB").save(out, "PNG", optimize=True)


def draw_coin(img: Image.Image, x: int, y: int, size: int) -> None:
    coin = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(coin)
    for r in range(size // 2, 0, -1):
        t = r / (size / 2)
        c = (
            int(124 + (246 - 124) * (1 - t)),
            int(88 + (214 - 88) * (1 - t)),
            int(28 + (141 - 28) * (1 - t)),
            255,
        )
        d.ellipse((size // 2 - r, size // 2 - r, size // 2 + r, size // 2 + r), fill=c)
    d.ellipse((size * 0.28, size * 0.20, size * 0.72, size * 0.64), fill=(255, 244, 199, 90))
    shadow = Image.new("RGBA", (size + 80, size + 80), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.ellipse((40, 32, 40 + size, 32 + size), fill=(84, 58, 16, 74))
    shadow = shadow.filter(ImageFilter.GaussianBlur(20))
    img.alpha_composite(shadow, (x - 40, y - 30))
    img.alpha_composite(coin, (x, y))


def shots(locale: str) -> list[Shot]:
    if locale == "zh":
        return [
            Shot("hero", "TAME Space Compass / 探觅·空间罗盘", ("精准测向", "一眼定局"), "双盘罗盘、户型参考与本地记录，专为现场空间判断而生。", "双盘测向 / 户型参考 / 本地报告", SHOTS / "compass_pointer_to_marked_ring.png", SHOTS / "compass_red_pointer_arrow_unified.png", True),
            Shot("compass", "现场测向", ("专业罗盘", "稳定定位"), "红针锁定主方向，角度、刻度与参考信息保持同一视线。", "182.5° 地盘读数   190.0° 空间参考", SHOTS / "compass_red_pointer_arrow_unified.png", SHOTS / "compass_pointer_to_marked_ring.png"),
            Shot("grid", "九宫布局", ("格局参考", "清晰归位"), "把方位、年度与阶段信息集中查看，复杂关系一屏整理。", "九宫 / 年度 / 阶段", SHOTS / "overview-nine-palace-2026-05-22.png"),
            Shot("plan", "户型叠加", ("空间关系", "直接看图"), "导入户型，标记中心点、开口与功能区，关系更直观。", "中心点 / 开口 / 功能区", SHOTS / "analysis-yanggong-entry-2026-05-22.png", warm=True),
            Shot("rooms", "空间分组", ("卧室书房", "分开判断"), "卧室、书房、客厅、玄关各自成组，复盘更稳定。", "卧室 / 书房 / 客厅 / 玄关", SHOTS / "yanggong-fenjin-clean.png"),
            Shot("records", "本地记录", ("生成报告", "从容分享"), "测向、户型与备注保存在本机，需要沟通时再生成报告。", "本地保存 / 按需分享", SHOTS / "overview-graphical-entry-2026-05-22.png", SHOTS / "analysis-yanggong-entry-2026-05-22.png", True),
        ]
    return [
        Shot("hero", "TAME Space Compass", ("Precise Direction", "Clear Spatial Reads"), "Dual compass, floor-plan references, and local records for spatial field work.", "Dual compass / Plans / Local reports", SHOTS / "compass_pointer_to_marked_ring.png", SHOTS / "compass_red_pointer_arrow_unified.png", True),
        Shot("compass", "On-Site Reading", ("Professional", "Compass Positioning"), "A red needle keeps the main direction visible while details stay structured.", "182.5° Earth plate   190.0° Space reference", SHOTS / "compass_red_pointer_arrow_unified.png", SHOTS / "compass_pointer_to_marked_ring.png"),
        Shot("grid", "Nine-Grid Layouts", ("Complex Layouts", "Made Legible"), "Bring direction, annual, and period references into one calm visual system.", "Grid / Annual / Period", SHOTS / "en-US/flying-star-demo-2.png"),
        Shot("plan", "Plan Alignment", ("Map Direction", "To Real Rooms"), "Import a plan, place the center point, and align openings with room zones.", "Center / Opening / Room zones", ASSETS / "en-US/04-floor-plan-heatmap.png", warm=True),
        Shot("rooms", "Room Groups", ("Judge Each Space", "Separately"), "Keep bedrooms, studies, living areas, and entries organized for review.", "Bedroom / Study / Living / Entry", ASSETS / "en-US/05-bazhai.png"),
        Shot("records", "Local Records", ("Create Reports", "Share Calmly"), "Compass checks, plans, and notes stay on device until you choose to share.", "Local first / Share when needed", ASSETS / "en-US/06-record-share.png", ASSETS / "en-US/04-floor-plan-heatmap.png", True),
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


def validate(paths: Iterable[Path]) -> list[str]:
    issues: list[str] = []
    for path in paths:
        im = Image.open(path)
        if im.size != (W, H):
            issues.append(f"{path}: expected {W}x{H}, got {im.size}")
        if im.mode in {"RGBA", "LA"} or "transparency" in im.info:
            issues.append(f"{path}: alpha present")
    return issues


def main() -> int:
    ensure_dirs()
    for path in [ICON, *[s.source for s in shots("zh")], *[s.source for s in shots("en")]]:
        if not path.exists():
            print(f"Missing asset: {path}")
            return 1

    outputs: list[Path] = []
    zh_paths: list[Path] = []
    en_paths: list[Path] = []
    for locale, out_dir, bucket in [("zh", OUT_ZH, zh_paths), ("en", OUT_EN, en_paths)]:
        for idx, shot in enumerate(shots(locale)):
            out = out_dir / FINAL_NAMES[idx]
            render_shot(shot, locale, idx, out)
            bucket.append(out)
            outputs.append(out)

    contact_sheet(zh_paths, CONTACT / "zh-contactsheet.jpg")
    contact_sheet(en_paths, CONTACT / "en-contactsheet.jpg")

    issues = validate(outputs)
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
