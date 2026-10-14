#!/usr/bin/env python3
"""Create coordinate-labelled inspection sheets for the overworld PNG tilesets.

Each source image is enlarged with nearest-neighbour scaling, shown over a
checkerboard so transparent pixels remain visible, and labelled with its
zero-based 16x16 atlas coordinate. These images are documentation aids only;
they are not intended to be imported as Godot game assets.
"""

from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "assets" / "tilesets" / "overworld"
OUTPUT_DIR = ROOT / "docs" / "tileset_reference" / "generated"
TILE_SIZE = 16
SCALE = 4
CELL = TILE_SIZE * SCALE
CHECKER = 8 * SCALE

SHEETS = (
    ("exterior.png", "exterior_labeled.png"),
    ("ground_grass_details.png", "ground_grass_details_labeled.png"),
)


def checkerboard(width: int, height: int) -> Image.Image:
    """Make a neutral checkerboard to reveal transparent sprite pixels."""
    image = Image.new("RGBA", (width, height), (38, 38, 38, 255))
    draw = ImageDraw.Draw(image)
    light = (62, 62, 62, 255)
    for y in range(0, height, CHECKER):
        for x in range(0, width, CHECKER):
            if (x // CHECKER + y // CHECKER) % 2 == 0:
                draw.rectangle((x, y, x + CHECKER - 1, y + CHECKER - 1), fill=light)
    return image


def load_font(size: int):
    """Use a standard font when available, falling back to Pillow's bitmap font."""
    try:
        return ImageFont.truetype("DejaVuSans.ttf", size)
    except OSError:
        return ImageFont.load_default()


def render_sheet(source_name: str, output_name: str) -> None:
    """Render one PNG with tile boundaries and (column, row) labels."""
    source_path = SOURCE_DIR / source_name
    if not source_path.is_file():
        raise FileNotFoundError(f"Required source image not found: {source_path}")

    source = Image.open(source_path).convert("RGBA")
    if source.width % TILE_SIZE or source.height % TILE_SIZE:
        raise ValueError(
            f"{source_name} is {source.width}x{source.height}; dimensions must "
            f"be divisible by {TILE_SIZE} for this 16x16 atlas workflow."
        )

    columns = source.width // TILE_SIZE
    rows = source.height // TILE_SIZE
    scaled = source.resize((source.width * SCALE, source.height * SCALE), Image.Resampling.NEAREST)
    background = checkerboard(scaled.width, scaled.height)
    background.alpha_composite(scaled)

    draw = ImageDraw.Draw(background)
    font = load_font(11)
    for row in range(rows):
        for column in range(columns):
            x0, y0 = column * CELL, row * CELL
            x1, y1 = x0 + CELL - 1, y0 + CELL - 1
            # Thin grid lines distinguish cell boundaries without hiding the art.
            draw.rectangle((x0, y0, x1, y1), outline=(230, 230, 230, 210), width=1)
            label = f"{column},{row}"
            bounds = draw.textbbox((0, 0), label, font=font)
            label_width = bounds[2] - bounds[0]
            label_height = bounds[3] - bounds[1]
            pad = 2
            # Put the label in a dark corner plate so it remains readable on foliage.
            plate = (
                x0 + 1,
                y0 + 1,
                min(x0 + label_width + pad * 2 + 1, x1),
                min(y0 + label_height + pad * 2 + 1, y1),
            )
            draw.rectangle(plate, fill=(0, 0, 0, 205))
            draw.text((x0 + pad + 1, y0 + pad), label, font=font, fill=(255, 255, 255, 255))

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    output_path = OUTPUT_DIR / output_name
    background.convert("RGB").save(output_path, optimize=True)
    print(f"{source_name}: {columns} columns x {rows} rows -> {output_path}")


def main() -> None:
    """Generate both reference sheets from the repository's current source PNGs."""
    for source_name, output_name in SHEETS:
        render_sheet(source_name, output_name)


if __name__ == "__main__":
    main()
