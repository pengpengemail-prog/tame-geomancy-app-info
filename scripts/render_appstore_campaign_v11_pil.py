#!/usr/bin/env python3

from __future__ import annotations

import math
import textwrap
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[1]
W, H = 1284, 2778
OUT_ROOT = ROOT / "AppStoreAssets"
CAMPAIGN = OUT_ROOT / "generated-marketing" / "campaign-v11"
ZH_DIR = OUT_ROOT / "zh-Hans-campaign-v11"
EN_DIR = OUT_ROOT / "en-US-campaign-v11"

ICON = Path("/Users/pengpeng/Downloads/下载.png")
FONT_CN = "/System/Library/Fonts/STHeiti Medium.ttc"
FONT_EN = "/System/Library/Fonts/Helvetica.ttc"


SOURCE_SETS = {
    "zh": [
        ("live", ROOT / "VerificationShots" / "compass_pointer_to_marked_ring.png"),
        ("live", ROOT / "VerificationShots" / "compass_red_pointer_arrow_unified.png"),
        ("crop", ROOT / "AppStoreAssets" / "zh-Hans" / "03-flying-star.png"),
        ("crop", ROOT / "AppStoreAssets" / "zh-Hans" / "04-floor-plan-heatmap.png"),
        ("crop", ROOT / "AppStoreAssets" / "zh-Hans" / "05-bazhai.png"),
        ("crop", ROOT / "AppStoreAssets" / "zh-Hans" / "06-record-share.png"),
    ],
    "en": [
        ("crop", ROOT / "AppStoreAssets" / "en-US" / "01-dual-compass.png"),
        ("crop", ROOT / "AppStoreAssets" / "en-US" / "02-opening-reference.png"),
        ("crop", ROOT / "AppStoreAssets" / "en-US" / "03-flying-star.png"),
        ("crop", ROOT / "AppStoreAssets" / "en-US" / "04-floor-plan-heatmap.png"),
        ("crop", ROOT / "AppStoreAssets" / "en-US" / "05-bazhai.png"),
        ("crop", ROOT / "AppStoreAssets" / "en-US" / "06-record-share.png"),
    ],
}


COPY = {
    "zh": [
        ("空间测向", "看清空间坐向", "红针、刻度和角度同时呈现，现场判断更稳。"),
        ("现场读数", "方向不再靠记忆", "测向、俯仰横滚与记录入口保持在同一屏。"),
        ("格局参考", "复杂关系一屏整理", "把方位、年度与阶段信息集中查看，少翻页。"),
        ("户型对齐", "让方向落到房间", "中心点、开口和区域关系直接落在户型上。"),
        ("空间分组", "每个房间分开判断", "卧室、书房、客厅等空间可以独立整理。"),
        ("本地记录", "复盘与分享更从容", "记录保存在本机，需要沟通时再生成报告卡。"),
    ],
    "en": [
        ("Spatial Reading", "Read Direction Clearly", "Keep the compass, angle, and field notes together."),
        ("On-Site Checks", "No More Guesswork", "Review the main direction and opening references in one flow."),
        ("Layout Reference", "Organize Complex Context", "Bring direction, year, and period references into one view."),
        ("Plan Alignment", "Map Direction To Rooms", "Connect center point, openings, and zones to the layout."),
        ("Room Groups", "Separate Every Space", "Review bedrooms, studies, and living areas with clearer context."),
        ("Local Records", "Review And Share Calmly", "Save records locally and create report cards when needed."),
    ],
}


def font(size: int, *, en: bool = False) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(FONT_EN if en else FONT_CN, size)


def text_size(draw: ImageDraw.ImageDraw, text: str, fnt: ImageFont.FreeTypeFont) -> tuple[int, int]:
    box = draw.textbbox((0, 0), text, font=fnt)
    return box[2] - box[0], box[3] - box[1]


def wrapped_lines(text: str, width: int, fnt: ImageFont.FreeTypeFont, draw: ImageDraw.ImageDraw, *, cn: bool) -> list[str]:
    if cn:
        lines: list[str] = []
        line = ""
        for ch in text:
            candidate = f"{line}{ch}"
            if text_size(draw, candidate, fnt)[0] <= width:
                line = candidate
            else:
                if line:
                    lines.append(line)
                line = ch
        if line:
            lines.append(line)
        return lines

    words = text.split()
    lines = []
    line = ""
    for word in words:
        candidate = word if not line else f"{line} {word}"
        if text_size(draw, candidate, fnt)[0] <= width:
            line = candidate
        else:
            if line:
                lines.append(line)
            line = word
    if line:
        lines.append(line)
    return lines


def draw_wrapped(
    draw: ImageDraw.ImageDraw,
    xy: tuple[int, int],
    text: str,
    fnt: ImageFont.FreeTypeFont,
    fill: tuple[int, int, int, int],
    width: int,
    *,
    cn: bool,
    gap: int = 10,
) -> int:
    x, y = xy
    for line in wrapped_lines(text, width, fnt, draw, cn=cn):
        draw.text((x, y), line, font=fnt, fill=fill)
        y += text_size(draw, line, fnt)[1] + gap
    return y


