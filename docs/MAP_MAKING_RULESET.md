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

- **Ground:** Base terrain and walkable floor surfaces. Individual floor variants may be placed separately across a room to create visual variation.
- **Details:** Small, non-blocking decoration.
- **Objects:** World features and structures, including rocks, trees, bushes, complete buildings, stone walls, and doors. Buildings, walls, and doors belong on this layer, not in a separate decorative layer. Every placed object needs collision appropriate to its role.
- **Foreground:** Scenery that must render over the player or over another object. A window sprite intended to sit visually on top of a wall belongs on this layer, not Details. Keep transparent openings in the window transparent so the wall/window composition looks correct.

Foreground layering is intentional when an asset must overlap the player or another structure. Do not add canopy layering or foreground art without a reason established by the asset and map design.

## 5. Placement and gameplay

- Use the identified source tiles to construct the requested map and place every bundle in its complete arrangement.
- Position objects appropriately while preserving paths, entrances, and usable space.
- **Every placed world object must have collision.** Do not assume the `Objects` layer or the sprite itself automatically blocks movement. This includes complete house/building bundles and door bundles placed on `Objects`.
- **Building collision:** A complete house/building is one bundled `Objects`-layer asset. Add collision to its solid/opaque structure so the player cannot walk through the building.
- **Door transition collision:** A door is also placed on `Objects` and needs collision. Its scene-transition interaction must use a dedicated transition trigger/collision area at the doorway, separate from the building's ordinary blocking collision. The trigger should activate the intended scene transition without making the surrounding building passable.
- Trees, rocks, bushes, and building structures block movement where their sprite pixels are visibly opaque. **Transparent pixels within any object's texture must remain passable**, including gaps inside canopies, branches, bush silhouettes, and building artwork. Do not leave opaque parts of an `Objects`-layer asset passable by default. Doorway transition triggers are a separate interaction layer of collision and do not replace the building's solid collision.
- Derive collision automatically from each placed asset's actual alpha channel rather than using the full tile-bundle rectangle. Merge adjacent opaque pixel runs into larger rectangles to keep physics shape counts practical. Ignore pixels with alpha at or below 0.05 to filter effectively transparent edges.
- Generate default object colliders in both the editor and at runtime under `GeneratedObjectCollisions`, with editor scene ownership so `StaticBody2D` and `CollisionShape2D` nodes are visible and selectable in the 2D editor. Generate this container only when it does not already exist. Never automatically delete or rebuild an existing container: users may have manually adjusted its shapes and saved those changes into the scene. To intentionally discard adjustments and regenerate defaults, delete `GeneratedObjectCollisions` in the editor and let the tool script recreate it. After adjusting collision shapes, save `world.tscn` so the adjustments are serialized.
- Use the project's established collision layers and masks; verify opaque tree canopy, trunk, rock, bush, and building pixels block movement while visible transparent gaps remain walkable. Verify each door's dedicated scene-transition trigger independently from ordinary blocking collision.
- For generated maps, generate matching collision bodies deterministically from the same object-placement definitions. Avoid duplicated or stale colliders when rebuilding the map. `Ground` and decorative `Details` are separate layers; this rule applies to every asset placed on `Objects`.
- Preserve existing gameplay logic, TileMapLayer nodes, scene components, and project conventions unless a change is necessary and authorized.
- Use the actual assets. Do not use Polygon2D, improvised graphics, or placeholder scenery as substitutes.

## 6. Verification

Before placement:
1. Find the asset in this catalog.
2. Confirm its appearance and grouped tiles in the SVG.
3. Verify atlas-coordinate mapping and the target map's structure.

After placement:
- Check for incorrect coordinates, missing bundle tiles, broken arrangements, unintended gaps or overlaps, missing collisions on opaque pixels, and collisions incorrectly covering transparent pixels.
- Test opaque and transparent regions across tree canopies/trunks, rocks, and bushes. Opaque pixels must block movement; transparent gaps must remain passable, and routes around objects must stay navigable.
- Distinguish proposed changes from implemented changes.
- Do not claim runtime verification until the map has been run and tested in Godot.
- State what remains unverified.

