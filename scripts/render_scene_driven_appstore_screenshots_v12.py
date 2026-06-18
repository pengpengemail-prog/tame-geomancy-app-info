#!/usr/bin/env python3
"""Render scene-driven App Store screenshots for TAME Space Compass.

This v12 pipeline treats screenshots like ads: each frame gets a real scene
background, a clear focal object, and a more cinematic sense of depth.
"""

from __future__ import annotations

import math
import random
from dataclasses import dataclass
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageEnhance, ImageFilter, ImageFont, ImageOps


ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "AppStoreAssets"
SHOTS = ROOT / "VerificationShots"
REFS = ASSETS / "reference-style"
BGS = ASSETS / "background-source"

OUT_ZH = ASSETS / "zh-Hans-campaign-v12"
OUT_EN = ASSETS / "en-US-campaign-v12"
CONTACT = ASSETS / "generated-marketing" / "campaign-v12"

W, H = 1284, 2778

PAPER = (250, 247, 239)
INK = (15, 18, 19)
MUTED = (90, 94, 91)
GOLD = (180, 148, 80)
GOLD_SOFT = (221, 194, 130)
GREEN = (24, 43, 35)
GREEN_DARK = (12, 21, 18)

FONT_ZH_SERIF = "/System/Library/Fonts/Supplemental/Songti.ttc"
FONT_ZH_BODY = "/System/Library/Fonts/Hiragino Sans GB.ttc"
FONT_EN = "/System/Library/Fonts/Helvetica.ttc"

ICON = ROOT / "Design" / "app-icon-original-geomancy-1024.png"

SCENES = {
    "hero": {
        "bg": BGS / "01-space-ring-mountains.jpg",
        "focus": (0.52, 0.58),
        "light": (0.50, 0.42),
        "warm": False,
    },
    "read": {
        "bg": BGS / "03-silver-flow.jpg",
        "focus": (0.35, 0.52),
        "light": (0.70, 0.24),
        "warm": True,
    },
    "layout": {
        "bg": BGS / "06-gold-crease.jpg",
        "focus": (0.58, 0.48),
        "light": (0.62, 0.28),
        "warm": True,
    },
    "report": {
        "bg": BGS / "09-chrome-sphere.jpg",
        "focus": (0.52, 0.54),
        "light": (0.50, 0.44),
        "warm": False,
    },
    "rooms": {
        "bg": BGS / "07-glass-forest-bubble.jpg",
        "focus": (0.50, 0.44),
        "light": (0.50, 0.24),
        "warm": True,
    },
    "close": {
        "bg": BGS / "10-galaxy-spiral.jpg",
        "focus": (0.52, 0.34),
        "light": (0.52, 0.36),
        "warm": False,
    },
}


@dataclass(frozen=True)
class Frame:
    key: str
    source: Path


ZH_COPY = {
    "hero": ("空间坐向", "一眼看清空间坐向", "罗盘、户型和记录放到同一屏。"),
    "read": ("现场读数", "现场读数更从容", "红针、角度与参考一起看，不用来回切。"),
    "layout": ("格局参考", "复杂格局一屏理顺", "把方位、年度与阶段整理成更清楚的判断。"),
    "report": ("户型对齐", "户型落点更直观", "中心点、开口、区域关系直接落到平面上。"),
    "rooms": ("空间分组", "房间分开看更稳", "卧室、书房、客厅分开记录，复盘更稳。"),
    "close": ("本地报告", "本地保存，按需分享", "记录留在本机，需要沟通时再生成报告。"),
}

EN_COPY = {
    "hero": ("Spatial reading", "See the spatial read at a glance", "Compass, plan, and notes stay in one view."),
    "read": ("On-site checks", "Read on-site with confidence", "Needle, angle, and reference together, without jumping around."),
    "layout": ("Layout reference", "Make complex layouts easier to read", "Bring direction, year, and period into one calm read."),
    "report": ("Plan alignment", "Map direction to real rooms", "Place center points, openings, and zones with confidence."),
    "rooms": ("Room groups", "Review each room separately", "Keep bedroom, study, and living areas organized."),
    "close": ("Local records", "Save locally. Share when ready.", "Your records stay on device until you choose to share."),
}


def font(locale: str, size: int, weight: str = "regular", serif: bool = False) -> ImageFont.FreeTypeFont:
    if locale == "zh" and serif:
        index = 1 if weight in {"bold", "heavy"} else 3
        return ImageFont.truetype(FONT_ZH_SERIF, size, index=index)
    if locale == "zh":
        index = 2 if weight in {"bold", "heavy"} else 0
        return ImageFont.truetype(FONT_ZH_BODY, size, index=index)
    return ImageFont.truetype(FONT_EN, size)


def load(path: Path) -> Image.Image:
    return Image.open(path).convert("RGB")


def fit_cover(img: Image.Image, size: tuple[int, int], centering: tuple[float, float] = (0.5, 0.5)) -> Image.Image:
    return ImageOps.fit(img, size, Image.Resampling.LANCZOS, centering=centering)


def rounded_mask(size: tuple[int, int], radius: int) -> Image.Image:
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, size[0] - 1, size[1] - 1), radius=radius, fill=255)
    return mask


