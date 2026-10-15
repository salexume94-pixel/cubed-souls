# Tileset Catalog Cross-Check

Date: 2026-10-15  
Branch: `main`

## Results

This review compares the labeled SVG source images, documented coordinate bundles, and the TileSet resource currently used by the overworld/town map. Visual inspection here is not a substitute for opening each resource in Godot.

| Reference | Source image dimensions | Grid | Result |
|---|---:|---:|---|
| `overworld_exterior_labeled.svg` / `town_exterior_labeled.svg` | 240 × 800 px | 15 × 50 | The two references show the same exterior sheet. Catalogued coordinates are within the sheet; registered cells needed by the current overworld and Havenreach object bundles are present in atlas source 0. |
| `ground_grass_details_labeled.svg` | 336 × 288 px | 21 × 18 | Existing grass-leaf placements use atlas source 1. The sheet contains several distinct detail families; only the grass-leaf cells currently used by the overworld generator are treated as verified placements. |
| `house_details_labeled.svg` | 160 × 272 px | 10 × 17 | Visual reference exists, but the ruleset has no coordinate-level catalog for this sheet yet. Do not use its modular parts until the intended bundles are catalogued. |
| `chapel_exterior_labeled.svg` | 256 × 304 px | 16 × 19 | The first chapel occupies an 8 × 10 region. The documented row-0 cells (1,0), (3,0), (4,0), (6,0) and rows 1–9, columns 0–7 match the visible bundle. Registered as atlas source 2 for Havenreach. |
| `chapel_walls_interior_labeled.svg` | 160 × 528 px | 10 × 33 | The listed floor, wall, portrait, and pillar groups are within the source grid. Dedicated TileSet resource `assets/tilesets/towns/church_interior.tres` and scene `world/maps/towns/interiors/church_interior.tscn` now use these bundles; runtime appearance remains unverified. The repeatable wall section duplicates coordinates already included in the back-wall region. |
| `walls_floor_labeled.svg` | 144 × 176 px | 9 × 11 | Listed floor, wall, door, and window coordinates fit the grid. Dedicated TileSet resource `assets/tilesets/towns/house_interior.tres` and scene `world/maps/towns/interiors/house_interior.tscn` now use the catalogued floor, wall, and open-door cells; runtime appearance remains unverified. |
| `ruined_temple_walls_floor_labeled.svg` | 176 × 256 px | 11 × 16 | Listed coordinates fit the grid. The pillar is a 3 × 5 bundle, the interior passage is 2 × 3, and wall-edge groups must remain assembled. |
| `ruined_temple_exterior_objects_labeled.svg` | 352 × 656 px | 22 × 41 | Listed coordinates fit the grid. Exterior temple/ruin structures and trees are separate bundles; do not substitute the ruin facade for an ordinary town building. |

## Cross-check findings

- Coordinates in the catalog are zero-based `(column, row)`; the labeled SVG display scales source tiles by 4, so each labeled cell is 64 × 64 SVG units representing a 16 × 16 source tile.
- The shared overworld TileSet registers the exterior, grass-detail, and chapel-exterior atlases (source IDs 0, 1, and 2). Dedicated TileSet resources now exist for the catalogued house-interior `walls_floor.png` sheet and chapel `Walls_Interior.png` sheet. Dungeon sheets still need dedicated TileSet resources before they can be placed as TileMapLayer cells.
- The town-house bundle in the exterior sheet has a 10 × 8 bounding footprint with intentional unlisted cells. The generator skips unregistered atlas cells while preserving their source-to-map offsets.
- No Polygon2D, hand-drawn replacements, or invented asset pixels are used by the Havenreach generator.
- No exact coordinate catalog is currently present for `house_details_labeled.svg`. That catalog gap remains open rather than being filled with guessed modular-piece coordinates.

## Remaining verification

- Open `house_interior.tscn` and `church_interior.tscn` in Godot and confirm atlas appearances, tile alignment, and editor-generated layouts.
- Run the Havenreach test scene and verify house/church doorway transitions, return positions, doorway collision, and camera framing.
- Catalog useful `house_details` bundles with explicit coordinates before using those modular parts; the reusable house interior deliberately uses the already-catalogued `walls_floor.png` sheet instead.
- Build dedicated TileSet resources for dungeon sheets when those maps are implemented.