def background(dark: bool, frame: int) -> Image.Image:
    if dark:
        top, bottom = (17, 39, 34), (29, 62, 54)
    else:
        top, bottom = (253, 251, 246), (231, 224, 211)

    img = Image.new("RGB", (W, H), top)
    px = img.load()
    cx = W * (0.72 if frame % 2 == 0 else 0.25)
    cy = H * (0.24 if dark else 0.18)
    for y in range(H):
        t = y / (H - 1)
        for x in range(W):
            r = int(top[0] * (1 - t) + bottom[0] * t)
            g = int(top[1] * (1 - t) + bottom[1] * t)
            b = int(top[2] * (1 - t) + bottom[2] * t)
            glow = math.exp(-(((x - cx) / 560) ** 2 + ((y - cy) / 520) ** 2))
            if dark:
                r = min(255, int(r + glow * 22))
                g = min(255, int(g + glow * 18))
                b = min(255, int(b + glow * 8))
            else:
                r = min(255, int(r + glow * 20))
                g = min(255, int(g + glow * 17))
                b = min(255, int(b + glow * 10))
            px[x, y] = (r, g, b)

    out = img.convert("RGBA")
    d = ImageDraw.Draw(out)
    line = (229, 206, 151, 54) if dark else (46, 48, 43, 22)
    accent = (210, 178, 108, 98) if dark else (181, 149, 82, 88)
    for idx, r in enumerate((520, 760, 1040)):
        x0 = W - 180 - r // 2
        y0 = -90 - r // 2
        d.ellipse((x0, y0, x0 + r, y0 + r), outline=line if idx else accent, width=2)
    d.line((92, 1468, W - 92, 1468), fill=line, width=2)
    d.line((W // 2, 760, W // 2, H - 248), fill=line, width=2)
    return out


def rounded(img: Image.Image, radius: int) -> Image.Image:
    img = img.convert("RGBA")
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, img.width, img.height), radius=radius, fill=255)
    out = Image.new("RGBA", img.size, (0, 0, 0, 0))
    out.paste(img, (0, 0), mask)
    return out


def fit_cover(img: Image.Image, size: tuple[int, int]) -> Image.Image:
    tw, th = size
    scale = max(tw / img.width, th / img.height)
    resized = img.resize((int(img.width * scale), int(img.height * scale)), Image.Resampling.LANCZOS)
    left = (resized.width - tw) // 2
    top = (resized.height - th) // 2
    return resized.crop((left, top, left + tw, top + th))


def fit_width(img: Image.Image, width: int) -> Image.Image:
    h = round(img.height * width / img.width)
    return img.resize((width, h), Image.Resampling.LANCZOS)


def shadow(base: Image.Image, xy: tuple[int, int], size: tuple[int, int], radius: int, opacity: int) -> None:
    x, y = xy
    w, h = size
    canvas = Image.new("RGBA", (w + 180, h + 180), (0, 0, 0, 0))
    d = ImageDraw.Draw(canvas)
    d.rounded_rectangle((90, 90, 90 + w, 90 + h), radius=radius, fill=(23, 18, 12, opacity))
    canvas = canvas.filter(ImageFilter.GaussianBlur(36))
    base.alpha_composite(canvas, (x - 90, y - 64))


def extract_phone_object(src: Image.Image) -> Image.Image:
    # Existing generated screenshot pages already contain a clean device object.
    # Crop away their old poster headline so the final campaign owns the copy.
    crop = src.crop((78, 580, 1208, 2532)).convert("RGB")
    bg = crop.getpixel((0, 0))
    px = crop.load()
    xs: list[int] = []
    ys: list[int] = []
    for y in range(crop.height):
        for x in range(crop.width):
            p = px[x, y]
            if abs(p[0] - bg[0]) + abs(p[1] - bg[1]) + abs(p[2] - bg[2]) > 28:
                xs.append(x)
                ys.append(y)
    if not xs:
        return crop.convert("RGBA")
    pad = 34
    left = max(0, min(xs) - pad)
    top = max(0, min(ys) - pad)
    right = min(crop.width, max(xs) + pad)
    bottom = min(crop.height, max(ys) + pad)
    return crop.crop((left, top, right, bottom)).convert("RGBA")


def device_from_live(src: Image.Image, width: int) -> Image.Image:
    screen_w = width - 44
    screen_h = round(screen_w * 2556 / 1179)
    screen = fit_cover(src.convert("RGB"), (screen_w, screen_h))
    phone = Image.new("RGBA", (width, screen_h + 44), (0, 0, 0, 0))
    d = ImageDraw.Draw(phone)
    d.rounded_rectangle((0, 0, width, screen_h + 44), radius=86, fill=(17, 17, 16, 255))
    d.rounded_rectangle((22, 22, width - 22, screen_h + 22), radius=64, fill=(248, 247, 243, 255))
    phone.alpha_composite(rounded(screen, 56), (22, 22))
    shine = Image.new("RGBA", phone.size, (0, 0, 0, 0))
    sd = ImageDraw.Draw(shine)
    sd.polygon([(52, 42), (164, 42), (width - 80, screen_h + 26), (width - 232, screen_h + 26)], fill=(255, 255, 255, 28))
    phone.alpha_composite(shine)
    return phone