---

# Tileset Catalog

## `overworld_exterior_labeled.svg` and `town_exterior_labeled.svg`

Both references display the same source image, `assets/tilesets/overworld/exterior.png`, because these exterior assets are shared between overworld and town maps. Use the overworld-named reference while building overworld areas and the town-named reference while building towns. Their tile coordinates and appearances are identical; the separate names clarify the intended map context. The catalog below applies to both references.

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

Buildings and doors listed here are placed on the `Objects` TileMapLayer. Complete bundled structures stay assembled as one asset; doors also need a dedicated scene-transition trigger separate from the building's blocking collision.

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


## Catalog maintenance notes

- These coordinates are transcribed from the working catalog and must be visually checked against `overworld_exterior_labeled.svg` and the Godot atlas configuration before use.
- Repeated asset names at different coordinates are separate atlas entries. Keep them distinct unless the SVG confirms they are duplicates.
- Document destination map coordinates separately from source atlas coordinates when planning a specific map.




### Town exterior door

| Coordinates | Asset |
|---|---|
| `(6,6), (7,6), (6,7), (7,7)` | Door bundle (2 × 2 atlas cells) |

The supplied coordinates form a 2-column × 2-row bundle in the labeled atlas. At 16 × 16 source pixels per cell, its atlas footprint is 32 × 32 pixels. The user's “4×4 door” label is retained as a note requiring clarification; it does not match the listed coordinate footprint if “4×4” means atlas cells.


### Town house sprite — complete bundled asset

**Asset:** One complete house sprite, arranged from top to bottom in `town_exterior_labeled.svg`. The coordinates below are a single asset, not separate buildings or modular pieces. Preserve the listed row/column arrangement and the empty cells inside its overall footprint.

```text
(2,0) (3,0) (4,0) (5,0)
(1,1) (2,1) (3,1) (4,1) (5,1) (6,1)
(1,2) (2,2) (3,2) (4,2) (5,2) (6,2) (7,2) (8,2)
(0,3) (1,3) (2,3) (3,3) (4,3) (5,3) (6,3) (7,3) (8,3) (9,3)
(0,4) (1,4) (2,4) (3,4) (4,4) (5,4) (6,4) (7,4) (8,4) (9,4)
(0,5) (1,5) (2,5) (3,5) (4,5) (5,5) (6,5) (7,5) (8,5) (9,5)
(1,6) (2,6) (3,6) (4,6) (5,6) (6,6) (7,6) (8,6)
(1,7) (2,7) (3,7) (4,7) (5,7) (6,7) (7,7) (8,7)
```

The asset's atlas footprint spans columns 0–9 and rows 0–7 (10 × 8 cells), with intentionally unlisted cells left empty. This is a source-atlas footprint, not a destination map position.

### Town exterior door

| Coordinates | Asset |
|---|---|
| `(6,6), (7,6), (6,7), (7,7)` | Door bundle (2 × 2 atlas cells) |

The supplied coordinates form a 2-column × 2-row bundle in the labeled atlas. At 16 × 16 source pixels per cell, its atlas footprint is 32 × 32 pixels. The user's “4×4 door” label is retained as a note requiring clarification; it does not match the listed coordinate footprint if “4×4” means atlas cells.


### Foreground

No assets documented yet. Leave this category unused unless a map explicitly requires scenery to render over the player.



## `chapel_exterior_labeled.svg`

### Objects

**Chapel building (single bundled asset, arranged from top to bottom).** All coordinates below belong to one complete chapel. Preserve their relative positions and the empty atlas cells in row 0; do not treat individual coordinates or rows as separate buildings.

