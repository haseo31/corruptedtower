#!/usr/bin/env python3
"""Generates all pixel art for The Corrupted Tower from code.

Usage:  python tools/art/generate_art.py [output_dir]

Writes the tile atlas, the character sheets and a bitmap font into assets/art/
(or the given directory). Standard library only. Output is deterministic: running
it twice gives byte-identical files. All art is original, drawn here as text grids.
"""
import json
import struct
import sys
import zlib
from pathlib import Path

TILE = 16
CHAR_W, CHAR_H = 16, 20
CLEAR = (0, 0, 0, 0)


def rgb(h):
    h = h.lstrip("#")
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), 255)


# --------------------------------------------------------------------------- PNG

def write_png(path, pixels):
    """pixels: list of rows of (r, g, b, a). Writes an RGBA PNG."""
    height, width = len(pixels), len(pixels[0])
    raw = bytearray()
    for row in pixels:
        raw.append(0)
        for px in row:
            raw.extend(px)

    def chunk(tag, data):
        body = tag + data
        return struct.pack(">I", len(data)) + body + struct.pack(">I", zlib.crc32(body) & 0xFFFFFFFF)

    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(bytes(raw), 9))
    png += chunk(b"IEND", b"")
    Path(path).write_bytes(png)


def blank(w, h, color=CLEAR):
    return [[color for _ in range(w)] for _ in range(h)]


def blit(dst, src, ox, oy):
    for y, row in enumerate(src):
        for x, px in enumerate(row):
            if px[3] and 0 <= oy + y < len(dst) and 0 <= ox + x < len(dst[0]):
                dst[oy + y][ox + x] = px


# ------------------------------------------------------------------------ tiles

