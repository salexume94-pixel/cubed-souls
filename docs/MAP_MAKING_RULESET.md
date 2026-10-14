# Map-Making Ruleset and SVG Tileset Reference

## Purpose and sources of truth

Use three sources together:
- **This Markdown file** defines asset names, categories, grouped source coordinates, and map-making rules.
- **The labeled SVG** is the visual source of truth for each tile's appearance and arrangement.
- **The Godot project** is the source of truth for atlas configuration, TileMapLayer setup, scene structure, and implementation details.

If these sources disagree, report the mismatch and resolve it before placement.

## 1. Asset identification

- When asked to place an asset, find its name here and locate its coordinates in the SVG.
- Verify its appearance and arrangement against the SVG.
- Never substitute a similar-looking tile, invent or redraw assets, or complete missing parts.
- If an asset cannot be confidently identified, report the ambiguity instead of guessing.
- Add newly identified assets using the same catalog format.

## 2. Coordinate mapping

- Coordinates in this catalog use `(column, row)`.
- Verify whether the SVG coordinates are zero-based or one-based.
- Determine the mapping from SVG coordinates to Godot atlas coordinates using the actual tileset resource and project configuration. Do not assume the coordinate systems match.
- Preserve documented coordinates. Flag suspected errors instead of silently correcting them.

## 3. Bundled assets

- Multiple coordinates grouped under one asset name represent **one bundled asset** and must be placed together.
- Preserve the bundle's arrangement, dimensions, and orientation. Do not split bundles into independent tiles unless explicitly instructed.
- Derive dimensions from the coordinate span and verify them against the SVG.
- Example: coordinates spanning columns 0–2 and rows 38–40 describe a 3 × 3 bundle if confirmed visually.
- Source atlas coordinates identify the asset; they are not its destination coordinates on the map.

## 4. Map layers

- **Ground:** Base terrain only.
- **Details:** Small, non-blocking decoration.
- **Objects:** World features such as rocks, trees, and bushes. Collision and interaction are handled separately where needed.
- **Foreground:** Parts of scenery that must render over the player.

Avoid canopy layering and foreground rendering unless explicitly requested. Foreground can remain unused until a map actually needs it.

## 5. Placement and gameplay

- Use the identified source tiles to construct the requested map and place every bundle in its complete arrangement.
- Position objects appropriately while preserving paths, entrances, and usable space.
- Visual category does not automatically determine collision or interaction. Configure those separately where applicable.
- Keep collision shapes appropriate to the actual object; do not block empty space just because it falls inside a sprite's footprint.
- Preserve existing gameplay logic, TileMapLayer nodes, scene components, and project conventions unless a change is necessary and authorized.
- Use the actual assets. Do not use Polygon2D, improvised graphics, or placeholder scenery as substitutes.

## 6. Verification

Before placement:
1. Find the asset in this catalog.
2. Confirm its appearance and grouped tiles in the SVG.
3. Verify atlas-coordinate mapping and the target map's structure.

After placement:
- Check for incorrect coordinates, missing bundle tiles, broken arrangements, unintended gaps or overlaps, and inappropriate collisions.
- Distinguish proposed changes from implemented changes.
- Do not claim runtime verification until the map has been run and tested in Godot.
- State what remains unverified.

---

# Tileset Catalog

## `exterior_labeled.svg`

### Ground

| Coordinates | Asset |
|---|---|
| `(1,12)` | Grass |

### Details

| Coordinates | Asset |
|---|---|
| `(14,34)` | Grass leaf |
| `(10,37)` | Grass leaf |
| `(10,38)` | Grass leaf |
| `(13,39)` | Grass leaf |
| `(14,39)` | Flower |
| `(8,41)` | Flower |
| `(14,42)` | Flower |
| `(14,43)` | Flower |
| `(14,44)` | Flower |
| `(9,47)` | Flower |
| `(10,47)` | Grass leaf |
| `(8,48) + (8,49)` | Vertical grass leaf bundle |
| `(9,48) + (9,49)` | Vertical flower bundle |
| `(11,49) + (12,49)` | Horizontal grass leaf bundle |
| `(10,48)` | Flower |
| `(10,49)` | Grass leaf |
| `(11,48)` | Flower |
| `(12,47)` | Grass leaf |
| `(13,48)` | Grass leaf |
| `(13,49)` | Grass leaf |
| `(14,49)` | Flower |

### Objects

| Coordinates | Asset |
|---|---|
| `(9,7)` | Rocks |
| `(10,7)` | Rocks |
| `(11,7)` | Rocks |
| `(12,7)` | Rocks |
| `(13,7)` | Rocks |
| `(0,25) + (1,25) + (2,25) + (0,26) + (1,26) + (2,26) + (0,27) + (1,27) + (2,27)` | Large square rock bundle (3 × 3) |
| `(3,25) + (4,25) + (3,26) + (4,26)` | Medium square rock bundle (2 × 2) |
| `(5,25) + (6,25) + (5,26) + (6,26)` | Medium square rock bundle (2 × 2) |
| `(7,25) + (8,25) + (7,26) + (8,26)` | Medium square rock bundle (2 × 2) |
| `(9,25) + (10,25) + (9,26) + (10,26)` | Medium square rock bundle (2 × 2) |
| `(11,25) + (12,25) + (11,26) + (12,26)` | Medium square rock bundle (2 × 2) |
| `(9,27) + (10,27) + (9,28) + (10,28)` | Medium square rock bundle (2 × 2) |
| `(11,27) + (12,27) + (11,28) + (12,28)` | Medium square rock bundle (2 × 2) |
| `(13,45) + (14,45) + (13,46) + (14,46) + (13,47) + (14,47)` | Vertical rock pillar bundle (2 × 3) |
| `(4,48) + (5,48) + (4,49) + (5,49)` | Square rock pillar bundle (2 × 2) |
| `(0,38) + (1,38) + (2,38) + (0,39) + (1,39) + (2,39) + (0,40) + (1,40) + (2,40)` | Vertical evergreen tree bundle (3 × 3) |
| `(3,39) + (4,39) + (3,40) + (4,40)` | Square evergreen tree bundle (2 × 2) |
| `(14,14)` | Small bush |
| `(13,15) + (14,15) + (13,16) + (14,16)` | Square bush bundle (2 × 2) |
| `(10,18) + (11,18) + (10,19) + (11,19)` | Medium square bush bundle (2 × 2) |

### Foreground

No assets documented yet. Leave this category unused unless a map explicitly requires scenery to render over the player.

## Catalog maintenance notes

- These coordinates are transcribed from the working catalog and must be visually checked against `exterior_labeled.svg` and the Godot atlas configuration before use.
- Repeated asset names at different coordinates are separate atlas entries. Keep them distinct unless the SVG confirms they are duplicates.
- Document destination map coordinates separately from source atlas coordinates when planning a specific map.
