# Overworld Tileset Catalog and Placement Rules

**Repository:** `salexume94-pixel/cubed-souls`  
**Canonical branch:** `main`  
**Source folder:** `assets/tilesets/overworld/`  
**Status:** Source sheets inspected visually; per-cell classifications and Godot runtime rendering are not yet verified.

This document is the reference point for anyone editing the overworld map. It exists to prevent guessing atlas coordinates, confusing flora with ground, and assembling incomplete trees or props.

## Source files and coordinate system

| Godot TileSet source ID | Image | Dimensions | 16×16 grid |
|---:|---|---:|---:|
| 0 | `exterior.png` | 240×800 px | 15 columns × 50 rows |
| 1 | `ground_grass_details.png` | 336×288 px | 21 columns × 18 rows |

- Both images align to a 16×16 pixel grid. Coordinates are zero-based: `(x, y)`, where `x` is the column and `y` is the row.
- Godot's source IDs are defined by `assets/tilesets/overworld/background.tres`. Do not assume an image's filename or coordinate alone tells you its gameplay role.
- Generate coordinate-labelled references with `python tools/generate_tileset_reference.py`. The script reads the source PNGs directly from the repository and writes enlarged, labelled SVG files to `docs/tileset_reference/generated/`. Open the SVG files in a browser; they reference the original PNGs with relative paths.
- These reference sheets are inspection aids, not game assets. Do not import them into the TileSet.

## Classification vocabulary

Classify each usable tile or multi-cell sprite before placing it.

| Class | Meaning | Correct layer/use |
|---|---|---|
| **Ground surface** | A seamless, opaque tile intended to cover every walkable ground cell, such as plain green grass. | `Ground`; repeat across the field only after the exact tile is visually confirmed. |
| **Flora / ground detail** | Small tufts, flowers, tiny stones, leaf litter, and similar accents that sit on top of the ground. | `Details`; sparse decoration, never a substitute for the base ground. |
| **Terrain / prop** | Trees, large bushes, rocks, stumps, mushrooms, fences, walls, buildings, fountains, and other substantial objects. | `Objects`; place the complete sprite or a verified set of connected cells. Add collision where required. |
| **Foreground piece** | Canopy, branches, roof/front sections, or other art meant to draw in front of the player. | `Foreground`; only when the source art is designed to overlap the player. |
| **Unknown / component** | A partial sprite, transparent fragment, animation frame, or cell whose intended use is unclear. | Do not place in the map until identified. |

### Visual observations from the actual sheets

- `exterior.png` is a transparent prop sheet. It visibly includes a building, fence/wall sections, rocks, bushes, trees, stumps, mushrooms, plants, and fountain-like objects. It is **not** a seamless full-field grass texture.
- `ground_grass_details.png` is a transparent detail sheet. It contains small earth/stone-like accents and green grass/plant tufts. It is **not** a seamless full-field grass texture.
- These are broad sheet-level observations, not a claim that every 16×16 cell has been individually classified. A large prop may span multiple cells, so isolated atlas cells can be incomplete fragments.

**Base grass confirmed by the user:** source ID `0`, `exterior.png`, atlas coordinate `(1, 12)`. This cell is the project's chosen ground base. The map builder currently repeats it across a 64×40-cell field. Other prop/path coordinates remain unverified and must not be guessed.

## Required placement workflow

1. **Inspect before editing.** Read `background.tres`, both PNG dimensions, and the current scene. Never infer a tile's appearance from its atlas coordinate.
2. **Generate references.** Run:
   ```powershell
   python tools/generate_tileset_reference.py
   ```
   Open both generated images and use the printed `(x, y)` labels to identify exact source cells.
3. **Record classifications.** Before use, add the coordinate or multi-cell rectangle, visual description, class, intended layer, and confidence to the table below. Use `Unverified` rather than guessing.
4. **Build the base first.** Fill `Ground` only with a visually confirmed, seamless ground tile. It must not be a flower, tuft, rock, or transparent prop.
5. **Add details second.** Scatter verified flora/ground-detail sprites sparingly over the base. Keep the player spawn and paths readable.
6. **Assemble props as complete art.** Use the full source region for multi-cell trees, rocks, buildings, and similar props. Do not place a few arbitrary 16×16 fragments and call them a complete tree. Confirm transparency and bounds in the labelled sheet.
7. **Use the existing layers.** Preserve `Ground`, `Details`, `Objects`, and `Foreground` in `world/maps/overworld/world.tscn`. Do not replace them with `Polygon2D`, hand-drawn geometry, or guessed regions.
8. **Verify in Godot.** Inspect the scene in the editor before running it, then check full sprite boundaries, draw order, collisions, paths, player spawn, and debugger output. Record local runtime results separately; a GitHub commit is not runtime verification.
9. **Log changes.** Append a dated entry to `docs/DEVELOPMENT_LOG.md`. Never rewrite or remove history.

## Tile classification register

Only add entries after visually checking the generated reference image. A multi-cell object should be recorded as a region, not mislabelled as a single-cell tile.

| Source | Coordinate / region | Description | Class | Layer | Confidence / notes |
|---|---|---|---|---|---|
| 0 — `exterior.png` | `(1, 12)` | User-confirmed base grass cell | Ground surface | Ground | **Coordinate confirmed by user; Godot rendering pending** |
| 1 — `ground_grass_details.png` | TBD | Small green grass/plant accents | Flora / ground detail | Details | Sheet-level observation; exact cells TBD |
| 0 — `exterior.png` | TBD | Trees, rocks, buildings, fences, and other large props | Terrain / prop | Objects / Foreground | Sheet-level observation; record each region before placement |

## Guardrails for future agents

- Do not select atlas coordinates by intuition or because a tile is registered in `background.tres`.
- A registered TileSet cell is not proof that it is a complete object or the correct ground texture.
- Do not replace or remove the four existing `TileMapLayer` nodes.
- Do not use `Polygon2D` as a shortcut for missing tile art.
- Do not claim a visual inspection, successful render, or runtime verification unless it actually occurred.
- If the needed base-grass tile is absent from the specified assets, stop and document the missing asset rather than fabricating one from unrelated art.

## Related files

- [TileSet resource](../assets/tilesets/overworld/background.tres)
- [Overworld scene](../world/maps/overworld/world.tscn)
- [Overworld script](../world/maps/overworld/world.gd)
- [Repository audit](AUDIT.md)
- [Architecture guide](ARCHITECTURE.md)
- [Development log](DEVELOPMENT_LOG.md)
