"""Draws media/logo.png, the 400x400 CurseForge project logo.

Four keycaps in the WASD shape. Each shows its Dvorak character large and the
QWERTY letter on the same physical key small in the corner.
Run: python3 media/make_logo.py  (needs Pillow)
"""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

SIZE = 400
S = 4  # draw at 4x, then shrink for smooth edges
W = SIZE * S

BG_TOP, BG_BOTTOM = (24, 28, 58), (52, 26, 78)
CAP_TOP, CAP_BOTTOM = (64, 70, 104), (40, 44, 72)
CAP_EDGE = (20, 22, 40)
DVORAK_COLOR = (92, 224, 200)
QWERTY_COLOR = (170, 176, 210)

BOLD = "/usr/share/fonts/truetype/noto/NotoSans-Bold.ttf"
big = ImageFont.truetype(BOLD, 64 * S)
small = ImageFont.truetype(BOLD, 22 * S)

# (QWERTY letter, Dvorak character, column, row) on a 3x2 grid.
KEYS = [("W", ",", 1, 0), ("A", "A", 0, 1), ("S", "O", 1, 1), ("D", "E", 2, 1)]
CAP = 104 * S
GAP = 14 * S
LEFT = (W - (3 * CAP + 2 * GAP)) // 2
TOP = (W - (2 * CAP + GAP)) // 2 + 6 * S
RADIUS = 18 * S


def vertical_gradient(size, top, bottom):
    w, h = size
    img = Image.new("RGB", size)
    d = ImageDraw.Draw(img)
    for y in range(h):
        t = y / (h - 1)
        d.line([(0, y), (w, y)], fill=tuple(round(a + (b - a) * t) for a, b in zip(top, bottom)))
    return img


img = vertical_gradient((W, W), BG_TOP, BG_BOTTOM)

# Soft shadow under the keys.
shadow = Image.new("L", (W, W), 0)
sd = ImageDraw.Draw(shadow)
for _, _, col, row in KEYS:
    x, y = LEFT + col * (CAP + GAP), TOP + row * (CAP + GAP)
    sd.rounded_rectangle([x, y + 10 * S, x + CAP, y + CAP + 10 * S], RADIUS, fill=150)
shadow = shadow.filter(ImageFilter.GaussianBlur(10 * S))
img.paste((8, 8, 20), mask=shadow)

draw = ImageDraw.Draw(img)
for qwerty, dvorak, col, row in KEYS:
    x, y = LEFT + col * (CAP + GAP), TOP + row * (CAP + GAP)
    # Keycap: dark edge, then a lighter gradient top face.
    draw.rounded_rectangle([x, y, x + CAP, y + CAP], RADIUS, fill=CAP_EDGE)
    face = vertical_gradient((CAP - 12 * S, CAP - 18 * S), CAP_TOP, CAP_BOTTOM)
    mask = Image.new("L", face.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, face.size[0] - 1, face.size[1] - 1], RADIUS - 4 * S, fill=255)
    img.paste(face, (x + 6 * S, y + 4 * S), mask)
    # Small QWERTY letter, top left.
    draw.text((x + 16 * S, y + 10 * S), qwerty, font=small, fill=QWERTY_COLOR)
    # Large Dvorak character, its ink centred on the face (so the comma
    # doesn't sit on the baseline).
    cx, cy = x + CAP // 2 + 4 * S, y + CAP // 2 + 4 * S
    l, t, r, b = draw.textbbox((0, 0), dvorak, font=big)
    draw.text((cx - (l + r) / 2, cy - (t + b) / 2), dvorak, font=big, fill=DVORAK_COLOR)

out = Path(__file__).with_name("logo.png")
img.resize((SIZE, SIZE), Image.LANCZOS).save(out, optimize=True)
print(out)
