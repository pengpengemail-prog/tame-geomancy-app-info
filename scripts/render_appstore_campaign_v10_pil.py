#!/usr/bin/env python3

from __future__ import annotations

import math
import textwrap
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[1]
W, H = 1284, 2778
OUT_ROOT = ROOT / "AppStoreAssets"
CAMPAIGN = OUT_ROOT / "generated-marketing" / "campaign-v10"
ZH_DIR = OUT_ROOT / "zh-Hans-campaign-v10"
EN_DIR = OUT_ROOT / "en-US-campaign-v10"

ICON = Path("/Users/pengpeng/Downloads/下载.png")
FONT_CN = "/System/Library/Fonts/STHeiti Medium.ttc"
FONT_EN = "/System/Library/Fonts/Helvetica.ttc"
FONT_EN_BOLD = "/System/Library/Fonts/Helvetica.ttc"

SOURCES = {
    "zh": [
        ROOT / "VerificationShots" / "compass_pointer_to_marked_ring.png",
        ROOT / "VerificationShots" / "compass_red_pointer_arrow_unified.png",
        ROOT / "AppStoreAssets" / "zh-Hans" / "03-flying-star.png",
        ROOT / "AppStoreAssets" / "zh-Hans" / "04-floor-plan-heatmap.png",
        ROOT / "AppStoreAssets" / "zh-Hans" / "05-bazhai.png",
        ROOT / "AppStoreAssets" / "zh-Hans" / "06-record-share.png",
    ],
    "en": [
        ROOT / "AppStoreAssets" / "en-US" / "01-dual-compass.png",
        ROOT / "AppStoreAssets" / "en-US" / "02-opening-reference.png",
        ROOT / "AppStoreAssets" / "en-US" / "03-flying-star.png",
        ROOT / "AppStoreAssets" / "en-US" / "04-floor-plan-heatmap.png",
        ROOT / "AppStoreAssets" / "en-US" / "05-bazhai.png",
        ROOT / "AppStoreAssets" / "en-US" / "06-record-share.png",
    ],
}

COPY = {
    "zh": [
        ("空间方向", "打开就能看清", "用罗盘、户型和记录整理现场判断。"),
        ("测向现场", "主方向一眼确认", "红针、角度和参考信息分层呈现。"),
        ("九宫布局", "复杂关系变直观", "把方位、年度与阶段参考放到同一屏。"),
        ("户型导入", "让方向落到房间", "中心点、开口和区域关系直接对齐。"),
        ("逐房间整理", "卧室书房各看各的", "把不同空间的参考信息分开记录。"),
        ("本地报告", "复盘分享更轻松", "离线保存，需要沟通时再生成分享卡。"),
    ],
    "en": [
        ("Room Direction", "Clear From The Start", "Organize compass checks, plans, and records in one place."),
        ("On-Site Checks", "Confirm The Main Direction", "Needle, angle, and reference details stay separated."),
        ("Nine-Grid View", "Make Layouts Easier To Read", "Keep direction, annual, and period references together."),
        ("Import A Plan", "Map Direction To Rooms", "Align center point, openings, and room zones directly."),
        ("Room Notes", "Separate Each Space", "Keep bedroom, study, and living areas organized."),
        ("Local Reports", "Review And Share Calmly", "Save offline, then create a share card when needed."),
    ],
}


def font(size: int, *, bold: bool = False, en: bool = False) -> ImageFont.FreeTypeFont:
    if en:
        path = FONT_EN_BOLD if bold else FONT_EN
    else:
        path = FONT_CN
    return ImageFont.truetype(path, size)


def gradient_bg(dark: bool) -> Image.Image:
    top = (22, 48, 41) if dark else (252, 250, 244)
    bottom = (38, 70, 60) if dark else (232, 222, 204)
    img = Image.new("RGB", (W, H), top)
    px = img.load()
    for y in range(H):
        t = y / (H - 1)
        for x in range(W):
            r = int(top[0] * (1 - t) + bottom[0] * t)
            g = int(top[1] * (1 - t) + bottom[1] * t)
            b = int(top[2] * (1 - t) + bottom[2] * t)
            glow = math.exp(-(((x - W * 0.72) / 520) ** 2 + ((y - H * 0.18) / 450) ** 2))
            if dark:
                r = min(255, int(r + glow * 28))
                g = min(255, int(g + glow * 24))
                b = min(255, int(b + glow * 9))
            else:
                r = min(255, int(r + glow * 15))
                g = min(255, int(g + glow * 15))
                b = min(255, int(b + glow * 12))
            px[x, y] = (r, g, b)
    return img


def round_rect_image(img: Image.Image, radius: int) -> Image.Image:
    img = img.convert("RGBA")
    mask = Image.new("L", img.size, 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0, img.width, img.height), radius=radius, fill=255)
    out = Image.new("RGBA", img.size, (0, 0, 0, 0))
    out.paste(img, (0, 0), mask)
    return out