```text
(1,0) (3,0) (4,0) (6,0)
(0,1) (1,1) (2,1) (3,1) (4,1) (5,1) (6,1) (7,1)
(0,2) (1,2) (2,2) (3,2) (4,2) (5,2) (6,2) (7,2)
(0,3) (1,3) (2,3) (3,3) (4,3) (5,3) (6,3) (7,3)
(0,4) (1,4) (2,4) (3,4) (4,4) (5,4) (6,4) (7,4)
(0,5) (1,5) (2,5) (3,5) (4,5) (5,5) (6,5) (7,5)
(0,6) (1,6) (2,6) (3,6) (4,6) (5,6) (6,6) (7,6)
(0,7) (1,7) (2,7) (3,7) (4,7) (5,7) (6,7) (7,7)
(0,8) (1,8) (2,8) (3,8) (4,8) (5,8) (6,8) (7,8)
(0,9) (1,9) (2,9) (3,9) (4,9) (5,9) (6,9) (7,9)
```

These are source atlas coordinates for **one chapel building**, with the listed arrangement running from the top row to the bottom row. Do not split this coordinate set into separate assets.
 
## `chapel_walls_interior_labeled.svg`

### Ground

| Coordinates | Asset |
|---|---|
| (2,31), (3,31), (2,32), (3,32) | Floor tile (2 × 2 bundle) |

### Objects

| Coordinates | Asset |
|---|---|
| (0,11), (1,11), (2,11), (3,11), (4,11), (5,11), (6,11), (0,12), (1,12), (2,12), (3,12), (4,12), (5,12), (6,12), (0,13), (1,13), (2,13), (3,13), (4,13), (5,13), (6,13), (0,14), (1,14), (2,14), (3,14), (4,14), (5,14), (6,14), (0,15), (1,15), (2,15), (3,15), (4,15), (5,15), (6,15) | Back wall (7 × 5 region) |
| (0,25), (1,25), (2,25), (3,25), (0,26), (1,26), (2,26), (3,26), (0,27), (1,27), (2,27), (3,27) | Portrait on back wall (4 × 3 bundle) |
| (8,4), (9,4), (8,5), (9,5), (8,6), (9,6), (8,7), (9,7) | Vertical pillar (2 × 4 bundle) |
| (3,12), (3,13), (3,14), (3,15) | Repeatable backwall section (1 × 4 vertical bundle) |

The coordinates (3,12) through (3,15) are also included in the full back-wall region above. The repeatable-backwall entry identifies those same tiles for modular/repeatable wall construction; do not treat it as a separate set of source coordinates.

## `walls_floor_labeled.svg`

Reference: `docs/tileset_reference/generated/walls_floor_labeled.svg`. Coordinates are zero-based `(column, row)`; each atlas cell represents 16 × 16 source pixels. Coordinates grouped in one row below are a single bundled asset and must retain their arrangement.

### Ground

| Coordinates | Asset | Placement rule |
|---|---|---|
| `(7,4), (8,4), (7,5), (8,5)` | Wooden floor tile variants (4 separate cells) | Each coordinate is a separately placeable floor tile. |
| `(6,10), (7,10), (8,10)` | Wooden floor tile variants (3 separate cells) | Each coordinate is a separately placeable floor tile. |

The wooden floor cells are individual tiles, not one multi-cell bundle. They may be mixed across eligible floor cells to create a varied or randomized-looking floor. Keep room geometry and collision deterministic; visual tile variation does not require procedural room generation. Only use the listed cells after confirming their appearance in the SVG.

### Objects

