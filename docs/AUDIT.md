# Asset and Repository Audit

**Repository:** `salexume94-pixel/cubed-souls`  
**Branch audited:** `main`  
**Commit audited:** `2324d8d14b0a8e609fa7f3d808ad3dc26a59c2ae`  
**Status:** Repository inventory complete; pixel-level inspection remains incomplete.

## 1. Repository inventory

The recursive Git tree returned `truncated: false`, so this inventory covers the complete tree at the audited commit.

| Check | Result |
| --- | ---: |
| Total tree entries | 2,861 |
| Files (blobs) | 2,785 |
| PNG assets | 1,379 |
| PNG `.import` sidecars | 1,379 |
| Total PNG file size | 7,122,758 bytes (about 7.12 MB) |
| PSD source files | 2 |
| `.DS_Store` files | 2 |

The sidecar count matches the PNG count. Preserve Godot import metadata where required; do not delete sidecars indiscriminately.

## 2. PNG assets by category

Counts are based on each PNG file's directory path.

| Category | PNG count | Contents |
| --- | ---: | --- |
| Objects | 656 | Trees, bushes, rocks, crystals, and environmental objects |
| Dungeons | 433 | Ruins, undead-themed assets, ruined temple tiles and objects |
| Towns | 189 | Town tiles, chapel assets, interiors, animated objects, and character sheets |
| Enemies | 92 | Three slime variants, animations, shadows, and component sheets |
| Player | 7 | Idle, walk, run, hurt, death, and shadow assets |
| Overworld | 2 | Exterior tilesheet and grass-detail tilesheet |

These counts describe file organization, not whether every file is ready for use in-game.

## 3. Confirmed project and overworld files

The repository contains:
- `project.godot`
- `world/maps/overworld/world.tscn`
- `assets/tilesets/overworld/background.tres`
- `assets/tilesets/overworld/exterior.png`
- `assets/tilesets/overworld/ground_grass_details.png`

The overworld PNG dimensions checked earlier are consistent with 16×16 tile cells. The TileSet resource contains atlas-coordinate definitions. The overworld scene now uses `world.gd` to draw a 1024×640 grass field and winding dirt path, scatter grass details from `ground_grass_details.png`, and place tree/rock sprite regions from `exterior.png`. The center is kept clear for the player spawn. These source sheets contain transparent props/details rather than a complete opaque ground texture, so the ground and path are drawn beneath them. This is a code-level implementation only: region boundaries and runtime appearance still require Godot testing.

## 4. Sprite-sheet findings

### Player

Files in `assets/sprites/player/` include:
- `Unarmed_Idle_without_shadow.png`
- `Unarmed_Walk_without_shadow.png`
- `Unarmed_Run_without_shadow.png`
- `Unarmed_Hurt_without_shadow.png`
- `Unarmed_Death_without_shadow.png`
- `shadow_death.png`
- `shadow_single.png`

No player attack animation was identified in this directory. Do not assume the player has a complete combat animation set until other assets are checked.

| File | Dimensions | Initial grid hypothesis |
| --- | ---: | --- |
| `Unarmed_Idle_without_shadow.png` | 768×256 | Candidate 12×4 frames at 64×64 |
| `Unarmed_Walk_without_shadow.png` | 384×256 | Candidate 6×4 frames at 64×64 |
| `Unarmed_Run_without_shadow.png` | 512×256 | Candidate 8×4 frames at 64×64 |

These are hypotheses based on image dimensions, not confirmed frame boundaries or animation order.

### Slimes

There are three slime variants under `assets/sprites/enemies/slime_mobs/`. Each has animation files for idle, walk, run, attack, hurt, and death, with versions that include or omit shadows. Component sheets and separate shadow assets are also present.

For Slime1, these dimensions were checked:

| File | Dimensions | Initial grid hypothesis |
| --- | ---: | --- |
| `With_shadow/Slime1_Idle_with_shadow.png` | 384×256 | Candidate 6×4 frames at 64×64 |
| `With_shadow/Slime1_Walk_with_shadow.png` | 512×256 | Candidate 8×4 frames at 64×64 |
| `With_shadow/Slime1_Attack_with_shadow.png` | 640×256 | Candidate 10×4 frames at 64×64 |

Do not assume every slime variant shares identical frame sizes or animation timing without checking the individual files.

### Environment asset variants

Trees, bushes, crystals, and ruins contain folders with names such as `Assets`, `Assets_shadow`, `Assets_texture_shadow`, and `Assets_texture_shadow_dark`. Source sheets and individually separated object images are also present.

These names suggest alternate visual or shadow variants, but their appearance and differences have not been visually confirmed. Choose consistent variants after inspection rather than mixing them without review.

## 5. Repository cleanup

Two macOS metadata files are tracked:
- `assets/sprites/enemies/slime_mobs/.DS_Store`
- `assets/tilesets/towns/chapels/.DS_Store`

Recommended cleanup:
1. Remove the two `.DS_Store` files from version control.
2. Add `.DS_Store` to `.gitignore`.
3. Review other non-game files before removing them.
4. Keep necessary Godot `.import` sidecars unless the import workflow is deliberately changed.

## 6. Audit status