def paste_shadow(base: Image.Image, box: tuple[int, int, int, int], radius: int, opacity: int = 80) -> None:
    x, y, w, h = box
    shadow = Image.new("RGBA", (w + 180, h + 180), (0, 0, 0, 0))
    d = ImageDraw.Draw(shadow)
    d.rounded_rectangle((90, 90, 90 + w, 90 + h), radius=radius, fill=(36, 28, 12, opacity))
    shadow = shadow.filter(ImageFilter.GaussianBlur(34))
    base.alpha_composite(shadow, (x - 90, y - 65))


def fit_cover(img: Image.Image, size: tuple[int, int]) -> Image.Image:
    tw, th = size
    scale = max(tw / img.width, th / img.height)
    nw, nh = int(img.width * scale), int(img.height * scale)
    resized = img.resize((nw, nh), Image.Resampling.LANCZOS)
    left = (nw - tw) // 2
    top = (nh - th) // 2
    return resized.crop((left, top, left + tw, top + th))


def fit_contain(img: Image.Image, size: tuple[int, int]) -> Image.Image:
    tw, th = size
    scale = min(tw / img.width, th / img.height)
    nw, nh = int(img.width * scale), int(img.height * scale)
    return img.resize((nw, nh), Image.Resampling.LANCZOS)