def _lerp(a: int, b: int, t: float) -> int:
    return int(a + (b - a) * t)


def _blend(c1: tuple[int, int, int, int], c2: tuple[int, int, int, int], t: float) -> tuple[int, int, int, int]:
    return tuple(_lerp(c1[i], c2[i], t) for i in range(4))  # type: ignore[return-value]


def linear_gradient(
    size: tuple[int, int],
    stops: list[tuple[float, tuple[int, int, int, int]]],
    horizontal: bool = True,
) -> Image.Image:
    """Small local gradient helper used for metallic bevels and glass glints."""
    w, h = size
    out = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(out)
    steps = w if horizontal else h
    stops = sorted(stops, key=lambda item: item[0])
    for i in range(steps):
        p = i / max(1, steps - 1)
        left = stops[0]
        right = stops[-1]
        for s0, s1 in zip(stops, stops[1:]):
            if s0[0] <= p <= s1[0]:
                left, right = s0, s1
                break
        span = max(0.001, right[0] - left[0])
        color = _blend(left[1], right[1], (p - left[0]) / span)
        if horizontal:
            draw.line((i, 0, i, h), fill=color)
        else:
            draw.line((0, i, w, i), fill=color)
    return out


def rounded_gradient(
    size: tuple[int, int],
    radius: int,
    stops: list[tuple[float, tuple[int, int, int, int]]],
    horizontal: bool = True,
) -> Image.Image:
    layer = linear_gradient(size, stops, horizontal=horizontal)
    layer.putalpha(ImageChops.multiply(layer.getchannel("A"), rounded_mask(size, radius)))
    return layer


def wrap_lines(draw: ImageDraw.ImageDraw, text: str, fnt: ImageFont.FreeTypeFont, width: int) -> list[str]:
    if any("\u4e00" <= ch <= "\u9fff" for ch in text):
        tokens, sep = list(text), ""
    else:
        tokens, sep = text.split(), " "
    lines: list[str] = []
    current = ""
    for token in tokens:
        probe = token if not current else current + sep + token
        if draw.textbbox((0, 0), probe, font=fnt)[2] <= width:
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
    fnt: ImageFont.FreeTypeFont,
    fill: tuple[int, int, int],
    width: int,
    line_gap: int = 10,
) -> int:
    x, y = xy
    for line in wrap_lines(draw, text, fnt, width):
        draw.text((x, y), line, font=fnt, fill=fill)
        bbox = draw.textbbox((x, y), line, font=fnt)
        y += (bbox[3] - bbox[1]) + line_gap
    return y


def grain(img: Image.Image, seed: int, strength: int = 10) -> None:
    random.seed(seed)
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    for _ in range(6500):
        x = random.randrange(img.width)
        y = random.randrange(img.height)
        alpha = random.randrange(2, strength)
        color = (255, 255, 255, alpha) if random.random() < 0.40 else (0, 0, 0, alpha)
        draw.point((x, y), fill=color)
    img.alpha_composite(layer)


