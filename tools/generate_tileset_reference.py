#!/usr/bin/env python3
"""Generate self-contained SVG coordinate atlases for project PNG tilesets.

Uses only Python's standard library. The SVGs embed each original PNG as base64,
enlarge it with pixelated rendering, and overlay 16x16 cell boundaries and
zero-based (column, row) labels. These files are inspection aids, not game assets.
"""

from pathlib import Path
from html import escape
from base64 import b64encode

ROOT = Path(__file__).resolve().parents[1]
TILESET_DIR = ROOT / "assets" / "tilesets"
OUTPUT_DIR = ROOT / "docs" / "tileset_reference" / "generated"
TILE_SIZE = 16
SCALE = 4
CELL = TILE_SIZE * SCALE

SHEETS = (
    ("overworld/exterior.png", "overworld_exterior_labeled.svg"),
    ("overworld/exterior.png", "town_exterior_labeled.svg"),
    ("overworld/ground_grass_details.png", "ground_grass_details_labeled.svg"),
    # The exterior atlas contains 32 extra pixels at the bottom of the source PNG.
    # Crop the reference viewport to the intended 256x304 atlas without altering the source asset.
    ("towns/chapels/Exterior.png", "chapel_exterior_labeled.svg", 304),
    ("towns/chapels/Walls_Interior.png", "chapel_walls_interior_labeled.svg", None),
    ("towns/towns/house_details.png", "house_details_labeled.svg"),
    ("towns/towns/walls_floor.png", "walls_floor_labeled.svg"),
    ("dungeons/ruined_temple/Exterior_objects.png", "ruined_temple_exterior_objects_labeled.svg"),
)


def render_sheet(source_relative_path: str, output_name: str, reference_height: int | None = None) -> None:
    """Write one self-contained SVG atlas with a grid and coordinate labels."""
    source_path = TILESET_DIR / source_relative_path
    source_name = Path(source_relative_path).name
    if not source_path.is_file():
        raise FileNotFoundError(f"Required source image not found: {source_path}")

    # PNG dimensions are read from the standard IHDR header, avoiding imaging packages.
    with source_path.open("rb") as image_file:
        header = image_file.read(24)
    if header[:8] != b"\x89PNG\r\n\x1a\n" or header[12:16] != b"IHDR":
        raise ValueError(f"{source_name} is not a valid PNG file.")
    width = int.from_bytes(header[16:20], "big")
    height = int.from_bytes(header[20:24], "big")
    if width % TILE_SIZE or height % TILE_SIZE:
        raise ValueError(
            f"{source_name} is {width}x{height}; dimensions must be divisible "
            f"by {TILE_SIZE} for this 16x16 atlas workflow."
        )
    # Some references intentionally show only a source-image region. Keep the
    # image at native scale and clip it with the SVG viewport instead of stretching it.
    display_height = height if reference_height is None else reference_height
    if display_height <= 0 or display_height > height or display_height % TILE_SIZE:
        raise ValueError(
            f"{output_name} display height {display_height} must be a positive "
            f"multiple of {TILE_SIZE} and no greater than source height {height}."
        )

    columns = width // TILE_SIZE
    rows = display_height // TILE_SIZE
    scaled_width = width * SCALE
    scaled_height = display_height * SCALE
    source_scaled_height = height * SCALE
    # Embed the source PNG so the reference works in GitHub previews and when the
    # SVG is opened or moved independently. Relative SVG image links often break
    # in repository viewers even when their paths are correct.
    image_data = b64encode(source_path.read_bytes()).decode("ascii")
    image_href = f"data:image/png;base64,{image_data}"

    svg = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{scaled_width}" height="{scaled_height}" viewBox="0 0 {scaled_width} {scaled_height}">',
        f'<title>{escape(output_name.removesuffix("_labeled.svg").replace("_", " ").title())} tileset reference</title>',
        '<defs><pattern id="checker" width="32" height="32" patternUnits="userSpaceOnUse">',
        '<rect width="32" height="32" fill="#262626"/>',
        '<rect width="16" height="16" fill="#3e3e3e"/>',
        '<rect x="16" y="16" width="16" height="16" fill="#3e3e3e"/>',
        '</pattern></defs>',
        f'<rect width="{scaled_width}" height="{scaled_height}" fill="url(#checker)"/>',
        f'<image href="{escape(image_href, quote=True)}" x="0" y="0" width="{scaled_width}" height="{source_scaled_height}" preserveAspectRatio="none" image-rendering="pixelated"/>',
    ]

    # Draw grid and compact coordinate labels on every source cell.
    for row in range(rows):
        for column in range(columns):
            x = column * CELL
            y = row * CELL
            svg.append(
                f'<rect x="{x + 0.5}" y="{y + 0.5}" width="{CELL - 1}" '
                f'height="{CELL - 1}" fill="none" stroke="#eeeeee" '
                'stroke-opacity="0.58" stroke-width="1"/>'
            )
            label = f"{column},{row}"
            svg.append(
                f'<rect x="{x + 1}" y="{y + 1}" width="25" height="13" '
                'rx="1" fill="#000000" fill-opacity="0.82"/>'
            )
            svg.append(
                f'<text x="{x + 3}" y="{y + 11}" font-family="monospace" '
                f'font-size="10" fill="#ffffff">{label}</text>'
            )

    svg.append("</svg>")
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    output_path = OUTPUT_DIR / output_name
    output_path.write_text("\n".join(svg) + "\n", encoding="utf-8")
    print(f"{source_name}: {columns} columns x {rows} rows -> {output_path}")


def main() -> None:
    """Generate overworld, town, chapel, and ruined-temple tile references."""
    for sheet in SHEETS:
        source_name, output_name = sheet[0], sheet[1]
        reference_height = sheet[2] if len(sheet) > 2 else None
        render_sheet(source_name, output_name, reference_height)


if __name__ == "__main__":
    main()