| Coordinates | Asset | Placement rule |
|---|---|---|
| `(1,3), (1,4)` | Stone wall section (2 × 1 bundle) | Keep the two cells together in their original vertical arrangement. |
| `(0,6), (0,7)` | Stone wall section (1 × 2 bundle) | Keep the two cells together vertically. |
| `(1,6), (1,7)` | Stone wall section (1 × 2 bundle) | Keep the two cells together vertically. |
| `(2,6), (2,7)` | Stone wall section (1 × 2 bundle) | Keep the two cells together vertically. |
| `(5,6), (6,6), (5,7), (6,7)` | Open door (2 × 2 bundle) | Preserve the complete bundle. |
| `(7,6), (8,6), (7,7), (8,7)` | Closed door (2 × 2 bundle) | Preserve the complete bundle. |

Stone wall pieces belong on the Objects layer and must block movement where the wall is solid. Door collision and scene-transition triggers must follow the existing building/door collision rules: the transition trigger is separate from ordinary blocking collision.

### Foreground

| Coordinates | Asset | Placement rule |
|---|---|---|
| `(5,4), (6,4), (5,5), (6,5)` | Window (2 × 2 bundle) | Place on Foreground so it renders over the wall. Preserve the complete bundle and keep transparent window openings transparent. |

The window is not a small decorative detail. It is an overlay component intended to be layered over the wall structure.


## `ruined_temple_exterior_objects_labeled.svg`

Reference: `docs/tileset_reference/generated/ruined_temple_exterior_objects_labeled.svg`, sourced from `assets/tilesets/dungeons/ruined_temple/Exterior_objects.png`. The sheet is 352 × 656 source pixels, arranged as 22 columns × 41 rows of 16 × 16 cells. Coordinates use zero-based `(column, row)`.

### Details

| Coordinates | Asset | Placement rule |
|---|---|---|
| `(10,2)` | Flower | Single-cell detail. |
| `(11,2)` | Flower | Single-cell detail. |
| `(12,2)` | Flower | Single-cell detail. |
| `(12,25)` | Grass leaf | Single-cell detail. |
| `(12,24)` | Grass leaf | Single-cell detail. |
| `(12,22), (12,23)` | Vertical grass leaf bundle (1 × 2) | Keep both cells together vertically. |

### Objects

| Coordinates | Asset | Placement rule |
|---|---|---|
| `(9,2)` | Small tree | Single-cell source asset; inspect alpha and collision before use. |
| `(9,0), (10,0), (9,1), (10,1)` | Medium tree bundle (2 × 2) | Preserve the complete arrangement. |
| `(11,0), (12,0), (11,1), (12,1)` | Medium tree bundle (2 × 2) | Preserve the complete arrangement. |
| `(3,0), (4,0), (5,0), (6,0), (7,0), (2,1), (3,1), (4,1), (5,1), (6,1), (7,1), (8,1), (2,2), (3,2), (4,2), (5,2), (6,2), (7,2), (8,2), (2,3), (3,3), (4,3), (5,3), (6,3), (7,3), (8,3), (1,4), (2,4), (3,4), (4,4), (5,4), (6,4), (7,4), (8,4), (9,4), (0,5), (1,5), (2,5), (3,5), (4,5), (5,5), (6,5), (7,5), (8,5), (9,5), (10,5), (0,6), (1,6), (2,6), (3,6), (4,6), (5,6), (6,6), (7,6), (8,6), (9,6), (0,7), (1,7), (2,7), (3,7), (4,7), (5,7), (6,7), (7,7), (8,7), (9,7), (1,8), (2,8), (3,8), (4,8), (5,8), (6,8), (7,8), (8,8), (9,8)` | Full moss-covered ruined temple sprite | One complete bundled asset. Preserve the exact listed row/column arrangement; do not split it into separate objects. Verify the visible sprite footprint against the SVG before placement. |

### Pending coordinate correction

The supplied coordinate list for the **vertical dragon statue** contains malformed and repeated entries: four occurrences of `(,31)` have no column value, and coordinates such as `(2,33)`, `(2,34)`, and `(2,35)` are repeated. These have intentionally **not** been normalized or treated as confirmed coordinates. Correct that list against the SVG before adding the dragon statue to a map or using it as a placement-ready bundle.