def floor_tile():
    t = blank(TILE, TILE, rgb("8fa3b8"))
    for y in range(TILE):
        for x in range(TILE):
            if (x // 8 + y // 8) % 2 == 1:
                t[y][x] = rgb("9aaec3")
            if x == 15 or y == 15:
                t[y][x] = rgb("7a8ea5")
            if (x + y * 3) % 11 == 0:
                t[y][x] = rgb("a6bace")
    return t


def carpet_tile():
    t = blank(TILE, TILE, rgb("8c3c46"))
    for y in range(TILE):
        for x in range(TILE):
            if x % 4 == 1 and y % 4 == 1:
                t[y][x] = rgb("aa525c")
            if (x + y) % 8 == 0:
                t[y][x] = rgb("7a3039")
            if y in (0, 15):
                t[y][x] = rgb("6a2830")
    return t


def wall_face_tile():
    t = blank(TILE, TILE, rgb("d9d2c0"))
    for y in range(TILE):
        for x in range(TILE):
            if x % 8 == 0 and y < 10:
                t[y][x] = rgb("cdc5b0")
            if 10 <= y <= 11:
                t[y][x] = rgb("b0a58c")
            if y >= 12:
                t[y][x] = rgb("6e6252") if y > 13 else rgb("857865")
            if y == 0:
                t[y][x] = rgb("efe9d8")
    return t


def wall_block_tile():
    t = blank(TILE, TILE, rgb("6b6f8a"))
    for y in range(TILE):
        for x in range(TILE):
            if y >= 10:
                t[y][x] = rgb("4a4d66")
            if y == 0:
                t[y][x] = rgb("8a8fae")
            if y == 10:
                t[y][x] = rgb("2f3147")
            if y >= 10 and (x + (y // 3) * 4) % 8 == 0:
                t[y][x] = rgb("3c3f58")
            if y < 10 and (x * 5 + y * 3) % 13 == 0:
                t[y][x] = rgb("7a7e9c")
    return t


def desk_tile(with_paper=False):
    t = blank(TILE, TILE)
    outline = rgb("3c281c")
    for y in range(1, 15):
        for x in range(16):
            top = y <= 9
            color = rgb("b98a55") if top else rgb("8a6038")
            if top and y % 3 == 0 and 2 < y < 9:
                color = rgb("a87c4a")
            t[y][x] = color
    for x in range(16):
        t[0][x] = outline
        t[1][x] = rgb("d4a56a")
        t[14][x] = outline
    for y in range(1, 15):
        t[y][0] = outline
        t[y][15] = outline
    for x in range(3, 13):
        t[11][x] = rgb("6a4828")
        t[13][x] = rgb("6a4828")
    for y in range(11, 14):
        t[y][3] = rgb("6a4828")
        t[y][12] = rgb("6a4828")
    t[12][7] = rgb("e8c16a")
    t[12][8] = rgb("e8c16a")
    if with_paper:
        for y in range(3, 8):
            for x in range(4, 11):
                t[y][x] = rgb("f2efe4")
        for x in range(5, 10):
            t[4][x] = rgb("9a98a0")
            t[6][x] = rgb("9a98a0")
    return t


def stairs_tile(locked=False):
    base = rgb("a64a4a") if locked else rgb("2f9e8f")
    light = rgb("c97070") if locked else rgb("5fc4b4")
    dark = rgb("7a3434") if locked else rgb("1f6e63")
    t = blank(TILE, TILE, base)
    for y in range(TILE):
        for x in range(TILE):
            if y % 4 == 0:
                t[y][x] = light
            elif y % 4 == 3:
                t[y][x] = dark
    for y in range(4, 12):
        w = (y - 3) // 2
        for x in range(8 - w, 8 + w):
            t[y][x] = rgb("f4f2e8")
    return t


TILE_ORDER = [
    ("floor", floor_tile),
    ("carpet", carpet_tile),
    ("wall_face", wall_face_tile),
    ("wall_block", wall_block_tile),
    ("desk", desk_tile),
    ("desk_paper", lambda: desk_tile(True)),
    ("stairs_open", stairs_tile),
    ("stairs_locked", lambda: stairs_tile(True)),
]


def make_tiles(out):
    atlas = blank(TILE * len(TILE_ORDER), TILE)
    index = {}
    for i, (name, make) in enumerate(TILE_ORDER):
        blit(atlas, make(), i * TILE, 0)
        index[name] = i
    write_png(out / "tiles.png", atlas)
    (out / "tiles.json").write_text(json.dumps({"tile_size": TILE, "tiles": index}, indent=2) + "\n")


# -------------------------------------------------------------------- characters

PALETTE = {
    ".": CLEAR,
    "K": rgb("2b2233"),  # outline
    "C": rgb("2f9e8f"),  # cap
    "c": rgb("247a6e"),  # cap shade
    "H": rgb("5a3a2e"),  # hair
    "h": rgb("7a5240"),  # hair light
    "S": rgb("f5cfa8"),  # skin
    "s": rgb("dba57b"),  # skin shade
    "T": rgb("d2b27a"),  # coat
    "t": rgb("a98a52"),  # coat shade
    "P": rgb("3a4a7a"),  # pants
    "B": rgb("1f1a26"),  # shoes
    "R": rgb("c03030"),  # tie
    "G": rgb("3a3a55"),  # glasses
    "M": rgb("8a8a94"),  # moustache
    "Y": rgb("e8c030"),  # lanyard
    "W": rgb("f4f2e8"),  # badge
    "o": rgb("8a6038"),  # wood
    "U": rgb("3f7a3f"),  # hood
}

DOWN = [
    "................",
    ".....KKKKKK.....",
    "....KCCCCCCK....",
    "...KCCCCCCCCK...",
    "..KKcccccccccKK.",
    "...KHHHHHHHHK...",
    "...KSSSSSSSSK...",
    "...KSKSSSSKSK...",
    "...KSSSSSSSSK...",
    "....KsSSSSsK....",
    ".....KKSSKK.....",
    "....KTTTTTTK....",
    "...KTTTTTTTTK...",
    "..KSKTTttTTKSK..",
    "..KSKTTttTTKSK..",
    "....KPPPPPPK....",
    "....KPPKKPPK....",
    "....KPPK.KPPK...",
    "...KBBBK.KBBBK..",
    "...KKKKK.KKKKK..",
]
DOWN_W1 = DOWN[:17] + ["....KPPK.KPPK...", "...KBBBK.KBBK...", "...KKKKK.KKKK..."]
DOWN_W2 = DOWN[:17] + ["....KPPK.KPPK...", "..KBBK.KBBBK....", "..KKKK.KKKKK...."]
UP = [
    "................",
    ".....KKKKKK.....",
    "....KCCCCCCK....",
    "...KCCCCCCCCK...",
    "...KccccccccK...",
    "...KHHHHHHHHK...",
    "...KHHHHHHHHK...",
    "...KHHhHHhHHK...",
    "...KHHHHHHHHK...",
    "....KHHHHHHK....",
    ".....KKssKK.....",
] + DOWN[11:]
UP_W1 = UP[:17] + DOWN_W1[17:]
UP_W2 = UP[:17] + DOWN_W2[17:]
LEFT = [
    "................",
    ".....KKKKKK.....",
    "....KCCCCCCK....",
    "...KCCCCCCCCK...",
    "..KKKccccccK....",
    "..KSKHHHHHHK....",
    "..KSSSSSSSSK....",
    "..KSKSSSSSSK....",
    "..KSSSSSSSSK....",
    "...KsSSSSSsK....",
    "....KKSSSKK.....",
    "....KTTTTTTK....",
    "...KTTTTTTTTK...",
    "...KTTttTTTTK...",
    "...KTSSttTTTK...",
    "....KPPPPPPK....",
    "....KPPPPPPK....",
    "....KPPKPPPK....",
    "...KBBBKBBBK....",
    "...KKKKKKKKK....",
]
LEFT_W1 = LEFT[:16] + ["....KPPPPPPK....", "...KPPK..KPPK...", "..KBBBK..KBBK...", "..KKKKK..KKKK..."]
LEFT_W2 = LEFT[:16] + ["....KPPPPPPK....", "....KPPKPPK.....", "...KBBKBBBK.....", "...KKKKKKKK....."]

def mirror(rows):
    return [row[::-1] for row in rows]


def frames_for(direction):
    if direction == "down":
        return [DOWN, DOWN_W1, DOWN_W2]
    if direction == "up":
        return [UP, UP_W1, UP_W2]
    if direction == "left":
        return [LEFT, LEFT_W1, LEFT_W2]
    return [mirror(r) for r in [LEFT, LEFT_W1, LEFT_W2]]


# Accessory overlays: (x, y, char) lists per direction. Applied on top of the grid.
OVERLAYS = {
    "glasses": {
        "down": [(4, 7, "G"), (6, 7, "G"), (7, 7, "G"), (8, 7, "G"), (9, 7, "G"), (11, 7, "G")],
        "left": [(3, 7, "G"), (5, 7, "G")],
        "right": [(12, 7, "G"), (10, 7, "G")],
    },
    "tie": {
        "down": [(7, 12, "R"), (8, 12, "R"), (7, 13, "R"), (8, 13, "R"), (7, 14, "R"), (8, 14, "R")],
    },
    "moustache": {
        "down": [(6, 8, "M"), (7, 8, "M"), (8, 8, "M"), (9, 8, "M")],
        "left": [(3, 8, "M"), (4, 8, "M")],
        "right": [(12, 8, "M"), (11, 8, "M")],
    },
    "lanyard": {
        "down": [(6, 11, "Y"), (9, 11, "Y"), (7, 12, "Y"), (8, 12, "Y"), (7, 13, "W"), (8, 13, "W")],
    },
    "hood": {
        "down": [(5, 10, "U"), (10, 10, "U"), (5, 11, "U"), (6, 11, "U"), (9, 11, "U"), (10, 11, "U")],
    },
    "mop": {
        "down": [(14, y, "o") for y in range(9, 18)]
        + [(13, 18, "M"), (14, 18, "M"), (15, 18, "M"), (13, 19, "M"), (14, 19, "M"), (15, 19, "M")],
    },
    "papers": {
        "down": [(13, 12, "W"), (14, 12, "W"), (15, 12, "W"), (13, 13, "W"), (14, 13, "M"), (15, 13, "W"),
                 (13, 14, "W"), (14, 14, "W"), (15, 14, "W"), (13, 15, "W"), (14, 15, "M"), (15, 15, "W")],
    },
}

# Rows 0-4 of the head for each hair style, per direction (right mirrors left).
HAIR_STYLES = {
    "spiky": {
        "down": ["....K.K..K.K....", "....KHKHHKHK....", "...KHHHHHHHHK...", "...KHHHHHHHHK...", "...KHHHHHHHHK..."],
        "left": ["....K.K.K.K.....", "....KHKHHKHK....", "...KHHHHHHHHK...", "..KHHHHHHHHHK...", "..KKHHHHHHHK...."],
    },
    "bun": {
        "down": ["......KKKK......", ".....KHHHHK.....", "....KHHHHHHK....", "...KHHHHHHHHK...", "...KHHHHHHHHK..."],
        "left": ["......KKKK......", ".....KHHHHK.....", "....KHHHHHHK....", "...KHHHHHHHHK...", "..KKHHHHHHHK...."],
    },
    "slick": {
        "down": ["................", ".....KKKKKK.....", "....KHHHHHHK....", "...KHHhhHHHHK...", "...KHHHHHHHHK..."],
        "left": ["................", ".....KKKKKK.....", "....KHHHHHHK....", "...KHHhhHHHHK...", "..KKHHHHHHHK...."],
    },
}

# A long skirt replaces the legs (rows 15-19), identical for every direction.
SKIRT = [
    "....KTTTTTTK....",
    "...KTTTTTTTTK...",
    "..KTTTTTTTTTTK..",
    "..KTTTttttTTTK..",
]
SKIRT_HEM = ["..KKBKKKKKKBKK..", "..KKKBKKKKBKKK..", "..KBKKKKKKKKBK.."]

CHARACTERS = {
    "player": {},
    "clerk": {
        "hair_style": "slick", "hair": "4a3426", "hair_shade": "6a4a3a",
        "colors": {"T": "e8e8f0", "t": "c0c0d0", "P": "4a4a5a", "R": "2f5fa8"},
        "overlays": ["glasses", "tie", "papers"],
    },
    "janitor": {
        "colors": {"C": "6b7280", "c": "4b5563", "T": "4a6fa5", "t": "35527d", "P": "35527d"},
        "overlays": ["moustache", "mop"],
    },
    "archivist": {
        "hair_style": "bun", "hair": "b0b0c0", "hair_shade": "8a8a9a",
        "colors": {"T": "8a6a4a", "t": "6a4e34", "B": "4a3a2a"},
        "overlays": ["glasses"],
        "body": "skirt",
    },
    "intern": {
        "hair_style": "spiky", "hair": "e0802a", "hair_shade": "b86018",
        "colors": {"T": "5a9a5a", "t": "3f7a3f", "P": "3a4a7a", "U": "3f7a3f"},
        "overlays": ["hood", "lanyard"],
    },
}


def render_frame(rows, spec, direction, frame_index=0):
    palette = dict(PALETTE)
    for key, value in spec.get("colors", {}).items():
        palette[key] = rgb(value)
    grid = [list(r) for r in rows]
    if "hair_style" in spec:
        palette["H"] = rgb(spec["hair"])
        palette["h"] = rgb(spec["hair_shade"])
        key = "left" if direction in ("left", "right") else "down"
        for i, row in enumerate(HAIR_STYLES[spec["hair_style"]][key]):
            grid[i] = list(row[::-1] if direction == "right" else row)
    if spec.get("body") == "skirt":
        for i, row in enumerate(SKIRT):
            grid[15 + i] = list(row)
        grid[19] = list(SKIRT_HEM[frame_index])
    for name in spec.get("overlays", []):
        for x, y, ch in OVERLAYS[name].get(direction, []):
            grid[y][x] = ch
    return [[palette[ch] for ch in row] for row in grid]


def make_character(out, name, spec):
    directions = ["down", "up", "left", "right"]
    sheet = blank(CHAR_W * 3, CHAR_H * 4)
    for row, direction in enumerate(directions):
        for col, rows in enumerate(frames_for(direction)):
            assert len(rows) == CHAR_H and all(len(r) == CHAR_W for r in rows), (name, direction, col)
            blit(sheet, render_frame(rows, spec, direction, col), col * CHAR_W, row * CHAR_H)
    write_png(out / ("char_%s.png" % name), sheet)


# ------------------------------------------------------------------------ bosses
# Bosses are bespoke 24x24 sprites with two idle frames, not recolors of the shared body.

BOSS = 24

DEPUTY = [
    "........................",
    ".......KKKKKKKKKK.......",
    "......KSSSSSSSSSSK......",
    ".....KSSSSSSSSSSSSK.....",
    ".....KSHHHHHHHHHHSK.....",
    ".....KSSSSSSSSSSSSK.....",
    ".....KSKKKSSSSKKKSK.....",
    ".....KSSKSSSSSSKSSK.....",
    ".....KSsSSnnnnSSsSK.....",
    ".....KSSKKKKKKKSSSKDDDO.",
    "....KSSSSSSSSSSSSSSK....",
    "....KSsSSSSSSSSSSsSK....",
    "....KKKKKKKKKKKKKKKK....",
    "...KKTTTTTWWWWTTTTTKK...",
    "..KTTTTTTTWRRWTTTTTTTK..",
    "..KTTTTTTTTRRTTTTTTTTK..",
    ".KTTTTTTTTTRRTTTTTTTTTK.",
    ".KTTTTTOTTTRRTTTOTTTTTK.",
    ".KttTTTTTTTRRTTTTTTTttK.",
    ".KtttttttOOOOOOtttttttK.",
    "...KKPPPPPPPPPPPPPPKK...",
    "....KPPPPPPKKPPPPPPK....",
    "....KBBBBBBK.KBBBBBBK...",
    "....KKKKKKKK.KKKKKKKK...",
]
DEPUTY_PALETTE = {
    "S": "e8a890", "s": "c98070", "H": "6a5a50", "T": "3a2f4a", "t": "2a2038", "R": "c03030",
    "W": "f4f2e8", "O": "e8c030", "n": "e07060", "D": "8a5a30", "P": "2a2038", "B": "1f1a26",
    "N": "8fd0ff", "g": "4aa860",
}
# Sweat and cash (overlay pixels); the second frame moves the sweat and the cigar ember.
DEPUTY_FRAMES = [
    [(3, 5, "N"), (3, 6, "N"), (20, 7, "N"), (20, 8, "N"), (3, 17, "g"), (4, 17, "g"), (3, 18, "g"), (4, 18, "g"), (5, 18, "g"),
     (22, 9, "O")],
    [(3, 6, "N"), (3, 7, "N"), (20, 8, "N"), (20, 9, "N"), (3, 17, "g"), (4, 17, "g"), (3, 18, "g"), (4, 18, "g"), (5, 18, "g"),
     (22, 9, "D")],
]

SPOKESPERSON = [
    "........................",
    "........KKKKKKKK........",
    ".......KLLLLLLLLK.......",
    "......KLLLLLLLLLLK......",
    "......KLLhhLLLLLLK......",
    "......KSSSSSSSSSSK......",
    "......KSEESSSSEESK......",
    "......KSEKSSSSKESK......",
    "......KSSSSnnSSSSK......",
    "......KSSSSSnSSSSK......",
    "......KSKKKKKKKKSK......",
    "......KSKWKWKWKWSK......",
    "......KSSKKKKKKSSK......",
    ".......KKSSSSKK.........",
    "........KKSSKK..........",
    ".....KKVVVVWWVVVVKK.....",
    ".....KVVVVWYYWVVVVK.....",
    ".....KVVVVVYYVVVVVK.....",
    ".....KVvVvVYYVvVvVK.....",
    ".....KVvVvVYYVvVvVK.....",
    ".......KVVVKKVVVK.......",
    ".......KVVVKKVVVK.......",
    ".......KBBBK.KBBBK......",
    ".......KKKKK.KKKKK......",
]
SPOKESPERSON_PALETTE = {
    "S": "f0d0b0", "s": "dba57b", "L": "e8c860", "h": "b89a40", "E": "f4f2e8", "n": "e8a080",
    "W": "f4f2e8", "V": "2a3f7a", "v": "3a529a", "Y": "e8c030", "B": "1f1a26",
    "X": "e8e8f0", "Z": "c03030",
}
MEGAPHONE = [
    (21, 15, "K"), (22, 15, "K"),
    (19, 16, "K"), (20, 16, "X"), (21, 16, "X"), (22, 16, "K"),
    (18, 17, "K"), (19, 17, "X"), (20, 17, "X"), (21, 17, "K"),
    (17, 18, "S"), (18, 18, "K"), (19, 18, "Z"), (20, 18, "K"),
]
SPOKESPERSON_FRAMES = [
    MEGAPHONE,
    MEGAPHONE + [(9, 7, "E"), (8, 7, "K"), (14, 7, "E"), (15, 7, "K")],
]

BOSSES = {
    "deputy_director": (DEPUTY, DEPUTY_PALETTE, DEPUTY_FRAMES),
    "spokesperson": (SPOKESPERSON, SPOKESPERSON_PALETTE, SPOKESPERSON_FRAMES),
}


def make_boss(out, name, rows, colors, frame_overlays):
    assert len(rows) == BOSS and all(len(r) == BOSS for r in rows), name
    palette = dict(PALETTE)
    for key, value in colors.items():
        palette[key] = rgb(value)
    sheet = blank(BOSS * len(frame_overlays), BOSS)
    for index, overlays in enumerate(frame_overlays):
        grid = [list(r) for r in rows]
        for x, y, ch in overlays:
            grid[y][x] = ch
        blit(sheet, [[palette[ch] for ch in row] for row in grid], index * BOSS, 0)
    write_png(out / ("char_%s.png" % name), sheet)


def write_character_info(out):
    info = {"player": {"frame": [CHAR_W, CHAR_H], "columns": 3, "rows": ["down", "up", "left", "right"]}}
    for name in CHARACTERS:
        info[name] = {"frame": [CHAR_W, CHAR_H], "columns": 3, "rows": ["down", "up", "left", "right"]}
    for name in BOSSES:
        info[name] = {"frame": [BOSS, BOSS], "columns": 2, "rows": ["down"]}
    (out / "characters.json").write_text(json.dumps(info, indent=2, sort_keys=True) + "\n")


# --------------------------------------------------------------------- pixel font

# Each glyph: (top_row, [rows of 5 chars]). Rows 1-7 hold capitals and digits,
# rows 3-7 the x-height, rows 8-9 descenders. Baseline sits under row 7.
GLYPHS = {
    "A": (1, [".###.", "#...#", "#...#", "#####", "#...#", "#...#", "#...#"]),
    "B": (1, ["####.", "#...#", "#...#", "####.", "#...#", "#...#", "####."]),
    "C": (1, [".###.", "#...#", "#....", "#....", "#....", "#...#", ".###."]),
    "D": (1, ["####.", "#...#", "#...#", "#...#", "#...#", "#...#", "####."]),
    "E": (1, ["#####", "#....", "#....", "####.", "#....", "#....", "#####"]),
    "F": (1, ["#####", "#....", "#....", "####.", "#....", "#....", "#...."]),
    "G": (1, [".###.", "#...#", "#....", "#.###", "#...#", "#...#", ".###."]),
    "H": (1, ["#...#", "#...#", "#...#", "#####", "#...#", "#...#", "#...#"]),
    "I": (1, [".###.", "..#..", "..#..", "..#..", "..#..", "..#..", ".###."]),
    "J": (1, ["..###", "...#.", "...#.", "...#.", "...#.", "#..#.", ".##.."]),
    "K": (1, ["#...#", "#..#.", "#.#..", "##...", "#.#..", "#..#.", "#...#"]),
    "L": (1, ["#....", "#....", "#....", "#....", "#....", "#....", "#####"]),
    "M": (1, ["#...#", "##.##", "#.#.#", "#.#.#", "#...#", "#...#", "#...#"]),
    "N": (1, ["#...#", "##..#", "#.#.#", "#..##", "#...#", "#...#", "#...#"]),
    "O": (1, [".###.", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."]),
    "P": (1, ["####.", "#...#", "#...#", "####.", "#....", "#....", "#...."]),
    "Q": (1, [".###.", "#...#", "#...#", "#...#", "#.#.#", "#..#.", ".##.#"]),
    "R": (1, ["####.", "#...#", "#...#", "####.", "#.#..", "#..#.", "#...#"]),
    "S": (1, [".####", "#....", "#....", ".###.", "....#", "....#", "####."]),
    "T": (1, ["#####", "..#..", "..#..", "..#..", "..#..", "..#..", "..#.."]),
    "U": (1, ["#...#", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."]),
    "V": (1, ["#...#", "#...#", "#...#", "#...#", "#...#", ".#.#.", "..#.."]),
    "W": (1, ["#...#", "#...#", "#...#", "#.#.#", "#.#.#", "##.##", "#...#"]),
    "X": (1, ["#...#", "#...#", ".#.#.", "..#..", ".#.#.", "#...#", "#...#"]),
    "Y": (1, ["#...#", "#...#", ".#.#.", "..#..", "..#..", "..#..", "..#.."]),
    "Z": (1, ["#####", "....#", "...#.", "..#..", ".#...", "#....", "#####"]),
    "0": (1, [".###.", "#...#", "#..##", "#.#.#", "##..#", "#...#", ".###."]),
    "1": (1, ["..#..", ".##..", "..#..", "..#..", "..#..", "..#..", ".###."]),
    "2": (1, [".###.", "#...#", "....#", "...#.", "..#..", ".#...", "#####"]),
    "3": (1, ["####.", "....#", "....#", ".###.", "....#", "....#", "####."]),
    "4": (1, ["...#.", "..##.", ".#.#.", "#..#.", "#####", "...#.", "...#."]),
    "5": (1, ["#####", "#....", "####.", "....#", "....#", "#...#", ".###."]),
    "6": (1, [".###.", "#....", "#....", "####.", "#...#", "#...#", ".###."]),
    "7": (1, ["#####", "....#", "...#.", "..#..", ".#...", ".#...", ".#..."]),
    "8": (1, [".###.", "#...#", "#...#", ".###.", "#...#", "#...#", ".###."]),
    "9": (1, [".###.", "#...#", "#...#", ".####", "....#", "....#", ".###."]),
    "a": (3, [".###.", "....#", ".####", "#...#", ".####"]),
    "b": (1, ["#....", "#....", "####.", "#...#", "#...#", "#...#", "####."]),
    "c": (3, [".###.", "#...#", "#....", "#...#", ".###."]),
    "d": (1, ["....#", "....#", ".####", "#...#", "#...#", "#...#", ".####"]),
    "e": (3, [".###.", "#...#", "#####", "#....", ".###."]),
    "f": (1, ["..##.", ".#..#", ".#...", "###..", ".#...", ".#...", ".#..."]),
    "g": (3, [".####", "#...#", "#...#", ".####", "....#", "....#", ".###."]),
    "h": (1, ["#....", "#....", "####.", "#...#", "#...#", "#...#", "#...#"]),
    "i": (2, ["..#..", ".....", ".##..", "..#..", "..#..", ".###."]),
    "j": (2, ["...#.", ".....", "..##.", "...#.", "...#.", "...#.", "#..#.", ".##.."]),
    "k": (1, ["#....", "#....", "#..#.", "#.#..", "##...", "#.#..", "#..#."]),
    "l": (1, [".##..", "..#..", "..#..", "..#..", "..#..", "..#..", ".###."]),
    "m": (3, ["##.#.", "#.#.#", "#.#.#", "#.#.#", "#.#.#"]),
    "n": (3, ["####.", "#...#", "#...#", "#...#", "#...#"]),
    "o": (3, [".###.", "#...#", "#...#", "#...#", ".###."]),
    "p": (3, ["####.", "#...#", "#...#", "####.", "#....", "#....", "#...."]),
    "q": (3, [".####", "#...#", "#...#", ".####", "....#", "....#", "....#"]),
    "r": (3, ["#.##.", "##..#", "#....", "#....", "#...."]),
    "s": (3, [".####", "#....", ".###.", "....#", "####."]),
    "t": (2, [".#...", "###..", ".#...", ".#...", ".#..#", "..##."]),
    "u": (3, ["#...#", "#...#", "#...#", "#..##", ".##.#"]),
    "v": (3, ["#...#", "#...#", "#...#", ".#.#.", "..#.."]),
    "w": (3, ["#...#", "#...#", "#.#.#", "#.#.#", ".#.#."]),
    "x": (3, ["#...#", ".#.#.", "..#..", ".#.#.", "#...#"]),
    "y": (3, ["#...#", "#...#", "#...#", ".####", "....#", "....#", ".###."]),
    "z": (3, ["#####", "...#.", "..#..", ".#...", "#####"]),
    ".": (6, [".##..", ".##.."]),
    ",": (7, [".##..", "..#..", ".#..."]),
    "!": (1, ["..#..", "..#..", "..#..", "..#..", "..#..", ".....", "..#.."]),
    "?": (1, [".###.", "#...#", "....#", "...#.", "..#..", ".....", "..#.."]),
    "'": (1, ["..#..", "..#..", ".#..."]),
    '"': (1, [".#.#.", ".#.#.", ".#.#."]),
    ":": (3, ["..#..", ".....", ".....", "..#.."]),
    ";": (3, ["..#..", ".....", ".....", "..#..", ".#..."]),
    "-": (5, [".###."]),
    "+": (3, ["..#..", "..#..", "#####", "..#..", "..#.."]),
    "=": (4, ["#####", ".....", "#####"]),
    "(": (1, ["...#.", "..#..", "..#..", "..#..", "..#..", "..#..", "...#."]),
    ")": (1, [".#...", "..#..", "..#..", "..#..", "..#..", "..#..", ".#..."]),
    "/": (1, ["....#", "....#", "...#.", "..#..", ".#...", "#....", "#...."]),
    "%": (1, ["##..#", "##..#", "...#.", "..#..", ".#...", "#..##", "#..##"]),
    "#": (1, [".#.#.", ".#.#.", "#####", ".#.#.", "#####", ".#.#.", ".#.#."]),
    "&": (1, [".##..", "#..#.", "#.#..", ".#...", "#.#.#", "#..#.", ".##.#"]),
    "*": (2, ["#.#.#", ".###.", "#####", ".###.", "#.#.#"]),
    "<": (2, ["...#.", "..#..", ".#...", "..#..", "...#."]),
    ">": (2, [".#...", "..#..", "...#.", "..#..", ".#..."]),
    "_": (9, ["#####"]),
    "[": (1, [".###.", ".#...", ".#...", ".#...", ".#...", ".#...", ".###."]),
    "]": (1, [".###.", "...#.", "...#.", "...#.", "...#.", "...#.", ".###."]),
    "▶": (1, ["#....", "##...", "###..", "####.", "###..", "##...", "#...."]),
    "▼": (3, ["#####", ".###.", "..#.."]),
}
SPACE_ADVANCE = 3
FONT_LINE_HEIGHT = 11
FONT_BASE = 8
GLYPH_CELL_H = 10


def make_font(out):
    cell_w, cell_h = 7, GLYPH_CELL_H + 1
    per_row = 18
    chars = sorted(GLYPHS)
    rows_needed = (len(chars) + per_row - 1) // per_row
    sheet = blank(per_row * cell_w, rows_needed * cell_h)
    white = (255, 255, 255, 255)
    lines = []
    for n, ch in enumerate(chars):
        top, rows = GLYPHS[ch]
        left = min(r.index("#") for r in rows if "#" in r)
        right = max(len(r.rstrip(".")) for r in rows)
        width = right - left
        cx, cy = (n % per_row) * cell_w, (n // per_row) * cell_h
        for ry, row in enumerate(rows):
            for rx in range(left, right):
                if row[rx] == "#":
                    sheet[cy + top + ry][cx + rx - left] = white
        lines.append((ord(ch), cx, cy, width, GLYPH_CELL_H, 0, 0, width + 1))
    write_png(out / "font_pixel.png", sheet)
    fnt = ["info face=\"PixelFont\" size=10 bold=0 italic=0 charset=\"\" unicode=1 stretchH=100 smooth=0 aa=1 padding=0,0,0,0 spacing=0,0 outline=0",
           "common lineHeight=%d base=%d scaleW=%d scaleH=%d pages=1 packed=0" % (FONT_LINE_HEIGHT, FONT_BASE, len(sheet[0]), len(sheet)),
           "page id=0 file=\"font_pixel.png\"",
           "chars count=%d" % (len(lines) + 1)]
    for cid, x, y, w, h, xo, yo, adv in lines:
        fnt.append("char id=%d x=%d y=%d width=%d height=%d xoffset=%d yoffset=%d xadvance=%d page=0 chnl=15" % (cid, x, y, w, h, xo, yo, adv))
    fnt.append("char id=32 x=0 y=0 width=0 height=0 xoffset=0 yoffset=0 xadvance=%d page=0 chnl=15" % SPACE_ADVANCE)
    (out / "font_pixel.fnt").write_text("\n".join(fnt) + "\n")


# ------------------------------------------------------------------------ icons

ICON = 16
ICON_ORDER = ["ledger_page", "meeting_photo", "text_messages", "original_statement", "bot_list", "edited_clip"]
DARK = rgb("3c281c")


def _fill(img, x0, y0, x1, y1, color):
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            img[y][x] = color


def _outline(img, x0, y0, x1, y1, color):
    for x in range(x0, x1 + 1):
        img[y0][x] = color
        img[y1][x] = color
    for y in range(y0, y1 + 1):
        img[y][x0] = color
        img[y][x1] = color


def icon_ledger():
    t = blank(ICON, ICON)
    _fill(t, 3, 1, 12, 14, rgb("f2efe4"))
    _outline(t, 3, 1, 12, 14, DARK)
    for y in range(2, 14):
        t[y][5] = rgb("c03030")
    for y in (4, 6, 8, 10, 12):
        for x in range(6, 12):
            t[y][x] = rgb("9a98a0")
    return t


def icon_photo():
    t = blank(ICON, ICON)
    _fill(t, 1, 2, 14, 13, rgb("8a6038"))
    _outline(t, 1, 2, 14, 13, DARK)
    _fill(t, 3, 4, 12, 11, rgb("8fd0ff"))
    _fill(t, 3, 10, 12, 11, rgb("4aa860"))
    _fill(t, 5, 5, 6, 6, rgb("2b2233"))
    _fill(t, 4, 7, 7, 11, rgb("3a4a7a"))
    _fill(t, 9, 5, 10, 6, rgb("2b2233"))
    _fill(t, 8, 7, 11, 11, rgb("7a3a3a"))
    return t


def icon_phone():
    t = blank(ICON, ICON)
    _fill(t, 4, 1, 11, 14, rgb("2b2233"))
    _fill(t, 5, 3, 10, 12, rgb("dff5ff"))
    _fill(t, 6, 4, 9, 6, rgb("4aa860"))
    _fill(t, 6, 8, 9, 10, rgb("b8c4d8"))
    t[13][7] = rgb("8a8a94")
    t[13][8] = rgb("8a8a94")
    return t


def icon_statement():
    t = blank(ICON, ICON)
    _fill(t, 3, 1, 12, 14, rgb("f4f2e8"))
    _outline(t, 3, 1, 12, 14, DARK)
    _fill(t, 5, 3, 10, 3, rgb("2b2233"))
    for y in (5, 7):
        for x in range(5, 11):
            t[y][x] = rgb("9a98a0")
    _fill(t, 8, 9, 11, 12, rgb("c03030"))
    t[13][9] = rgb("7a1c1c")
    t[13][10] = rgb("7a1c1c")
    return t


def icon_bots():
    t = blank(ICON, ICON)
    _fill(t, 3, 2, 12, 14, rgb("8a6038"))
    _outline(t, 3, 2, 12, 14, DARK)
    _fill(t, 4, 4, 11, 13, rgb("f2efe4"))
    _fill(t, 6, 1, 9, 3, rgb("8a8a94"))
    _outline(t, 6, 1, 9, 3, DARK)
    _fill(t, 5, 5, 9, 8, rgb("8fd0ff"))
    _outline(t, 5, 5, 9, 8, rgb("2b2233"))
    t[6][6] = rgb("2b2233")
    t[6][8] = rgb("2b2233")
    t[8][7] = rgb("2b2233")
    for y in (10, 12):
        for x in range(5, 11):
            t[y][x] = rgb("9a98a0")
    return t


def icon_clip():
    t = blank(ICON, ICON)
    _fill(t, 1, 3, 14, 12, rgb("2b2233"))
    for x in (2, 4, 6, 8, 10, 12):
        t[4][x] = rgb("d8d8e8")
        t[11][x] = rgb("d8d8e8")
    _fill(t, 3, 6, 7, 9, rgb("5a6a8a"))
    _fill(t, 9, 6, 12, 9, rgb("5a6a8a"))
    for x, y in ((4, 6), (4, 7), (4, 8), (5, 7)):
        t[y][x] = rgb("f4f2e8")
    for y in range(5, 11):
        t[y][8] = rgb("c03030")
    return t


ICON_MAKERS = [icon_ledger, icon_photo, icon_phone, icon_statement, icon_bots, icon_clip]


def make_icons(out):
    atlas = blank(ICON * len(ICON_MAKERS), ICON)
    index = {}
    for i, (evidence_id, make) in enumerate(zip(ICON_ORDER, ICON_MAKERS)):
        blit(atlas, make(), i * ICON, 0)
        index[evidence_id] = i
    write_png(out / "icons.png", atlas)
    (out / "icons.json").write_text(json.dumps({"icon_size": ICON, "icons": index}, indent=2) + "\n")


# -------------------------------------------------------------------------- main

def main():
    out = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parents[2] / "assets" / "art"
    out.mkdir(parents=True, exist_ok=True)
    make_tiles(out)
    for name, spec in CHARACTERS.items():
        make_character(out, name, spec)
    for name, (rows, colors, frames) in BOSSES.items():
        make_boss(out, name, rows, colors, frames)
    write_character_info(out)
    make_icons(out)
    make_font(out)
    print("wrote art to", out)


if __name__ == "__main__":
    main()