| Audit item | Status |
| --- | --- |
| Complete Git tree inventory | Verified |
| Asset counts by category | Verified from file paths |
| PNG and `.import` sidecar counts | Verified |
| Player, slime, and overworld file presence | Verified |
| Dimensions of listed sample PNGs | Verified from PNG headers |
| 16×16 overworld tile grid | Consistent with dimensions and TileSet definitions |
| 64×64 character frame grid | Plausible hypothesis; not fully verified |
| Actual transparency of all PNGs | Not verified |
| Pixel margins, spacing, and frame boundaries across all sheets | Not verified |
| Animation directions, frame order, and timing | Not verified |
| Runtime appearance of all assets in Godot | Not verified |

## 7. Remaining audit work

Before relying on these assets in gameplay:
1. Inventory dimensions of every PNG.
2. Check alpha-channel presence and actual transparent pixels.
3. Identify likely tile dimensions, frame dimensions, margins, and spacing.
4. Confirm animation rows, directions, frame counts, and ordering.
5. Identify duplicates and alternate versions.
6. Record each asset's intended role: overworld, town, dungeon, player, enemy, or effect.
7. Flag assets requiring manual visual inspection or Godot import testing.

**Limitation:** This audit confirms repository structure, file counts, selected PNG dimensions, and the presence of key project resources. It does not claim that all 1,379 PNGs have been visually inspected or runtime-tested. Complete the pixel-level audit before making assumptions about sprite layout or migrating gameplay systems around those assumptions.


---

## 2026-10-14 — Repository Audit Refresh

**Branch:** `main`  
**Latest commit inspected:** `98684e452b65e7f1670a3168d227b5cf75321b18` — `Log ruined temple walls floor catalog`

### Current repository snapshot

The recursive Git tree completed without truncation and returned **2,888 entries**. This is 27 more entries than the earlier audit's 2,861 tree entries, so the original inventory is now historical rather than current. The current repository metadata confirms the default branch is `main`, the repository is public, and it is not archived.

### Findings

| Severity | Finding | Status / impact |
|---|---|---|
| High | `world/maps/towns/havenreach/havenreach.tscn` is only a scene scaffold: four TileMapLayers, empty Buildings/NPCs containers, and PlayerSpawn. It has no attached map-generation script, populated cells, or placed town assets. | Confirmed by static inspection. Havenreach is not yet a playable/constructed town map. |
| High | `scenes/main.tscn` starts directly with `world/maps/overworld/world.tscn` and a player at (512, 320). | Confirmed. The project currently launches the generic overworld, not Havenreach or the story opening. |
| High | `world/maps/overworld/world.gd` reconstructs the Ground, Details, and Objects layers on ready. The placement data is hard-coded in the script. | Confirmed. Keep the generated layout deterministic; map-specific hand-authored placements should not be added to layers that the script clears. |
| High | The overworld collision generator derives shapes from texture alpha, but collision accuracy and transparency gaps cannot be established from code inspection alone. | Requires Godot runtime testing against actual sprites and movement. Preserve user-adjusted `GeneratedObjectCollisions` as the script's comments specify. |
| Medium | `.gitignore` does not ignore `.DS_Store`, while two `.DS_Store` files are tracked in the repository. | Confirmed. Ignore future macOS metadata; remove tracked copies separately if desired. |
| Medium | The project config has no explicit viewport/window dimensions. | Confirmed in `project.godot`. Decide desired baseline dimensions before relying on window defaults. |
| Medium | `docs/AUDIT.md` previously recorded commit `2324d8d...` and 2,861 tree entries. | Updated snapshot supersedes those counts; retain the older section as historical evidence. |
| Medium | The tileset catalog contains coordinate entries that are explicitly awaiting visual cross-checks against labeled SVGs and the actual atlas resource. | Do not assume newly cataloged dungeon pieces are ready for map placement until cross-checked. |
| Low | The repository root has no `README.md`. | Confirmed by a 404 on the default branch. A root README would improve onboarding, but is not required for the project to run. |

### Positive findings

- `project.godot`, `scenes/main.tscn`, player scene/script, overworld scene/script, and the shared TileSet resource are present.
- The recursive tree includes `world/maps/towns/havenreach/` and the intended map directories for `dungeons`, `overworld`, and `towns`.
- Generated labeled references now include overworld/town exterior, ground grass details, house details, chapel exterior/interior, and ruined-temple exterior/interior tilesets.
- `docs/MAP_MAKING_RULESET.md` clearly separates Ground, Details, Objects, and Foreground and requires complete bundled assets, alpha-aware collision, and explicit runtime verification.
- `docs/RUNTIME_VERIFIED.md` appropriately labels user-reported checks and states their scope limits.
- The latest commits append catalog/development-log entries rather than deleting the earlier history.

### Recommended next actions

1. Build Havenreach using the existing labeled references and actual tileset resources; do not invent substitute art.
2. Before map placement, reconcile the newly supplied ruined-temple coordinates against the SVG and TileSet atlas.
3. Run the project in Godot and test object collisions, transparent gaps, map boundaries, camera bounds, and player movement after the latest pull.
4. Add `.DS_Store` to `.gitignore`; remove the already tracked metadata files in a separate cleanup commit.
5. Decide and document the intended viewport/window dimensions.
6. Keep all untested findings labeled as static inspection, not runtime verification.

**Audit limits:** This refresh inspects GitHub files, metadata, and the complete repository tree. It does not execute Godot, inspect every PNG pixel, validate all scene resource references, or verify collision fit in runtime.