def paste_product(base: Image.Image, source_kind: str, source_path: Path, frame: int, dark: bool) -> None:
    src = Image.open(source_path).convert("RGB")

    if source_kind == "crop":
        obj = extract_phone_object(src)
        obj = fit_width(obj, 760 if frame in {0, 5} else 730)
    else:
        obj = device_from_live(src, 690 if frame == 0 else 650)

    angle = -3 if frame in {0, 3} else 3 if frame in {1, 4} else 0
    obj = obj.rotate(angle, resample=Image.Resampling.BICUBIC, expand=True)

    x_positions = [88, 420, 480, 86, 430, 412]
    y_positions = [760, 842, 810, 852, 842, 858]
    x = x_positions[frame]
    y = y_positions[frame]
    if frame == 0 and source_kind == "live":
        x = 96
    if frame == 1 and source_kind == "live":
        x = 548

    shadow(base, (x, y), obj.size, 92, 88 if dark else 70)
    base.alpha_composite(obj, (x, y))


def draw_brand_footer(base: Image.Image, locale: str, dark: bool) -> None:
    d = ImageDraw.Draw(base)
    text = (248, 242, 229, 255) if dark else (26, 27, 26, 255)
    muted = (216, 207, 188, 255) if dark else (98, 100, 94, 255)
    try:
        icon = rounded(fit_cover(Image.open(ICON), (78, 78)), 20)
        base.alpha_composite(icon, (86, H - 182))
    except FileNotFoundError:
        d.rounded_rectangle((86, H - 182, 164, H - 104), radius=20, fill=(235, 231, 220, 255))
    d.text((188, H - 172), "TAME Space Compass", font=font(27, en=True), fill=text)
    d.text((188, H - 128), "空间参考工具" if locale == "zh" else "Spatial reference tool", font=font(23, en=locale != "zh"), fill=muted)


def render(locale: str, frame: int) -> Image.Image:
    is_zh = locale == "zh"
    dark = frame in {0, 5}
    img = background(dark, frame)
    d = ImageDraw.Draw(img)

    accent = (216, 185, 112, 255) if dark else (166, 132, 68, 255)
    text = (250, 245, 232, 255) if dark else (19, 20, 19, 255)
    muted = (226, 216, 196, 255) if dark else (86, 88, 84, 255)

    kicker, title, subtitle = COPY[locale][frame]
    en = not is_zh
    d.text((86, 96), f"{frame + 1:02d}", font=font(31, en=en), fill=accent)
    d.line((156, 117, 284, 117), fill=accent, width=3)
    brand = "TAME Space Compass / 探觅·空间罗盘" if is_zh else "TAME Space Compass"
    d.text((86, 164), brand, font=font(24, en=en), fill=accent)
    d.text((86, 272), kicker, font=font(40 if is_zh else 36, en=en), fill=accent if dark else (104, 89, 55, 255))
    title_size = 88 if is_zh else 72
    draw_wrapped(d, (86, 336), title, font(title_size, en=en), text, 820, cn=is_zh, gap=12)
    draw_wrapped(d, (86, 560), subtitle, font(33 if is_zh else 30, en=en), muted, 760, cn=is_zh, gap=12)

    kind, path = SOURCE_SETS[locale][frame]
    paste_product(img, kind, path, frame, dark)
    draw_brand_footer(img, locale, dark)
    return img.convert("RGB")


def make_contact_sheet(locale: str, files: list[Path]) -> None:
    thumbs = [Image.open(path).resize((360, round(360 * H / W)), Image.Resampling.LANCZOS) for path in files]
    sheet = Image.new("RGB", (1126, 1610), (232, 229, 220))
    for idx, thumb in enumerate(thumbs):
        x = 22 + (idx % 3) * 382
        y = 22 + (idx // 3) * (thumb.height + 22)
        sheet.paste(thumb, (x, y))
    sheet.save(CAMPAIGN / f"{locale}-contactsheet.jpg", quality=92)


def main() -> None:
    for folder in (CAMPAIGN, ZH_DIR, EN_DIR):
        folder.mkdir(parents=True, exist_ok=True)

    for locale, out_dir in (("zh", ZH_DIR), ("en", EN_DIR)):
        files: list[Path] = []
        for frame in range(6):
            out = out_dir / f"{frame + 1:02d}.png"
            render(locale, frame).save(out)
            files.append(out)
        make_contact_sheet(locale, files)

    print(f"Wrote zh screenshots to {ZH_DIR}")
    print(f"Wrote en screenshots to {EN_DIR}")
    print(f"Contact sheets in {CAMPAIGN}")


if __name__ == "__main__":
    main()