def glow(img: Image.Image, center: tuple[int, int], radius: int, color: tuple[int, int, int], alpha: int) -> None:
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    x, y = center
    draw.ellipse((x - radius, y - radius, x + radius, y + radius), fill=(*color, alpha))
    layer = layer.filter(ImageFilter.GaussianBlur(radius // 2))
    img.alpha_composite(layer)


def scene_bg(scene_key: str, seed: int) -> Image.Image:
    scene = SCENES[scene_key]
    base = fit_cover(load(scene["bg"]).convert("RGBA"), (W, H), centering=scene["focus"]).convert("RGBA")
    if scene["warm"]:
        wash = Image.new("RGBA", (W, H), (248, 244, 236, 70))
        halo_color = (222, 190, 128)
        horizon = (255, 255, 255, 42)
    else:
        wash = Image.new("RGBA", (W, H), (14, 28, 25, 92))
        halo_color = (160, 205, 206)
        horizon = (232, 238, 240, 36)

    base.alpha_composite(wash)
    glow(base, (int(W * scene["light"][0]), int(H * scene["light"][1])), 280, halo_color, 78 if scene["warm"] else 92)

    draw = ImageDraw.Draw(base)
    horizon_y = int(H * 0.61)
    draw.line((78, horizon_y, W - 78, horizon_y), fill=horizon, width=2)
    draw.line((W // 2, 110, W // 2, H - 140), fill=(255, 255, 255, 20) if scene["warm"] else (255, 255, 255, 14), width=1)

    fade = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    fd = ImageDraw.Draw(fade)
    for y in range(H):
        if y < 260:
            a = int(82 * (1 - y / 260) ** 2)
            fd.line((0, y, W, y), fill=(255, 255, 255, a))
        elif y > H - 320:
            a = int(102 * ((y - (H - 320)) / 320) ** 2)
            fd.line((0, y, W, y), fill=(0, 0, 0, a))
    base.alpha_composite(fade)

    grain(base, seed, 10 if scene["warm"] else 12)
    return base


def shadow(base: Image.Image, x: int, y: int, w: int, h: int, radius: int = 42, opacity: int = 82) -> None:
    layer = Image.new("RGBA", (w + 220, h + 220), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    draw.rounded_rectangle((110, 120, 110 + w, 120 + h), radius=radius, fill=(0, 0, 0, opacity))
    layer = layer.filter(ImageFilter.GaussianBlur(44))
    base.alpha_composite(layer, (x - 110, y - 88))


def cast_shadow(
    base: Image.Image,
    obj: Image.Image,
    xy: tuple[int, int],
    blur: int = 54,
    opacity: int = 86,
    offset: tuple[int, int] = (0, 34),
) -> None:
    margin = blur * 3
    alpha = obj.getchannel("A").point(lambda p: int(p * opacity / 255))
    layer = Image.new("RGBA", (obj.width + margin * 2, obj.height + margin * 2), (0, 0, 0, 0))
    shadow_alpha = Image.new("L", layer.size, 0)
    shadow_alpha.paste(alpha, (margin, margin))
    shadow_alpha = shadow_alpha.filter(ImageFilter.GaussianBlur(blur))
    layer.putalpha(shadow_alpha)
    base.alpha_composite(layer, (xy[0] - margin + offset[0], xy[1] - margin + offset[1]))


def screen_treatment(src: Image.Image, size: tuple[int, int]) -> Image.Image:
    screen = fit_cover(src.convert("RGB"), size)
    screen = ImageEnhance.Contrast(screen).enhance(1.05)
    screen = ImageEnhance.Sharpness(screen).enhance(1.08)
    screen = ImageEnhance.Color(screen).enhance(0.98)
    return screen


def extrude_device(front: Image.Image, angle: float) -> Image.Image:
    """Give a rotated phone a real side wall so it stops reading as a sticker."""
    if abs(angle) < 1:
        return front
    depth = max(7, int(front.width * 0.020))
    sign = -1 if angle < 0 else 1
    out = Image.new("RGBA", (front.width + depth * 3, front.height + depth * 3), (0, 0, 0, 0))
    alpha = front.getchannel("A")
    side = Image.new("RGBA", out.size, (0, 0, 0, 0))

    for i in range(depth, 0, -1):
        t = i / depth
        if sign > 0:
            color = _blend((24, 23, 21, 165), (150, 137, 105, 145), 1 - t)
        else:
            color = _blend((132, 121, 94, 155), (22, 21, 19, 165), 1 - t)
        layer = Image.new("RGBA", front.size, color)
        layer.putalpha(alpha.point(lambda p, tt=t: int(p * (0.22 + 0.20 * tt))))
        side.alpha_composite(layer, (depth + sign * i, depth + int(i * 0.72)))
    side = side.filter(ImageFilter.GaussianBlur(max(1, depth // 8)))
    out.alpha_composite(side)

    # Very small bottom rim and bounced highlight, like a product photo on glass.
    rim = Image.new("RGBA", front.size, (0, 0, 0, 0))
    rd = ImageDraw.Draw(rim)
    bbox = alpha.getbbox()
    if bbox:
        rd.line((bbox[0] + 38, bbox[3] - 14, bbox[2] - 38, bbox[3] - 14), fill=(255, 232, 174, 42), width=2)
    out.alpha_composite(rim, (depth, depth))
    out.alpha_composite(front, (depth, depth))
    bbox = out.getbbox()
    return out.crop(bbox) if bbox else out


def phone_mockup(src: Image.Image, width: int, angle: float = 0) -> Image.Image:
    """Render a premium product-style iPhone object instead of a flat black shell."""
    scale = 3
    body_w = int(width * scale)
    body_h = int(width * 2.16 * scale)
    pad = int(width * 0.11 * scale)
    radius = int(width * 0.18 * scale)
    phone = Image.new("RGBA", (body_w + pad * 2, body_h + pad * 2), (0, 0, 0, 0))
    d = ImageDraw.Draw(phone)
    x0, y0 = pad, pad
    x1, y1 = pad + body_w, pad + body_h

    # Physical side controls. They sit outside the body so the object reads as hardware.
    button_col = (78, 72, 61, 220)
    button_hi = (227, 212, 172, 82)
    d.rounded_rectangle((x0 - 7 * scale, y0 + 274 * scale, x0 + 2 * scale, y0 + 404 * scale), radius=5 * scale, fill=button_col)
    d.rounded_rectangle((x0 - 7 * scale, y0 + 454 * scale, x0 + 2 * scale, y0 + 555 * scale), radius=5 * scale, fill=button_col)
    d.rounded_rectangle((x1 - 2 * scale, y0 + 370 * scale, x1 + 7 * scale, y0 + 535 * scale), radius=5 * scale, fill=(58, 54, 48, 220))
    d.line((x0 - 2 * scale, y0 + 292 * scale, x0 - 2 * scale, y0 + 386 * scale), fill=button_hi, width=1 * scale)

    # Outer titanium body: warm graphite/champagne, with real edge bands.
    metal = rounded_gradient(
        (body_w, body_h),
        radius,
        [
            (0.00, (25, 24, 22, 255)),
            (0.08, (95, 88, 74, 255)),
            (0.20, (222, 210, 178, 255)),
            (0.36, (150, 139, 115, 255)),
            (0.55, (78, 74, 66, 255)),
            (0.76, (225, 214, 184, 255)),
            (0.92, (88, 81, 68, 255)),
            (1.00, (20, 19, 18, 255)),
        ],
        horizontal=True,
    )
    phone.alpha_composite(metal, (x0, y0))
    d.rounded_rectangle((x0, y0, x1, y1), radius=radius, outline=(255, 244, 210, 92), width=2 * scale)
    d.rounded_rectangle((x0 + 4 * scale, y0 + 5 * scale, x1 - 4 * scale, y1 - 5 * scale), radius=radius - 5 * scale, outline=(0, 0, 0, 88), width=5 * scale)

    lip = int(width * 0.030 * scale)
    inner_box = (x0 + lip, y0 + lip, x1 - lip, y1 - lip)
    d.rounded_rectangle(inner_box, radius=radius - lip, fill=(5, 6, 6, 255))
    d.rounded_rectangle(inner_box, radius=radius - lip, outline=(255, 255, 255, 38), width=2 * scale)

    screen_inset_x = int(width * 0.058 * scale)
    screen_top = int(width * 0.062 * scale)
    screen_bottom = int(width * 0.064 * scale)
    sx0, sy0 = x0 + screen_inset_x, y0 + screen_top
    sx1, sy1 = x1 - screen_inset_x, y1 - screen_bottom
    sw, sh = sx1 - sx0, sy1 - sy0
    sr = int(width * 0.115 * scale)
    screen = screen_treatment(src, (sw, sh)).convert("RGBA")
    phone.paste(screen, (sx0, sy0), rounded_mask((sw, sh), sr))

    # Inner glass edge, soft reflections, and a diagonal highlight that follows the body.
    glass = Image.new("RGBA", phone.size, (0, 0, 0, 0))
    gd = ImageDraw.Draw(glass)
    gd.rounded_rectangle((sx0, sy0, sx1, sy1), radius=sr, outline=(255, 255, 255, 74), width=2 * scale)
    gd.rounded_rectangle((sx0 + 3 * scale, sy0 + 3 * scale, sx1 - 3 * scale, sy1 - 3 * scale), radius=sr - 3 * scale, outline=(0, 0, 0, 52), width=2 * scale)
    gd.polygon(
        [
            (sx0 + 12 * scale, sy0 + 8 * scale),
            (sx0 + 156 * scale, sy0 + 8 * scale),
            (sx1 - 84 * scale, sy1 - 90 * scale),
            (sx1 - 238 * scale, sy1 - 90 * scale),
        ],
        fill=(255, 255, 255, 34),
    )
    gd.polygon(
        [
            (sx0 + 42 * scale, sy0 + 170 * scale),
            (sx0 + 88 * scale, sy0 + 170 * scale),
            (sx1 - 260 * scale, sy1 - 120 * scale),
            (sx1 - 318 * scale, sy1 - 120 * scale),
        ],
        fill=(255, 255, 255, 18),
    )
    bottom_vignette = linear_gradient((sw, int(240 * scale)), [(0, (0, 0, 0, 0)), (1, (0, 0, 0, 60))], horizontal=False)
    bottom_vignette.putalpha(ImageChops.multiply(bottom_vignette.getchannel("A"), rounded_mask(bottom_vignette.size, 22 * scale)))
    glass.alpha_composite(bottom_vignette, (sx0, sy1 - int(240 * scale)))

    # Simulator captures already include the Dynamic Island/status bar. Drawing it
    # twice makes the device look synthetic, so the hardware layer only adds glass.
    top_glint = linear_gradient(
        (sw - 90 * scale, 10 * scale),
        [(0.0, (255, 255, 255, 0)), (0.5, (255, 255, 255, 70)), (1.0, (255, 255, 255, 0))],
        horizontal=True,
    )
    glass.alpha_composite(top_glint.filter(ImageFilter.GaussianBlur(2 * scale)), (sx0 + 45 * scale, sy0 + 8 * scale))
    phone.alpha_composite(glass)

    # A subtle grounding rim keeps rotated phones from reading as a paper cutout.
    rim = Image.new("RGBA", phone.size, (0, 0, 0, 0))
    rd = ImageDraw.Draw(rim)
    rd.arc((x0 + 18 * scale, y1 - 96 * scale, x1 - 18 * scale, y1 + 30 * scale), 0, 180, fill=(255, 241, 198, 70), width=2 * scale)
    rd.line((x0 + 80 * scale, y1 - 22 * scale, x1 - 80 * scale, y1 - 22 * scale), fill=(0, 0, 0, 84), width=3 * scale)
    phone.alpha_composite(rim)

    phone = phone.resize((round(phone.width / scale), round(phone.height / scale)), Image.Resampling.LANCZOS)
    bbox = phone.getbbox()
    if bbox:
        phone = phone.crop(bbox)
    if angle:
        phone = phone.rotate(angle, resample=Image.Resampling.BICUBIC, expand=True)
        phone = extrude_device(phone, angle)
    return phone


def reflect(base: Image.Image, layer: Image.Image, xy: tuple[int, int], height: int = 400, strength: int = 42) -> None:
    x, y = xy
    crop = ImageOps.flip(layer).crop((0, 0, layer.width, min(height, layer.height)))
    fade = Image.new("L", crop.size, 0)
    fd = ImageDraw.Draw(fade)
    for row in range(crop.height):
        fd.line((0, row, crop.width, row), fill=int(strength * (1 - row / max(1, crop.height - 1)) ** 1.8))
    crop.putalpha(ImageChops.multiply(crop.getchannel("A"), fade))
    base.alpha_composite(crop, (x, y + layer.height - 86))


def circle_lens(src: Image.Image, size: int) -> Image.Image:
    src = src.convert("RGB")
    crop = fit_cover(src, (size, size))
    out = Image.new("RGBA", (size + 78, size + 78), (0, 0, 0, 0))
    shadow(out, 0, 0, size, size, radius=size // 2, opacity=74)
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).ellipse((0, 0, size - 1, size - 1), fill=255)
    disc = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    disc.paste(crop.convert("RGBA"), (0, 0), mask)
    out.alpha_composite(disc, (39, 39))
    d = ImageDraw.Draw(out)
    d.ellipse((39, 39, 39 + size, 39 + size), outline=(231, 201, 122, 210), width=7)
    d.ellipse((52, 52, 52 + size - 26, 52 + size - 26), outline=(255, 255, 255, 140), width=4)
    return out


def compass_disc(src: Image.Image, size: int) -> Image.Image:
    src = src.convert("RGB")
    crop = fit_cover(src, (size, size))
    out = Image.new("RGBA", (size + 180, size + 180), (0, 0, 0, 0))
    shadow(out, 0, 0, size, size, radius=size // 2, opacity=74)
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).ellipse((0, 0, size - 1, size - 1), fill=255)
    disc = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    disc.paste(crop.convert("RGBA"), (0, 0), mask)
    out.alpha_composite(disc, (90, 78))
    d = ImageDraw.Draw(out)
    d.ellipse((90, 78, 90 + size, 78 + size), outline=(228, 196, 123, 220), width=8)
    d.ellipse((104, 92, 104 + size - 28, 92 + size - 28), outline=(255, 255, 255, 130), width=4)
    d.line((90 + size // 2, 78 + size * 0.35, 90 + size // 2, 78 + size * 0.05), fill=(193, 45, 39, 210), width=max(8, size // 60))
    d.polygon(
        [
            (90 + size // 2, 78 + size * 0.03),
            (90 + size // 2 - 22, 78 + size * 0.12),
            (90 + size // 2 + 22, 78 + size * 0.12),
        ],
        fill=(193, 45, 39, 210),
    )
    return out


def footer(base: Image.Image, locale: str, dark: bool) -> None:
    draw = ImageDraw.Draw(base)
    text = (248, 243, 232, 255) if dark else (17, 18, 19, 255)
    muted = (224, 215, 198, 255) if dark else (96, 99, 95, 255)
    if ICON.exists():
        icon = fit_cover(load(ICON), (74, 74))
        mask = rounded_mask((74, 74), 18)
        ic = Image.new("RGBA", (74, 74), (0, 0, 0, 0))
        ic.paste(icon.convert("RGBA"), (0, 0), mask)
        base.alpha_composite(ic, (86, H - 180))
    draw.text((188, H - 172), "TAME Space Compass", font=font("en", 28, "bold"), fill=text)
    draw.text((188, H - 128), "空间参考工具" if locale == "zh" else "Spatial reference tool", font=font(locale, 23), fill=muted)


def hero_layout(base: Image.Image, src: Image.Image, locale: str, dark: bool) -> None:
    obj = compass_disc(src, 760)
    x, y = 78, 1120
    shadow(base, x, y, obj.width, obj.height, radius=170, opacity=72 if dark else 56)
    base.alpha_composite(obj, (x, y))
    if locale == "zh":
        x0, y0 = 86, 112
    else:
        x0, y0 = 86, 112
    draw = ImageDraw.Draw(base)
    draw.text((x0, y0), "01", font=font("en", 30, "bold"), fill=(GOLD_SOFT[0], GOLD_SOFT[1], GOLD_SOFT[2], 255))
    draw.line((x0 + 62, y0 + 18, x0 + 182, y0 + 18), fill=(GOLD_SOFT[0], GOLD_SOFT[1], GOLD_SOFT[2], 255), width=3)
    key, title, sub = (ZH_COPY["hero"] if locale == "zh" else EN_COPY["hero"])
    draw.text((x0, y0 + 76), key, font=font(locale, 24, "bold"), fill=(GOLD_SOFT[0], GOLD_SOFT[1], GOLD_SOFT[2], 255))
    draw_wrapped(draw, title, (x0, y0 + 160), font(locale, 92 if locale == "zh" else 78, "heavy", serif=(locale == "zh")), (PAPER if dark else INK), 850, 10)
    draw_wrapped(draw, sub, (x0, y0 + 380), font(locale, 31 if locale == "zh" else 29), (226, 219, 202) if dark else MUTED, 760, 12)
    chip_y = 2230
    chip_fill = (255, 255, 255, 38) if dark else (255, 255, 255, 180)
    chip_outline = (232, 214, 175, 72) if dark else (183, 162, 113, 110)
    chips = ["离线运行", "本地记录", "无需登录"] if locale == "zh" else ["Offline", "Local records", "No login"]
    for i, chip in enumerate(chips):
        w = 172 if locale == "zh" else 154
        x = 84 + i * (w + 16)
        draw.rounded_rectangle((x, chip_y, x + w, chip_y + 62), radius=31, fill=chip_fill, outline=chip_outline, width=2)
        draw.text((x + 20, chip_y + 17), chip, font=font(locale, 24 if locale == "zh" else 22, "bold"), fill=(35, 37, 35, 255) if not dark else (248, 243, 232, 255))
    footer(base, locale, dark)


def read_layout(base: Image.Image, src: Image.Image, locale: str, dark: bool) -> None:
    phone = phone_mockup(src, 610, -4)
    x, y = 646, 810
    cast_shadow(base, phone, (x, y), blur=62, opacity=96 if dark else 78, offset=(4, 44))
    base.alpha_composite(phone, (x, y))
    reflect(base, phone, (x, y), 390, 34)

    lens = circle_lens(src, 360)
    base.alpha_composite(lens, (122, 1350))
    draw = ImageDraw.Draw(base)
    key, title, sub = (ZH_COPY["read"] if locale == "zh" else EN_COPY["read"])
    draw.text((86, 112), "02", font=font("en", 30, "bold"), fill=(GOLD_SOFT[0], GOLD_SOFT[1], GOLD_SOFT[2], 255))
    draw.line((148, 130, 270, 130), fill=(GOLD_SOFT[0], GOLD_SOFT[1], GOLD_SOFT[2], 255), width=3)
    draw.text((86, 180), key, font=font(locale, 25, "bold"), fill=(GOLD_SOFT[0], GOLD_SOFT[1], GOLD_SOFT[2], 255))
    draw_wrapped(draw, title, (86, 262), font(locale, 88 if locale == "zh" else 74, "heavy", serif=(locale == "zh")), (PAPER if dark else INK), 820, 10)
    draw_wrapped(draw, sub, (86, 478), font(locale, 31 if locale == "zh" else 29), (224, 217, 202) if dark else MUTED, 760, 12)
    footer(base, locale, dark)


def layout_layout(base: Image.Image, src: Image.Image, locale: str, dark: bool) -> None:
    card = phone_mockup(src, 560, 4)
    x, y = 620, 790
    cast_shadow(base, card, (x, y), blur=58, opacity=90 if dark else 70, offset=(-6, 42))
    base.alpha_composite(card, (x, y))
    reflect(base, card, (x, y), 400, 30)

    focus = Image.new("RGBA", (530, 560), (0, 0, 0, 0))
    fd = ImageDraw.Draw(focus)
    fd.rounded_rectangle((14, 20, 516, 536), radius=34, fill=(250, 247, 240, 190) if not dark else (28, 33, 31, 210), outline=(230, 208, 162, 130), width=2)
    fd.line((40, 110, 490, 110), fill=(191, 171, 122, 140), width=2)
    fd.text((42, 46), "九宫参考", font=font(locale, 26, "bold"), fill=(GOLD if dark else INK) if locale == "zh" else (GOLD if dark else INK))
    if locale == "zh":
        labels = ["东", "南", "西", "北", "中", "宅"]
    else:
        labels = ["East", "South", "West", "North", "Center", "Home"]
    for i, label in enumerate(labels):
        xx = 44 + (i % 3) * 150
        yy = 172 + (i // 3) * 142
        fd.rounded_rectangle((xx, yy, xx + 120, yy + 88), radius=22, fill=(233, 227, 210, 230) if not dark else (49, 57, 53, 230), outline=(255, 255, 255, 88), width=2)
        fd.text((xx + 20, yy + 26), label, font=font(locale, 24, "bold"), fill=(INK if not dark else PAPER))
    base.alpha_composite(focus, (102, 880))

    draw = ImageDraw.Draw(base)
    key, title, sub = (ZH_COPY["layout"] if locale == "zh" else EN_COPY["layout"])
    draw.text((86, 112), "03", font=font("en", 30, "bold"), fill=(GOLD_SOFT[0], GOLD_SOFT[1], GOLD_SOFT[2], 255))
    draw.line((148, 130, 270, 130), fill=(GOLD_SOFT[0], GOLD_SOFT[1], GOLD_SOFT[2], 255), width=3)
    draw.text((86, 180), key, font=font(locale, 25, "bold"), fill=(GOLD_SOFT[0], GOLD_SOFT[1], GOLD_SOFT[2], 255))
    draw_wrapped(draw, title, (86, 262), font(locale, 86 if locale == "zh" else 72, "heavy", serif=(locale == "zh")), (PAPER if dark else INK), 830, 10)
    draw_wrapped(draw, sub, (86, 478), font(locale, 31 if locale == "zh" else 29), (224, 217, 202) if dark else MUTED, 770, 12)
    footer(base, locale, dark)


def report_layout(base: Image.Image, src: Image.Image, locale: str, dark: bool) -> None:
    phone = phone_mockup(src, 530, -5)
    x, y = 124, 910
    cast_shadow(base, phone, (x, y), blur=60, opacity=96 if dark else 72, offset=(0, 42))
    base.alpha_composite(phone, (x, y))
    reflect(base, phone, (x, y), 420, 28)

    card_src = fit_cover(src.convert("RGB"), (500, 700), centering=(0.55, 0.34))
    card = Image.new("RGBA", (540, 770), (0, 0, 0, 0))
    d = ImageDraw.Draw(card)
    d.rounded_rectangle((12, 18, 528, 754), radius=42, fill=(250, 247, 240, 222) if not dark else (27, 33, 31, 228), outline=(230, 210, 170, 150), width=2)
    card.paste(card_src.convert("RGBA"), (20, 26), rounded_mask((500, 700), 34))
    d.rounded_rectangle((42, 550, 498, 704), radius=30, fill=(255, 255, 255, 160) if not dark else (255, 255, 255, 28), outline=(224, 205, 165, 110), width=2)
    d.text((58, 574), "报告预览" if locale == "zh" else "Report preview", font=font(locale, 28, "bold"), fill=(INK if not dark else PAPER))
    d.text((58, 620), "本机保存 · 需要时再分享" if locale == "zh" else "Saved locally · Share when ready", font=font(locale, 23), fill=(92, 95, 90) if not dark else (216, 208, 193))
    base.alpha_composite(card, (640, 980))

    draw = ImageDraw.Draw(base)
    key, title, sub = (ZH_COPY["report"] if locale == "zh" else EN_COPY["report"])
    draw.text((86, 112), "04", font=font("en", 30, "bold"), fill=(GOLD_SOFT[0], GOLD_SOFT[1], GOLD_SOFT[2], 255))
    draw.line((148, 130, 270, 130), fill=(GOLD_SOFT[0], GOLD_SOFT[1], GOLD_SOFT[2], 255), width=3)
    draw.text((86, 180), key, font=font(locale, 25, "bold"), fill=(GOLD_SOFT[0], GOLD_SOFT[1], GOLD_SOFT[2], 255))
    draw_wrapped(draw, title, (86, 262), font(locale, 86 if locale == "zh" else 72, "heavy", serif=(locale == "zh")), (PAPER if dark else INK), 830, 10)
    draw_wrapped(draw, sub, (86, 478), font(locale, 31 if locale == "zh" else 29), (224, 217, 202) if dark else MUTED, 770, 12)
    footer(base, locale, dark)


def rooms_layout(base: Image.Image, src: Image.Image, locale: str, dark: bool) -> None:
    phone = phone_mockup(src, 580, 4.5)
    x, y = 615, 960
    cast_shadow(base, phone, (x, y), blur=60, opacity=96 if dark else 72, offset=(-4, 42))
    base.alpha_composite(phone, (x, y))
    reflect(base, phone, (x, y), 410, 30)

    chip_layer = Image.new("RGBA", (520, 480), (0, 0, 0, 0))
    d = ImageDraw.Draw(chip_layer)
    labels = ["卧室", "书房", "客厅", "玄关"] if locale == "zh" else ["Bedroom", "Study", "Living", "Entry"]
    fills = [(224, 212, 168, 220), (212, 229, 215, 220), (235, 218, 210, 220), (241, 232, 196, 220)]
    pos = [(32, 26), (86, 142), (24, 270), (96, 386)]
    for i, label in enumerate(labels):
        xx, yy = pos[i]
        d.rounded_rectangle((xx + 10, yy + 12, xx + 392, yy + 102), radius=24, fill=(0, 0, 0, 28))
        d.rounded_rectangle((xx, yy, xx + 382, yy + 90), radius=24, fill=fills[i], outline=(255, 255, 255, 120), width=2)
        d.text((xx + 30, yy + 26), label, font=font(locale, 30, "bold"), fill=INK)
    base.alpha_composite(chip_layer, (96, 980))

    draw = ImageDraw.Draw(base)
    key, title, sub = (ZH_COPY["rooms"] if locale == "zh" else EN_COPY["rooms"])
    draw.text((86, 112), "05", font=font("en", 30, "bold"), fill=(GOLD_SOFT[0], GOLD_SOFT[1], GOLD_SOFT[2], 255))
    draw.line((148, 130, 270, 130), fill=(GOLD_SOFT[0], GOLD_SOFT[1], GOLD_SOFT[2], 255), width=3)
    draw.text((86, 180), key, font=font(locale, 25, "bold"), fill=(GOLD_SOFT[0], GOLD_SOFT[1], GOLD_SOFT[2], 255))
    draw_wrapped(draw, title, (86, 262), font(locale, 86 if locale == "zh" else 72, "heavy", serif=(locale == "zh")), (PAPER if dark else INK), 830, 10)
    draw_wrapped(draw, sub, (86, 478), font(locale, 31 if locale == "zh" else 29), (224, 217, 202) if dark else MUTED, 770, 12)
    footer(base, locale, dark)


def close_layout(base: Image.Image, src: Image.Image, locale: str, dark: bool) -> None:
    icon = fit_cover(load(ICON), (290, 290))
    icon_layer = Image.new("RGBA", (330, 330), (0, 0, 0, 0))
    icon_layer.paste(icon.convert("RGBA"), (20, 20), rounded_mask((290, 290), 70))
    shadow(base, 470, 980, 330, 330, radius=74, opacity=78 if dark else 56)
    base.alpha_composite(icon_layer, (470, 980))

    disc = compass_disc(src, 360)
    base.alpha_composite(disc, (120, 1730))

    draw = ImageDraw.Draw(base)
    key, title, sub = (ZH_COPY["close"] if locale == "zh" else EN_COPY["close"])
    draw.text((86, 112), "06", font=font("en", 30, "bold"), fill=(GOLD_SOFT[0], GOLD_SOFT[1], GOLD_SOFT[2], 255))
    draw.line((148, 130, 270, 130), fill=(GOLD_SOFT[0], GOLD_SOFT[1], GOLD_SOFT[2], 255), width=3)
    draw.text((86, 180), key, font=font(locale, 25, "bold"), fill=(GOLD_SOFT[0], GOLD_SOFT[1], GOLD_SOFT[2], 255))
    draw_wrapped(draw, title, (86, 262), font(locale, 92 if locale == "zh" else 78, "heavy", serif=(locale == "zh")), (PAPER if dark else INK), 840, 10)
    draw_wrapped(draw, sub, (86, 478), font(locale, 31 if locale == "zh" else 29), (224, 217, 202) if dark else MUTED, 770, 12)

    brand = "TAME Space Compass / 探觅·空间罗盘" if locale == "zh" else "TAME Space Compass"
    draw.text((86, 2148), brand, font=font(locale, 28 if locale == "zh" else 26, "bold"), fill=(PAPER if dark else INK))
    draw.text((86, 2200), "让判断更轻、更稳、更清楚。" if locale == "zh" else "Spatial judgment, made calmer.", font=font(locale, 28 if locale == "zh" else 26), fill=(222, 215, 198) if dark else MUTED)


def render_frame(locale: str, frame: Frame, index: int) -> Image.Image:
    dark = not bool(SCENES[frame.key]["warm"])
    base = scene_bg(frame.key, 900 + index * 17)
    src = load(frame.source)
    if frame.key == "hero":
        hero_layout(base, src, locale, dark)
    elif frame.key == "read":
        read_layout(base, src, locale, dark)
    elif frame.key == "layout":
        layout_layout(base, src, locale, dark)
    elif frame.key == "report":
        report_layout(base, src, locale, dark)
    elif frame.key == "rooms":
        rooms_layout(base, src, locale, dark)
    else:
        close_layout(base, src, locale, dark)
    return base.convert("RGB")


def contact_sheet(paths: list[Path], out: Path) -> None:
    thumb_w = 360
    thumb_h = int(thumb_w * H / W)
    gap = 22
    sheet = Image.new("RGB", (thumb_w * 3 + gap * 4, thumb_h * 2 + gap * 3), (233, 229, 220))
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
    for d in (OUT_ZH, OUT_EN, CONTACT):
        d.mkdir(parents=True, exist_ok=True)

    frames = [
        Frame("hero", SHOTS / "compass_pointer_to_marked_ring.png"),
        Frame("read", SHOTS / "compass_red_pointer_arrow_unified.png"),
        Frame("layout", SHOTS / "overview-nine-palace-2026-05-22.png"),
        Frame("report", SHOTS / "analysis-yanggong-entry-2026-05-22.png"),
        Frame("rooms", SHOTS / "yanggong-fenjin-clean.png"),
        Frame("close", SHOTS / "overview-graphical-entry-2026-05-22.png"),
    ]
    en_frames = [
        Frame("hero", ASSETS / "en-US" / "01-dual-compass.png"),
        Frame("read", ASSETS / "en-US" / "02-opening-reference.png"),
        Frame("layout", ASSETS / "en-US" / "03-flying-star.png"),
        Frame("report", ASSETS / "en-US" / "04-floor-plan-heatmap.png"),
        Frame("rooms", ASSETS / "en-US" / "05-bazhai.png"),
        Frame("close", ASSETS / "en-US" / "06-record-share.png"),
    ]

    outputs: dict[str, list[Path]] = {"zh": [], "en": []}
    for locale, frame_set, out_dir in (("zh", frames, OUT_ZH), ("en", en_frames, OUT_EN)):
        for idx, frame in enumerate(frame_set):
            out = out_dir / f"{idx + 1:02d}.png"
            render_frame(locale, frame, idx).save(out, "PNG")
            outputs[locale].append(out)
        contact_sheet(outputs[locale], CONTACT / f"{locale}-contactsheet.jpg")

    issues = validate(outputs["zh"] + outputs["en"])
    if issues:
        print("Validation issues:")
        for issue in issues:
            print("-", issue)
        return 1

    print(f"Wrote zh screenshots to {OUT_ZH}")
    print(f"Wrote en screenshots to {OUT_EN}")
    print(f"Contact sheets in {CONTACT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
