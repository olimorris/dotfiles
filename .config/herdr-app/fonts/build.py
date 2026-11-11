"""Build "OperatorMono Tall": OperatorMono Nerd Font with Medium as its regular
weight and extra line height, because Herdr has no font weight or line height
setting and sizes terminal rows from the font's ascent and descent.

    uvx --from fonttools python -I build.py [extra_em]

Writes to misc/ui/fonts; run `rake install:fonts` to install them.

extra_em is the space added to every row, as a fraction of the font size
(default 0.5, which matches Ghostty's `adjust-cell-height = 21` at size 21).
"""

import sys
from pathlib import Path

from fontTools.ttLib import TTFont

FAMILY = "OperatorMono Tall"
FONTS = Path.home() / ".dotfiles/misc/ui/fonts"
STYLES = {
    "Medium": ("Regular", 400),
    "MediumItalic": ("Italic", 400),
    "Bold": ("Bold", 700),
    "BoldItalic": ("Bold Italic", 700),
}

extra_em = float(sys.argv[1]) if len(sys.argv) > 1 else 0.5

for source_style, (style, weight) in STYLES.items():
    font = TTFont(FONTS / f"OperatorMonoNerdFont-{source_style}.otf")
    upm = font["head"].unitsPerEm
    # Split evenly so the text stays centred in the taller row, as in Ghostty
    half = round(extra_em * upm / 2)

    hhea, os2 = font["hhea"], font["OS/2"]
    hhea.ascent += half
    hhea.descent -= half
    os2.sTypoAscender += half
    os2.sTypoDescender -= half
    os2.usWinAscent += half
    os2.usWinDescent += half

    bold, italic = "Bold" in style, "Italic" in style
    os2.usWeightClass = weight
    os2.fsSelection &= ~0b1100001
    os2.fsSelection |= (italic and 0b1) | (bold and 0b100000) | (not (bold or italic) and 0b1000000)
    font["head"].macStyle = (bold and 0b1) | (italic and 0b10)

    postscript = f"{FAMILY.replace(' ', '')}-{style.replace(' ', '')}"
    full = FAMILY if style == "Regular" else f"{FAMILY} {style}"
    names = font["name"]
    for name_id in (16, 17):
        names.removeNames(nameID=name_id)
    for name_id, value in {1: FAMILY, 2: style, 3: postscript, 4: full, 6: postscript}.items():
        names.setName(value, name_id, 3, 1, 0x409)
        names.setName(value, name_id, 1, 0, 0)

    font.save(FONTS / f"{postscript}.otf")
    print(f"{postscript}.otf")