def paste_phone(base: Image.Image, src: Image.Image, xy: tuple[int, int], width: int, angle: float) -> tuple[int, int, int, int]:
    screen_w = width - 46
    screen_h = int(screen_w * 2.165)
    screen = fit_cover(src, (screen_w, screen_h))
    phone = Image.new("RGBA", (width, screen_h + 46), (0, 0, 0, 0))
    d = ImageDraw.Draw(phone)
    d.rounded_rectangle((0, 0, width, screen_h + 46), radius=84, fill=(18, 18, 17, 255))
    d.rounded_rectangle((23, 23, width - 23, screen_h + 23), radius=64, fill=(246, 244, 238, 255))
    phone.alpha_composite(round_rect_image(screen, 58), (23, 23))
    d.rounded_rectangle((width // 2 - 88, 35, width // 2 + 88, 72), radius=19, fill=(4, 4, 4, 255))
    shine = Image.new("RGBA", phone.size, (0, 0, 0, 0))
    sd = ImageDraw.Draw(shine)
    sd.polygon([(44, 40), (165, 40), (width - 90, screen_h + 35), (width - 240, screen_h + 35)], fill=(255, 255, 255, 34))
    phone.alpha_composite(shine)
    phone = phone.rotate(angle, resample=Image.Resampling.BICUBIC, expand=True)
    x, y = xy
    paste_shadow(base, (x, y, phone.width, phone.height), 90, 95)
    base.alpha_composite(phone, xy)
    return (x, y, phone.width, phone.height)


def paste_detail(base: Image.Image, src: Image.Image, center: tuple[int, int], size: int, dark: bool) -> None:
    crop = fit_cover(src, (size, size))
    mask = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(mask)
    d.ellipse((0, 0, size - 1, size - 1), fill=255)
    ring = Image.new("RGBA", (size + 54, size + 54), (0, 0, 0, 0))
    rd = ImageDraw.Draw(ring)
    rd.ellipse((12, 12, size + 42, size + 42), fill=(0, 0, 0, 70))
    ring = ring.filter(ImageFilter.GaussianBlur(22))
    x = center[0] - size // 2
    y = center[1] - size // 2
    base.alpha_composite(ring, (x - 27, y - 18))
    detail = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    detail.paste(crop.convert("RGBA"), (0, 0), mask)
    base.alpha_composite(detail, (x, y))
    od = ImageDraw.Draw(base)
    color = (235, 220, 176, 210) if dark else (184, 157, 94, 190)
    od.ellipse((x, y, x + size, y + size), outline=color, width=12)
    od.ellipse((x + 18, y + 18, x + size - 18, y + size - 18), outline=(255, 255, 255, 150), width=5)


def draw_wrapped(draw: ImageDraw.ImageDraw, xy: tuple[int, int], text: str, fnt: ImageFont.FreeTypeFont, fill, width: int, line_gap: int = 10) -> int:
    if len(text) <= 16 and any("\u4e00" <= ch <= "\u9fff" for ch in text):
        lines = [text]
    else:
        chars = 18 if any("\u4e00" <= ch <= "\u9fff" for ch in text) else 24
        lines = textwrap.wrap(text, width=chars)
    x, y = xy
    for line in lines:
        draw.text((x, y), line, font=fnt, fill=fill)
        bbox = draw.textbbox((x, y), line, font=fnt)
        y += bbox[3] - bbox[1] + line_gap
    return y


def draw_pills(base: Image.Image, labels: list[str], x: int, y: int, dark: bool) -> None:
    d = ImageDraw.Draw(base)
    f = font(27, bold=True)
    for label in labels:
        bbox = d.textbbox((0, 0), label, font=f)
        w = bbox[2] - bbox[0] + 54
        fill = (255, 255, 255, 38) if dark else (255, 255, 255, 188)
        outline = (232, 216, 175, 72) if dark else (186, 166, 115, 120)
        text = (246, 238, 219, 255) if dark else (54, 57, 54, 255)
        d.rounded_rectangle((x, y, x + w, y + 68), radius=34, fill=fill, outline=outline, width=2)
        d.text((x + 27, y + 19), label, font=f, fill=text)
        x += w + 16


def render(locale: str, i: int) -> Image.Image:
    is_zh = locale == "zh"
    dark = i in {0, 5}
    img = gradient_bg(dark).convert("RGBA")
    d = ImageDraw.Draw(img)
    for r in (620, 860, 1100):
        d.ellipse((W - 320 - r // 2, -160 - r // 2, W - 320 + r // 2, -160 + r // 2), outline=(238, 220, 171, 34) if dark else (45, 45, 40, 22), width=2)
    d.line((82, 1390, W - 82, 1390), fill=(235, 220, 176, 38) if dark else (25, 25, 23, 24), width=2)
    d.line((W // 2, 210, W // 2, H - 210), fill=(235, 220, 176, 28) if dark else (25, 25, 23, 18), width=2)

    kicker, title, subtitle = COPY[locale][i]
    src = Image.open(SOURCES[locale][i]).convert("RGB")
    main_left = i % 2 == 0
    if main_left:
        paste_phone(img, src, (78, 770), 610 if i else 660, -4)
        paste_detail(img, src, (930, 1650), 440, dark)
        pill_x = 650
    else:
        paste_phone(img, src, (610, 780), 590, 4)
        paste_detail(img, src, (280, 1660), 430, dark)
        pill_x = 84

    text_color = (248, 242, 228, 255) if dark else (15, 16, 16, 255)
    muted = (226, 216, 196, 255) if dark else (88, 91, 88, 255)
    accent = (216, 186, 114, 255) if dark else (166, 135, 74, 255)
    en_font = not is_zh
    d.text((84, 96), f"{i + 1:02d}", font=font(31, bold=True, en=en_font), fill=accent)
    d.line((155, 116, 280, 116), fill=accent, width=3)
    brand = "TAME Space Compass / 探觅·空间罗盘" if is_zh else "TAME Space Compass"
    d.text((84, 164), brand, font=font(25 if is_zh else 24, bold=True, en=en_font), fill=accent)
    d.text((84, 260), kicker, font=font(40 if is_zh else 36, bold=True, en=en_font), fill=accent if dark else (106, 91, 58, 255))
    draw_wrapped(d, (84, 324), title, font(92 if is_zh else 76, bold=True, en=en_font), text_color, 850, 12)
    draw_wrapped(d, (84, 540), subtitle, font(33 if is_zh else 30, en=en_font), muted, 760, 12)

    labels = ["离线运行", "本地记录", "无需登录"] if is_zh else ["Offline", "Local records", "No login"]
    draw_pills(img, labels, pill_x, 2260, dark)

    icon = round_rect_image(fit_cover(Image.open(ICON), (82, 82)), 22)
    img.alpha_composite(icon, (84, H - 184))
    d.text((188, H - 176), "TAME Space Compass", font=font(27, bold=True, en=True), fill=text_color)
    d.text((188, H - 132), "空间参考工具" if is_zh else "Spatial reference tool", font=font(23, en=en_font), fill=muted)
    return img.convert("RGB")


def main() -> None:
    for p in (CAMPAIGN, ZH_DIR, EN_DIR):
        p.mkdir(parents=True, exist_ok=True)
    outputs = {"zh": [], "en": []}
    for locale, out_dir in (("zh", ZH_DIR), ("en", EN_DIR)):
        for i in range(6):
            out = out_dir / f"{i + 1:02d}.png"
            render(locale, i).save(out)
            outputs[locale].append(out)

    for locale, files in outputs.items():
        thumbs = [Image.open(p).resize((360, round(360 * H / W)), Image.Resampling.LANCZOS) for p in files]
        sheet = Image.new("RGB", (1126, 1610), (232, 229, 220))
        for idx, thumb in enumerate(thumbs):
            x = 22 + (idx % 3) * 382
            y = 22 + (idx // 3) * (thumb.height + 22)
            sheet.paste(thumb, (x, y))
        sheet.save(CAMPAIGN / f"{locale}-contactsheet.jpg", quality=92)

    print(f"Wrote zh screenshots to {ZH_DIR}")
    print(f"Wrote en screenshots to {EN_DIR}")
    print(f"Contact sheets in {CAMPAIGN}")


if __name__ == "__main__":
    main()
