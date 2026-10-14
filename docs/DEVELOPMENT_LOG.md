## 2026-10-14 — Add NPC Instances to Havenreach

### Changes
- Added three reusable NPC scene instances under Havenreach's existing `NPCs` node: a wandering townsperson, a patrolling town guard, and a wandering traveler using the Ally profile.
- Configured distinct starter dialogue on each instance so the E-key interaction can be tested in the actual town scene.
- Kept the isolated NPC test scene for movement-specific testing; it is not the game's startup scene.
- Source committed directly to GitHub `main`.

### Verification
- [x] Confirmed the previous Havenreach scene had an empty `NPCs` container.
- [x] Added three NPC instances and configured their profiles/dialogue in `havenreach.tscn`.
- [ ] Pull `origin main`, open Havenreach in Godot, and confirm the NPCs are visible and positioned correctly.
- [ ] Runtime-test NPC movement, obstacle avoidance, and E-key dialogue.
- **Status:** Scene placement committed; Godot editor/runtime verification pending.

---

## 2026-10-14 — Port NPC Movement and Behavior Profiles

### Changes
- Adapted the previous Scripts repository's movement ideas to the current reusable NPC actor instead of copying its old combat/game-state dependencies.
- Added Stationary, Civilian, Guard, and Ally behavior profiles. Civilians and Allies wander within a bounded home radius and create personal space when the Player approaches; Guards follow authored patrol points or remain at their post.
- Added obstacle steering using three parallel raycasts, alternate-direction checks, and a short stuck-recovery override.
- Added Ally proximity signals and explicit story-target movement hooks without coupling NPC movement to a story manager.
- Separated physics layers: static world geometry is layer 1, Player is layer 2, and NPCs use layer 3. The Player collides with NPCs, but NPC movement ignores the Player body so it cannot push civilians around; interaction sensors still detect the Player.
- Expanded scenes/tests/npc_test.tscn with Civilian, Guard, and Ally examples.
- Updated the architecture guide and implementation checklist.

### Verification
- [x] Reviewed the previous Scripts/world/moving_npc.gd and adapted movement/avoidance concepts to the current NPC scene.
- [x] Updated NPC/player collision layers and interaction sensor masks in source.
- [x] Committed implementation and documentation directly to GitHub main.
- [ ] Pull origin main, run scenes/tests/npc_test.tscn, and verify civilian wandering/retreat, guard patrol, ally wandering/detection, obstacle avoidance, collision, and dialogue.
- **Status:** Source committed; Godot runtime verification pending.

---

## 2026-10-14 — Re-enable Source-Alpha Object Collision Trial

### Changes
- Re-enabled alpha-derived object collision generation in the overworld and Havenreach map builders.
- The generators now clear the previous `GeneratedObjectCollisions` container and rebuild it from the current catalogued object bundles.
- Collision is derived from opaque source-atlas pixels; transparent pixels remain passable.
- Havenreach includes complete houses and chapel now that their roof tiles are placed on Objects rather than Foreground.
- Preserved map-edge boundaries, player/NPC collision, and interaction logic.
- Updated the map-making ruleset to describe alpha collision as the current trial rather than a disabled phase.

### Verification
- [x] Confirmed the existing alpha-mask and merged-rectangle generation methods are present in both map scripts.
- [x] Enabled collision generation after each map's object placement step.
- [x] Committed source and documentation updates to GitHub `main`.
- [ ] Pull `origin main`, open the overworld and Havenreach in Godot, inspect `GeneratedObjectCollisions`, and test movement against visible and transparent sprite areas.
- **Status:** Source changes committed; Godot editor/runtime verification pending.

---

## 2026-10-14 — Move Havenreach Roof Tiles to Objects Layer

### Changes
- Changed Havenreach house placement so every house tile, including all roof tiles, is placed on the Objects TileMapLayer.
- Changed chapel placement so its entire bundled sprite, including the roof, stays on Objects.
- Clear and rebuild the generated Objects and Foreground layers before placement, preventing roof tiles left by the old split-layer logic from lingering.
- Reserved Foreground for clouds and flying birds; updated the map-making ruleset accordingly, including moving the documented window overlay rule to Objects.
- Left collision generation disabled as currently configured; this change only changes visual tile-layer placement.

### Verification
- [x] Updated the Havenreach generator source and map-making documentation on GitHub `main`.
- [ ] Pull `origin main`, open Havenreach in Godot, and confirm house/church roofs are on Objects and Foreground is clear for sky elements.
- [ ] Runtime/editor verification remains pending.

---

## 2026-10-14 — Narrow Collision Disablement to World Objects

### Changes
- Corrected the previous change: only world-object collision is disabled; map-edge boundary collision remains enabled at runtime.
- Added cleanup for the generated `GeneratedObjectCollisions` container in the overworld and Havenreach tool scripts, removing the invisible house/tree/rock/bush collision nodes from the editor as well as runtime.
- Left player/NPC actor collision and interaction systems unchanged.
- Updated the map-making ruleset to clarify the scope.

### Verification
- [x] Confirmed both scene files do not serialize generated object-collision nodes.
- [x] Restored runtime map-edge boundary creation in both map scripts.
- [x] Committed the corrected source to GitHub `main`.
- [ ] Pull `origin main` and verify in Godot that object collision boxes disappear while map boundaries and actor collisions remain.
- **Status:** Source changes committed; Godot runtime/editor verification pending.

---

## 2026-10-14 — Temporarily Disable World Object and Boundary Collisions

### Changes
- Disabled generated alpha-based collision creation in the overworld and Havenreach map builders.
- Disabled automatically created map-edge boundary bodies so map navigation can be inspected without object or boundary collision nodes.
- Confirmed the shared overworld TileSet resource contains no serialized physics-layer or tile-collision entries.
- Left all visual tile placement, player movement, and NPC interaction code unchanged.
- Updated the map-making ruleset to mark this as a temporary collision-disabled debugging phase.

### Verification
- [x] Inspected the overworld and Havenreach scene scripts and shared TileSet resource on GitHub `main`.
- [x] Source edits committed to `main`.
- [ ] Pull `origin main`, inspect the scene tree, and test movement through objects and across map edges in Godot.
- **Status:** Source changes are committed; Godot editor/runtime verification is pending.

---

## 2026-10-14 — Fix Project and NPC Test Scene Parse Errors

### Changes
- Replaced literal escaped newline sequences in the `project.godot` autoload block with real line breaks, preserving the existing `SceneTestBootstrap` autoload and display settings.
- Changed the NPC test scene comment to Godot scene-file comment syntax.

### Verification
- [x] Confirmed the autoload block is structurally separated from the display section in the source.
- [x] Confirmed the test scene no longer uses the invalid `#` comment line.
- [ ] Pull `origin main`, reopen the project, and confirm Godot no longer reports the autoload resource-path or test-scene parse errors.
- **Status:** Source formatting corrected; Godot runtime/editor verification pending.

---

## 2026-10-14 — Add Isolated NPC Test Scene

### Changes
- Added `scenes/tests/npc_test.tscn`, which loads the existing overworld, player, and reusable NPC with sample two-line dialogue.
- Kept the test scene separate from `scenes/main.tscn`; it does not change the game's startup scene.
- Documented the test scene in the architecture guide and NPC checklist.

### Verification
- [x] Checked that the scene references existing scene paths and sets the NPC sample dialogue.
- [ ] Open `scenes/tests/npc_test.tscn` in Godot and run it to test proximity, E-key dialogue, player movement lock/unlock, collision, and optional movement modes.
- **Status:** Code-reviewed; runtime verification pending.

---

## 2026-10-14 — Add Reusable NPC Scene, Movement, and Dialogue

### Changes
- Added `world/actors/npc/npc.tscn` and `npc.gd` as a reusable NPC actor.
- NPCs reuse the player's 64×64 sprite sheets and directional idle/walk/run frame layout. The physical capsule uses the same radius (10 px), height (32 px), and vertical offset (-24 px) as the player.
- Added configurable stationary, bounded-wander, and patrol movement modes. NPCs are stationary by default; patrol paths can be assigned in the Inspector.
- Added an interaction area and E-key dialogue with configurable speaker name and multiple lines. Dialogue locks player movement until the final line is advanced.
- Added the player's `movement_enabled` flag and `player` group registration so dialogue can pause movement cleanly.
- Updated `docs/ARCHITECTURE.md` and `docs/checklist.md` to document the new actor and keep runtime verification pending.

### Verification
- [x] Reviewed referenced sprite paths, scene node paths, collision dimensions, and player movement-lock integration against current `main` source.
- [x] Changes committed directly to GitHub `main`.
- [ ] Pull `origin main`, open/run the project in Godot, and verify NPC animation visibility, collisions, each movement mode, E-key interaction, multi-line dialogue, and player movement lock/unlock.
- **Status:** Code-reviewed; Godot parser/editor/runtime verification has not been run here.

---

## 2026-10-14 — Add Prioritized Implementation Checklist

### Changes
- Added `docs/checklist.md` to track the next gameplay-system work in priority order: reusable NPC scenes, scene transitions ported from `Scripts`, then the quest system ported from `Scripts`.
- Recorded the current state accurately: NPC scenes are not implemented; scene transitions and the quest system have not been ported.
- Linked the checklist from the documentation index.

### Verification
- [x] Checklist and documentation index committed directly to `main`.
- [ ] Pull `origin main` and confirm `docs/checklist.md` appears in the local working tree.
- Runtime verification is not applicable to this documentation-only change.

---

## 2026-10-14 — Generalize F6 Player Spawning for Map Scenes

### Changes
- Added `systems/scene_test_bootstrap.gd` as a shared autoload that checks the active scene after a whole-scene launch.
- When the selected scene contains `PlayerSpawnMarker` or the legacy `PlayerSpawn` marker, the bootstrap reuses an existing Player or instantiates `player/player.tscn`, then places it at the marker.
- Registered the bootstrap in `project.godot`. The main scene's existing player is left alone when its scene has no spawn marker.
- Removed the Havenreach-only spawning helper so the behavior is not tied to one map.
- Kept the existing Havenreach marker named `PlayerSpawnMarker`.

### Verification
- [x] Changes committed directly to `main`.
- [ ] Pull `origin main`, press F6 on Havenreach, and confirm the player appears at its marker.
- [ ] Press F6 on another map with a spawn marker and confirm the same behavior.
- [ ] Run the main game and confirm it does not create a duplicate player.
- Runtime verification is pending.

---

## 2026-10-14 — Spawn Player at Havenreach Marker During Standalone Tests

### Changes
- Renamed the Havenreach marker to `PlayerSpawnMarker` so its role is explicit.
- Added runtime-only standalone test spawning: when Havenreach is the active scene and no `Player` already exists, it instantiates `player/player.tscn` and places it at the marker's global position.
- When Havenreach is loaded into a scene that already contains a player, the map reuses that player and does not create a duplicate.
- Editor preview remains unchanged; the player is created only at runtime.

### Verification
- [x] Source changes committed directly to `main`.
- [ ] Pull `origin main` and press F6 on `world/maps/towns/havenreach/havenreach.tscn`; confirm the player appears at `PlayerSpawnMarker`.
- [ ] Confirm loading Havenreach with an existing player does not create a duplicate.
- Runtime verification is pending.

---

## 2026-10-14 — Full House Alpha Collision and Occupied-Plot Checks

### Changes
- Replaced the split roof/body collision specs with one alpha mask spanning the complete 10×8 house bundle. This removes the roof/body row cutoff and runs the existing alpha-based collider generator across the roof and body together.
- Changed Havenreach placement order so the chapel, trees, rocks, and bushes are placed before houses.
- House candidates are now checked against occupied `Objects` and `Foreground` tile cells; overlapping plots are skipped while preserving seeded random placement.
- Added a warning if fewer than four non-overlapping houses can be placed.

### Verification
- [x] Changes committed directly to `main`.
- [ ] Pull `origin main`, inspect house placement and test collision on opaque roof pixels and transparent gaps in Godot.
- Runtime verification is pending.

---

## 2026-10-14 — Correct Havenreach Roof Alpha Sampling

### Correction
- The prior roof/body split did not change the alpha sampler's reliance on each TileSetAtlasSource tile texture region. Reworked sampling to read the exact registered atlas cell directly from the source PNG using atlas coordinates, so foreground-rendered roof pixels are sampled independently of their visual layer.
- Added an explicit error if a requested object region produces zero opaque pixels, preventing a missing collider from failing silently.
- Kept alpha-based collision, transparent gaps, and merged rectangle shapes.

### Verification
- [x] Fix committed directly to `main`.
- [ ] Pull `origin main`, open Havenreach in Godot, and test opaque roof pixels and transparent gaps.
- Runtime verification is pending.

---

## 2026-10-14 — Extend Havenreach House Alpha Collision to Roofs

### Changes
- Split each generated house collision mask into two alpha-derived regions matching its rendering layers: roof/foreground rows 0–4 and body/object rows 5–7.
- The roof now gets an explicit collision pass over its full 10×5-tile region. Opaque roof pixels block movement; transparent pixels remain walkable.
- Kept the existing alpha threshold and merged-rectangle approach. House placement, art, and randomized layout are unchanged.

### Verification
- [x] Change committed directly to `main`.
- [ ] Pull `origin main`, open Havenreach in Godot, and test movement against the roof edges and transparent gaps.
- Runtime verification is pending.

---

## 2026-10-14 — Keep Building Collision Alpha-Based

### Correction
- Building collision now uses the same alpha-mask method as trees, rocks, and bushes. Opaque pixels from roof and wall artwork block the player; transparent pixels inside atlas cells remain walkable.
- Removed the intended full-footprint rectangle behavior from the current Havenreach collision generator. The roof is not treated as a solid rectangular tile area.
- Seeded-random house plot selection remains in place, and modular `house_details` construction remains deferred.

### Verification
- [x] Current `havenreach.gd` source checked on GitHub `main`: all placed bundles use `_add_alpha_collision_for_bundle()`.
- [ ] User should visually check roof gaps and building edges in Godot after pulling the latest changes.

---

## 2026-10-14 — Scatter Havenreach Houses and Use Full-Building Collisions

### Changes
- Replaced the rigid four-corner house layout with seeded-random selection from separated candidate plots, keeping the arrangement irregular but repeatable between runs.
- Changed house and chapel collision to one solid rectangle covering the entire building footprint, including roofs. Walking behind building roofs is intentionally blocked.
- Kept alpha-derived collisions for trees, rocks, and bushes so their transparent gaps remain passable.
- Deferred the modular `house_details` sheet; modular house construction is not part of this pass.

### Verification
- [x] User reports Havenreach movement, collisions, and camera bounds are runtime-verified in Godot.
- [x] Source changes committed to GitHub `main`.
- [ ] Reopen Havenreach in Godot and visually check the randomized house arrangement and full-footprint building blockers after pulling the latest `main`.

---


---

## 2026-10-14 — Add Havenreach Runtime Verification Checklist

### Changes
- Added a repeatable local Godot checklist for import/parse errors, map layout, player movement/run, object collisions, transparent gaps, foreground overlap, camera bounds, and map boundaries.
- Kept runtime verification unchecked because Godot is not available in the repository-editing environment and the project has not yet been run locally.

### Verification
- [x] Checklist committed to GitHub `main`.
- [ ] User must pull `origin main`, run the Havenreach test scene, and report any errors before runtime behavior can be marked verified.

---


---

## 2026-10-14 — Build Havenreach Map Scaffold and Cross-Check Tileset Catalogs

### Changes
- Cross-checked labeled SVG dimensions and documented bundle footprints in `docs/TILESET_CROSSCHECK.md`.
- Registered the existing chapel exterior PNG as atlas source ID 2 in the shared TileSet; the chapel bundle uses its catalogued 8 × 10 region.
- Added the deterministic Havenreach map generator using existing grass, house, chapel, tree, rock, bush, and grass-detail atlas cells.
- Kept house and chapel bundles aligned to their source coordinates and split upper rows onto Foreground for player overlap.
- Added alpha-derived collision generation for placed bundles and runtime-only map boundaries.
- Added `havenreach_test.tscn` as a direct movement/camera test harness without changing the main story launch scene.
- Set the project baseline viewport and window override to 1152 × 648 (16:9).
- Preserved the existing development history and kept the earlier `.DS_Store` cleanup in its own commit.

### Verification
- [x] Static source inspection of the labeled atlas references and current TileSet resource.
- [x] Havenreach scene, script, chapel atlas source, and test harness committed to GitHub `main`.
- [x] Viewport/window baseline explicitly configured.
- [ ] Godot editor import and parse validation pending on the user's machine.
- [ ] Runtime movement, alpha collision fit, transparent gaps, foreground overlap, camera bounds, and boundaries remain unverified until the test scene is run in Godot.
- [ ] Modular house-details coordinates still need cataloguing; chapel-interior and dungeon sheets do not yet have TileSet resources.

---

## 2026-10-14 — Catalog Ruined Temple Walls and Floor Assets

### Changes
- Added the supplied Ground coordinates for the entrance floor and repeatable floor cells to `docs/MAP_MAKING_RULESET.md`.
- Cataloged crumbling wall edges, four vertical stone-wall sections, left/right wall edges, the 2 × 3 interior door bundle, and the complete 3 × 5 solid stone pillar bundle.
- Documented the interior door as a possible future deeper-level passage, not an implemented transition.
- Preserved the existing append-only development history.

### Verification
- [x] Coordinate catalog committed directly to GitHub `main`.
- [ ] Visual cross-check against the labeled SVG and Godot atlas configuration remains pending.
- [ ] No map placement, collision implementation, or runtime behavior was changed or verified.

---

## 2026-10-14 — Add Ruined Temple Walls and Floor Coordinate Reference

### Changes
- Added `docs/tileset_reference/generated/ruined_temple_walls_floor_labeled.svg` directly to GitHub `main`, embedding the original PNG with a zero-based coordinate grid.
- Confirmed the source dimensions are 176 × 256 pixels: 11 columns × 16 rows of 16 × 16 cells.
- Updated `docs/MAP_MAKING_RULESET.md` with the reference path, dimensions, visible asset categories, and catalog status.
- Kept exact per-asset coordinates unlisted rather than guessing bundle boundaries from an unverified visual read.

### Verification
- [x] Source PNG fetched from the repository and dimensions confirmed from its PNG header.
- [x] Labeled SVG committed to GitHub `main`.
- [x] Ruleset updated and this entry added without removing historical log content.
- [ ] Exact floor, wall, doorway, and overlay coordinates still need a careful pass against the labeled SVG.
- [ ] No Godot map placement or runtime behavior was changed or verified.

---

## 2026-10-14 — Add Ruined Temple Walls and Floors Reference

### Changes
- Added `assets/tilesets/dungeons/ruined_temple/Walls_floor.png` to `tools/generate_tileset_reference.py`.
- Defined the generated reference name as `ruined_temple_walls_floor_labeled.svg`.
- Added a section to `docs/MAP_MAKING_RULESET.md` explaining the source and that its assets must be visually cataloged before coordinates or classifications are assigned.

### Verification
- [x] Generator and documentation updates committed to GitHub `main`.
- [ ] Run the generator locally and inspect the generated SVG.
- [ ] Identify useful floor, wall, and doorway assets and record their exact coordinates.
- [ ] Godot atlas mapping, placement, collision, layering, and runtime behavior remain unverified.

---

## 2026-10-14 — Correct Complete Ruined Temple Dragon Statue Coordinates

### Changes
- Updated the vertical dragon statue entry in `docs/MAP_MAKING_RULESET.md` with the user's corrected full coordinate set.
- Recorded all 24 unique cells across columns 0–3 and rows 29–35, including the previously omitted `(1,33)`, `(1,34)`, and `(1,35)` cells.
- Kept the statue as one bundled object and did not change any other tileset entries.

### Verification
- [x] Corrected coordinate list committed to GitHub `main`.
- [ ] Visually cross-check the full statue silhouette against `ruined_temple_exterior_objects_labeled.svg`.
- [ ] Godot placement, collision, layering, and runtime behavior remain unverified.

---

## 2026-10-14 — Correct Ruined Temple Dragon Statue Coordinates

### Changes
- Replaced the unresolved dragon-statue note with the corrected coordinates supplied by the user in `docs/MAP_MAKING_RULESET.md`.
- Removed repeated coordinate entries `(2,33)`, `(2,34)`, and `(2,35)` from the catalog representation; each unique source cell is recorded once.
- Preserved all unique coordinates supplied for the vertical dragon statue. No missing coordinates were invented.

### Verification
- [x] Updated the ruined temple asset catalog on GitHub `main`.
- [ ] Visually cross-check the dragon statue's full silhouette against the labeled SVG.
- [ ] Godot placement, collision, layering, and runtime behavior remain unverified.

---

## 2026-10-14 — Catalog Ruined Temple Exterior Objects

### Changes
- Added the user's confirmed flower, grass-leaf, small-tree, medium-tree, and complete moss-covered ruined-temple sprite coordinates to `docs/MAP_MAKING_RULESET.md`.
- Recorded the two medium trees as complete 2 × 2 bundles and the vertical grass leaf as a 1 × 2 bundle.
- Preserved the complete ruined-temple sprite's coordinate arrangement as one bundled asset.
- Flagged the dragon statue coordinates as unresolved because the supplied list contains four malformed `(,31)` entries and repeated coordinates. No corrections were guessed.

### Verification
- [x] Updated the catalog and development log on GitHub `main`.
- [ ] Visually cross-check each listed asset against `ruined_temple_exterior_objects_labeled.svg`.
- [ ] Confirm the dragon statue coordinates before documenting it as placement-ready.
- [ ] Godot placement, collision, layering, and runtime behavior remain unverified.

---

## 2026-10-14 — Add Ruined Temple Exterior Objects Reference

- Added `docs/tileset_reference/generated/ruined_temple_exterior_objects_labeled.svg`, a self-contained coordinate atlas sourced from `assets/tilesets/dungeons/ruined_temple/Exterior_objects.png`.
- Source dimensions: 352×656 pixels; atlas grid: 22 columns × 41 rows using 16×16 source cells. Coordinates are zero-based `(column, row)`.
- Registered the source sheet in `tools/generate_tileset_reference.py` so the reference can be regenerated locally.
- This is a visual reference only; no gameplay assets or scenes were changed.
- Verification: SVG source and embedded PNG dimensions checked during generation. Visual cross-check and Godot runtime verification are pending.

## 2026-10-14 — Catalog Walls, Floors, Windows, and Doors

### Changes
- Added the user's confirmed `walls_floor_labeled.svg` coordinates to `docs/MAP_MAKING_RULESET.md`.
- Classified the four-cell window bundle as Foreground because it renders over the wall; preserved its transparent openings.
- Recorded the stone wall bundles and open/closed door bundles under Objects.
- Recorded seven wooden floor cells as separate, individually placeable Ground tiles that can be mixed for visual variation without requiring procedural room generation.
- Preserved all supplied source coordinates and documented the existing separate door-transition trigger rule.

### Verification
- [x] Updated the ruleset on GitHub `main`.
- [x] Confirmed the catalog records the user's coordinates and stated layer decisions.
- [ ] Visually cross-check the assets against `walls_floor_labeled.svg` and verify placement, layering, collision, and door transitions in Godot. Runtime verification remains pending.

---

## 2026-10-14 — Add Missing House and Interior Tile References

### Changes
- Generated and committed `docs/tileset_reference/generated/house_details_labeled.svg` from `assets/tilesets/towns/towns/house_details.png`.
- Generated and committed `docs/tileset_reference/generated/walls_floor_labeled.svg` from `assets/tilesets/towns/towns/walls_floor.png`.
- Both references use the generator's 16 × 16 source-cell grid and zero-based coordinate labels.
- Corrected the tileset catalog note to reflect that generated SVGs embed the source PNG, so the references are self-contained.

### Verification
- [x] Confirmed source PNG dimensions and generated grid counts: house details 10 × 17 cells; walls/floor 9 × 11 cells.
- [x] Confirmed both SVG files were created on GitHub `main`.
- [ ] Open both references and visually inspect the atlas contents; Godot placement/runtime verification is not part of this documentation/reference generation step.

---

## 2026-10-14 — Move Town House and Door Entries Under Objects

### Changes
- Moved the complete town house bundle and town exterior door bundle into the town exterior catalog's `Objects` section in `docs/MAP_MAKING_RULESET.md`.
- Added an explicit layer note stating that both belong on the `Objects` TileMapLayer.
- Kept the door's scene-transition trigger distinct from ordinary building/object collision.
- Preserved the existing coordinate lists and bundle descriptions without changing any source coordinates.

### Verification
- [x] Confirmed the house and door entries are now under the town exterior `Objects` section.
- [x] Confirmed the recorded coordinate lists and arrangement notes were preserved.
- [ ] Visual cross-check against the labeled SVG and Godot placement/runtime verification remain pending.

---

## 2026-10-14 — Clarify Building and Door Object Collision Rules

### Changes
- Clarified that complete houses/buildings and doors belong on the `Objects` TileMapLayer.
- Required collision for both building bundles and door assets.
- Distinguished ordinary solid building/object collision from a dedicated door scene-transition trigger, which must activate the transition without making the surrounding building passable.
- Updated the verification checklist to include building collision and door-transition trigger checks.

### Verification
- [x] Updated the map-making ruleset documentation on GitHub `main`.
- [ ] Verify actual house/door placement, collision shapes, and scene-transition behavior in Godot. Runtime verification remains pending.

---

## 2026-10-14 — Catalog Town Exterior Door Bundle

### Changes
- Added the door coordinates `(6,6), (7,6), (6,7), (7,7)` from `town_exterior_labeled.svg` to the map-making ruleset.
- Recorded the supplied coordinates as one 2 × 2 atlas-cell bundle.
- Flagged that the user's “4×4 door” label does not match the listed atlas footprint if it means 4 × 4 cells; no coordinate changes were guessed.

### Verification
- [x] Checked the coordinate list's row/column footprint.
- [ ] Confirm door appearance and intended size against the SVG.
- [ ] Godot placement/runtime verification remains pending.

---

## 2026-10-14 — Catalog Complete Town House Sprite

### Changes
- Added the complete house sprite from `town_exterior_labeled.svg` to `docs/MAP_MAKING_RULESET.md`.
- Recorded the full coordinate arrangement as one bundled asset spanning a 10 × 8 atlas-cell footprint.
- Preserved intentionally empty cells in the footprint and clarified that the coordinates are source-atlas positions, not destination map positions.
- No source artwork or Godot scenes were changed.

### Verification
- [x] Transcribed the user's coordinate list row by row into the map-making ruleset.
- [ ] Visually cross-check the complete bundle against `town_exterior_labeled.svg` before placing it in a map.
- [ ] Godot editor/runtime placement remains unverified.

---

## 2026-10-14 — Preserve Manual Overworld Collision Adjustments

### Changes
- Changed `world/maps/overworld/world.gd` so `GeneratedObjectCollisions` is generated only when the container is absent.
- Removed automatic deletion and regeneration of existing collision nodes. Manually adjusted `StaticBody2D` and `CollisionShape2D` nodes now remain intact across tool-script refreshes, scene reloads, and runtime instantiation when the scene has been saved with those nodes.
- Documented the reset workflow: deleting `GeneratedObjectCollisions` manually intentionally discards its adjustments and allows the script to generate default collisions again.
- Left `world.tscn` unchanged in this commit to avoid overwriting any local collision edits.

### Verification
- [x] Reviewed the collision generation path to confirm an existing container returns before any generated nodes can be removed or modified.
- [x] Updated `docs/MAP_MAKING_RULESET.md` with the persistence and reset rules.
- [ ] Pull `origin main`, save `world/maps/overworld/world.tscn` after any collision adjustments, then reopen the scene and confirm the adjusted shapes remain.
- [ ] Run the overworld and verify all object collisions. Godot editor/runtime verification remains pending.
- Note: this source change preserves local scene adjustments but does not upload local-only edits to GitHub. The edited scene must be committed separately if those exact adjustments should also exist in the repository.

---

## 2026-10-14 — Generate Object Collision From Sprite Transparency

### Changes
- Replaced full-bundle rectangular object colliders with collision generated from the actual exterior atlas texture's alpha channel.
- The generator reads each placed bundle's source atlas cells, marks visible pixels as solid, merges contiguous horizontal runs vertically, and creates compact rectangle shapes.
- Transparent holes and margins inside trees, rocks, and bushes are now excluded from collision automatically.
- Updated `docs/MAP_MAKING_RULESET.md` to require alpha-derived collision for every `Objects`-layer asset.

### Verification
- [x] Collision definitions cover all 20 placed objects: 10 trees, 5 rock bundles, and 5 bushes.
- [x] Reviewed the generated alpha-mask and run-merging logic for transparent-pixel exclusion.
- [ ] Pull `origin main`; run the overworld in Godot and inspect collisions against the actual imported sprite alpha.
- [ ] Verify no parse/runtime errors, opaque sprite pixels block movement, and transparent gaps remain passable.
- Runtime behavior remains **unverified locally** until tested in Godot.

---

## 2026-10-14 — Make Every Overworld Object Solid

### Changes
- Replaced undersized tree-trunk and compact rock collision shapes with colliders covering each object's complete placed tile-bundle footprint.
- Added collision to every placed bush, including single-tile bushes.
- Tree canopies now block movement as part of the full tree-bundle collider; bushes and rocks also block movement.
- Updated `docs/MAP_MAKING_RULESET.md` to require collision on every `Objects`-layer asset, including tree canopies and bushes.

### Verification
- [x] Compared collision definitions against all 20 placed objects: 10 trees, 5 rock bundles, and 5 bushes.
- [x] Confirmed the collider dimensions match each object's 3×3, 2×2, or single-tile placement footprint.
- [ ] Pull `origin main` and test trees (including canopies), rocks, and bushes in Godot.
- Runtime collision behavior remains **unverified locally** until the user tests the updated project.

---

## 2026-10-14 — Add Overworld Object Collision and Map-Making Rule

### Changes
- Added runtime-only collision bodies for the placed tree trunks and rock formations in `world/maps/overworld/world.gd`.
- Tree colliders cover the trunk/base rather than the entire canopy; rock colliders use compact footprints. Bushes remain passable.
- Kept collision on the established player-blocking collision layer with empty masks; map boundary logic remains unchanged.
- Updated `docs/MAP_MAKING_RULESET.md` to require an explicit collision decision for every world object, fitted collision geometry, and runtime route/collision testing.

### Verification
- [x] Reviewed each collider's destination against its matching object placement and map bounds.
- [x] Confirmed physics bodies are created only at runtime, avoiding duplicate editor-generated colliders.
- [ ] Pull `origin main`; test each tree trunk and rock from all reachable sides in Godot.
- [ ] Confirm tree canopies and bushes are passable where intended, paths remain open, and no debugger errors appear.
- Collision sizing and runtime behavior remain **unverified in Godot** until tested locally.

---

## 2026-10-14 — Extend Overworld With Catalogued Objects

### Changes
- Added complete evergreen tree bundles, rock bundles, and bush assets to the existing `Objects` TileMapLayer.
- Used only the documented source coordinates in `docs/MAP_MAKING_RULESET.md`; each multi-cell asset is copied as a contiguous bundle.
- Kept the 64×40 grass field, existing details, all four TileMapLayer nodes, player movement, and perimeter boundaries.
- Placed scenery mainly around the map edges to preserve an open central walking route.
- No Polygon2D, improvised graphics, canopy layering, or Foreground tiles were added.

### Verification
- [x] Confirmed used source coordinates and bundle dimensions against the catalog and existing TileSet atlas registrations.
- [x] Reviewed the placement script and ensured bundled cells remain contiguous.
- [ ] Pull `origin main`, open the overworld in Godot, and inspect every tree/rock/bush for visual correctness and bundle alignment.
- [ ] Run the game and check path clearance, collisions, and camera bounds.
- Runtime appearance and object collision remain **unverified**.

---

## 2026-10-14 — Shift-to-Run Runtime-Verified

- User confirmed the Shift-to-run feature works in Godot.
- Recorded the verified behavior in `docs/RUNTIME_VERIFIED.md`.
- Holding Shift while moving uses the run state/animation; releasing Shift returns to walking, and stopping returns to idle.
- This verification is limited to the behavior the user tested and does not imply every direction/key combination was separately checked.

---

## 2026-10-14 — Add Shift-to-Run Movement

### Changes
- Added a configurable `run_speed_multiplier` defaulting to `1.6`, so holding Shift while moving increases the player's speed.
- Connected the existing directional run sprite animations to the movement state; releasing Shift returns to the walk animation, and stopping returns to idle.
- Kept WASD and arrow-key movement, diagonal normalization, player collision, and camera behavior unchanged.
- No Input Map configuration is required.

### Verification
- [x] Reviewed the movement-state and animation selection logic.
- [x] Committed the change to GitHub `main`.
- [ ] Pull `origin main`; test Shift with WASD and arrow keys in all directions.
- [ ] Confirm run animation transitions cleanly to walk/idle and no debugger errors appear.
- Runtime running behavior is **not yet verified** in Godot.

---

## 2026-10-14 — Camera Bounds Runtime-Verified

- User confirmed that the reusable camera-bounds implementation works in Godot.
- Recorded the tested camera clipping behavior in `docs/RUNTIME_VERIFIED.md`.
- The current camera script calculates limits from populated `TileMapLayer` nodes. Universal use on future maps depends on those maps having populated tile layers and should be checked as they are added.

---

## 2026-10-14 — Add Reusable Camera Bounds for Tile Maps

### Changes
- Added `systems/map_camera_bounds.gd`, a reusable Camera2D script that finds the active scene's non-empty TileMapLayer bounds and applies them to the camera limits.
- Attached the script to the existing player Camera2D so maps using TileMapLayer nodes inherit bounds automatically without per-map dimensions.
- Preserved camera zoom, position smoothing, player movement, collision, and existing map art.
- Scenes without populated TileMapLayer nodes are left unchanged rather than assigned guessed limits.

### Verification
- [x] Reviewed the script's tile-edge conversion and world-coordinate handling.
- [x] Committed the reusable camera setup to GitHub `main`.
- [ ] Pull `origin main`, run the game, and check all four screen edges while moving the player.
- [ ] Verify any future map has populated TileMapLayer bounds before marking universal behavior runtime-verified.
- Runtime camera clipping is **not yet verified** in Godot.

---

## 2026-10-14 — Overworld Boundaries Runtime-Verified

- User confirmed the overworld perimeter collision fix is working in Godot.
- The four invisible boundary walls are created at runtime by `world.gd`, avoiding the broken serialized parent paths in `world.tscn`.
- Recorded the tested behavior in `docs/RUNTIME_VERIFIED.md`.
- Scope is limited to the overworld boundary behavior tested; other maps and unrelated collisions are not implied to be verified.

---

## 2026-10-14 — Replace Fragile Scene-File Boundary Nodes

### Issue
- Repeated Godot warnings reported that the `CollisionShape2D` parent path for the overworld boundary had vanished, despite corrections to the scene file.

### Fix
- Removed the four boundary bodies and collision shapes from `world.tscn` to eliminate the failing serialized parent paths entirely.
- Added runtime construction of the four invisible `StaticBody2D` perimeter walls in `world.gd`, with each collision shape attached through `add_child()`.
- Preserved all existing TileMapLayers, tileset references, and map-art generation. The walls are created only at runtime, not in the editor.

### Verification
- [x] Removed the problematic serialized boundary child paths on GitHub `main`.
- [ ] Pull and run in Godot; confirm warnings are gone and test all four edges and corners.
- Runtime collision behavior remains **unverified** until locally tested.

---

## 2026-10-14 — Correct Boundary Collision Shape Parenting

### Issue
- User-reported warning showed the collision-shape node parent path was still unresolved.

### Fix
- Corrected the scene's direct-child parent paths to use Godot's scene-relative names without a leading `./`.
- Reattached each `CollisionShape2D` to its matching `StaticBody2D`; shapes use local origin while the parent body sets the boundary position.
- Kept the existing TileMapLayers, tile resources, and invisible rectangular boundary geometry unchanged.

### Verification
- [x] Corrected scene structure committed to GitHub `main`.
- [ ] Pull and run in Godot; verify all parent-path warnings are gone and test all four edges and corners.
- Runtime collision remains **unverified** until locally tested.

---

## 2026-10-14 — Fix Overworld Boundary Instantiation Warnings

### Issue
- User-reported Godot warnings showed boundary child nodes could not resolve nested parent paths, so the collision walls were not instantiated and did not block the player.

### Fix
- Removed the unnecessary `MapBoundaries` container and placed each `StaticBody2D` directly under the world root.
- Kept each collision shape as a child of its corresponding static body.
- Preserved the existing TileMapLayers and invisible rectangular boundary geometry.

### Verification
- [x] Scene parent paths reviewed and corrected on GitHub `main`.
- [ ] Pull and run in Godot; confirm the parent-path warnings are gone and test all four edges and corners.
- Runtime collision behavior remains **unverified** until the user retests.

---

## 2026-10-14 — Add Overworld Perimeter Collision

### Changes
- Added four invisible `StaticBody2D` boundary walls to `world/maps/overworld/world.tscn`, aligned to the perimeter of the 64×40 tile map (1,024×640 world pixels).
- Reused two simple `RectangleShape2D` resources for horizontal and vertical walls.
- Set the walls to the player's collision layer and kept their collision masks empty, so they block the player without trying to move or detect other physics bodies.
- Preserved the existing `Ground`, `Details`, `Objects`, and `Foreground` TileMapLayers, TileSet, map script, player capsule, and all artwork. No visible border art or `Polygon2D` was added.

### Verification
- [x] Scene structure and map dimensions inspected on GitHub `main`.
- [x] Boundary positions and rectangle sizes reviewed against the 1,024×640 map bounds.
- [ ] Pull `origin main`, run the game, and test all four edges and corners.
- Runtime collision behavior is **not yet verified**.

---

## 2026-10-14 — Record Player Capsule Collision Verification

### Verification
- User confirmed the current player capsule-collision setup and the collision-shape policy are verified in their tested build.
- Player and NPC bodies should use `CapsuleShape2D` by default; enemy shapes remain case-by-case.
- This does not claim that all existing NPC scenes have already been converted or that enemy collision shapes are verified.
- Added the user-reported result to `docs/RUNTIME_VERIFIED.md`.

---

## 2026-10-14 — Establish Character Collision-Shape Policy

### Decisions
- Player and NPC collision bodies should use `CapsuleShape2D` by default.
- Enemy collision shapes will be assessed individually rather than forced into one standard.
- Collision geometry should fit the visible character body, accounting for transparent padding in sprite frames.
- Godot has no general automatic sprite-alpha “wrap collision” option for `CollisionShape2D`; capsule size and offset must be fitted manually. The result is a practical physics shape, not a pixel-perfect outline.

### Status
- Documented the standing policy in `docs/ARCHITECTURE.md`.
- This records a design rule; it does not claim that every existing NPC has been updated or verified.

---

## 2026-10-14 — Replace Player Rectangle With Capsule Collision

### Changes
- Replaced the 64×64 rectangle collision with a `CapsuleShape2D` using radius `10` and height `32` to better fit the character's body instead of the full transparent animation frame.
- Kept the collision center at `(0, -24)`, aligned with the sprite frame position.
- Preserved the sprite setup, scene hierarchy, and camera settings.

### Verification
- [x] Scene change committed directly to GitHub `main`.
- [ ] Pull `origin main` and inspect the capsule outline against the visible character in the 2D editor.
- [ ] Run the game and test movement along walls and around objects; adjust capsule dimensions or vertical position if needed.

---

## 2026-10-14 — Align Player Collision With Sprite Frame

### Changes
- Changed the player's `RectangleShape2D` from 18×14 to 64×64 pixels, matching the existing sprite animation frame dimensions.
- Moved `CollisionShape2D` to `(0, -24)`, matching the `AnimatedSprite2D` position so their frame rectangles align.
- Preserved the existing player scene hierarchy, sprite sheets, animation setup, and camera settings.

### Verification
- [x] Scene change committed directly to GitHub `main`.
- [ ] Pull `origin main` and confirm the collision rectangle matches the 64×64 sprite frame in Godot's 2D editor.
- [ ] Run the game and verify collision behavior feels correct; exact frame-sized collision includes transparent padding.

---

## 2026-10-14 — Keep Player Sprite Visible in the Godot Editor

### Changes
- Added `@tool` to `player/player.gd` so its existing sprite-sheet animation frames are built when the player scene is opened in the editor.
- Kept the existing idle, walk, and run sheets, 64×64 frame size, animation timing, and transparent-frame filtering.
- Guarded physics movement with `Engine.is_editor_hint()` so the player cannot move around while the scene is being edited.
- Left the player scene hierarchy, collision shape, and camera settings unchanged.

### Verification
- [x] Script change committed directly to GitHub `main`.
- [ ] Pull `origin main`, reopen the player or main scene, and confirm the player sprite is visible in the 2D editor before pressing Play.
- [ ] Confirm no tool-script errors appear in the editor debugger and movement still works at runtime.

---

## 2026-10-14 — Keep Overworld Visible in the Godot Editor

### Changes
- Added the `@tool` annotation to `world/maps/overworld/world.gd` so the existing deterministic ground and grass-leaf layout is generated when the scene is opened in the editor, not only when the game runs.
- Kept the existing `Ground`, `Details`, `Objects`, and `Foreground` TileMapLayers and existing TileSet resources unchanged.
- No Polygon2D, substitute artwork, or atlas-coordinate changes were introduced.

### Verification
- [x] Script change committed directly to GitHub `main`.
- [ ] Pull `origin main`, reopen the overworld scene in Godot, and confirm the grass and leaves are visible in the 2D editor before pressing Play.
- [ ] Confirm the editor debugger shows no tool-script errors.

---

## 2026-10-14 — Scatter Grass-Leaf Bundles Across Overworld

### Changes
- Added user-confirmed grass-leaf atlas cells from `ground_grass_details.png` (TileSet source ID `1`) to the existing `Details` TileMapLayer.
- Placed bundle A using atlas cells `(11, 15)` and `(12, 15)`, and bundle B using `(13, 15)` and `(14, 15)`. Each pair is placed on adjacent map cells by a shared helper.
- Scattered 12 two-cell bundles and 11 single-leaf accents around the 64×40 field.
- Preserved the existing scene layers and base grass tile. No Polygon2D or invented art was added.
- Updated the tileset catalog with the confirmed leaf-cell classifications.

### Verification
- [x] User previously confirmed the base-grass field is runtime-verified.
- [x] Script places each leaf bundle as two adjacent cells on the `Details` layer.
- [ ] Pull `origin main` and inspect the new leaf placements in Godot. This decoration pass has not yet been runtime-verified.

---

## 2026-10-14 — Rebuild Overworld Ground With Confirmed Grass Cell

### Changes
- Used the user's confirmed base-grass atlas coordinate: `exterior.png`, source ID `0`, atlas `(1, 12)`.
- Reattached `world/maps/overworld/world.gd` to the existing overworld scene and added a deterministic 64×40 ground fill.
- Preserved the existing `Ground`, `Details`, `Objects`, and `Foreground` TileMapLayer` nodes and the existing TileSet resource.
- Did not add Polygon2D, hand-drawn geometry, or guessed prop coordinates.
- Updated the tileset catalog to record the confirmed ground cell and distinguish it from still-unverified props and path tiles.

### Verification
- [x] Confirmed the existing scene and TileSet resource before editing.
- [x] Ground fill uses source ID `0` and atlas coordinate `(1, 12)` only.
- [ ] Pull `origin main` and run the scene in Godot to verify the selected cell visually tiles cleanly.
- [ ] Add paths, trees, and other props only after exact atlas regions are visually identified. Runtime/editor verification remains pending.

---

## 2026-10-14 — Remove Pillow Dependency From Tileset Reference Generator

### Changes
- Reworked `tools/generate_tileset_reference.py` to use only the Python standard library.
- The generator now writes SVG atlas references with checkerboard backgrounds, 16×16 grid lines, and zero-based cell labels. The SVGs link to the original PNGs using relative paths.
- Updated `docs/OVERWORLD_TILESET_CATALOG.md` to document the SVG output and browser viewing workflow.
- No package installation is required.

### Verification
- [x] Reviewed the generator's PNG-header dimension reading and output-path construction.
- [x] Changes committed to GitHub `main`.
- [ ] Run the generator locally and open both SVG references to verify the rendered output.

---

## 2026-10-14 — Add Overworld Tileset Catalog and Coordinate References

### Findings
- Visually inspected the actual `exterior.png` and `ground_grass_details.png` images from GitHub, not example art.
- `exterior.png` is a transparent prop sheet with a building, fences/walls, bushes, trees, rocks, stumps, mushrooms, plants, and fountain-like objects.
- `ground_grass_details.png` is a transparent detail sheet with small earth/stone-like accents and green grass/plant tufts.
- Neither sheet contains a confirmed seamless opaque grass tile suitable for filling the whole ground layer. The prior repeated atlas cell `(0, 0)` from source ID 1 is a small transparent detail, not valid base ground.

### Changes
- Added `docs/OVERWORLD_TILESET_CATALOG.md` with asset dimensions, source IDs, category definitions, layer rules, placement workflow, and future-agent guardrails.
- Added `tools/generate_tileset_reference.py`, which generates enlarged, checkerboard-backed PNG sheets with every 16×16 cell labelled by zero-based `(x, y)` coordinate.
- Removed the unverified tile placements from `world/maps/overworld/world.tscn` rather than leaving a tiny detail repeated as ground or unverified details scattered over the map.
- Preserved the four existing TileMapLayer nodes: `Ground`, `Details`, `Objects`, and `Foreground`. No `Polygon2D` nodes or hand-drawn geometry were added.

### Verification
- [x] Source PNGs inspected visually from the repository.
- [x] TileSet resource checked for image references and source IDs.
- [x] Coordinate-reference generator and catalog committed to GitHub `main`.
- [x] Scene source checked to confirm all four TileMapLayer nodes remain and unverified tile data is removed.
- [ ] Run `python tools/generate_tileset_reference.py` locally to create the labelled reference sheets.
- [ ] Open the scene in Godot and verify the cleared scene state.
- [ ] Identify and add a proper base-grass asset before rebuilding the ground field. Godot editor/runtime behavior is not yet verified.

---

## 2026-10-14 — Rebuild Overworld From the Specified Asset Folder

### Changes
- Inspected the actual images in `assets/tilesets/overworld/`: `exterior.png` contains transparent environment props (including trees, rocks, fences, and a building), while `ground_grass_details.png` contains transparent ground-detail sprites. Neither image is a complete opaque grass ground texture.
- Replaced the guessed TileSet atlas-cell placement with region-based sprites sampled from those two exact sheets.
- Rebuilt `world/maps/overworld/world.gd` to draw a grass field and winding dirt path, scatter ground details, place trees/rocks around the map edges and in small groves, and leave a clear player spawn area.
- Simplified `world/maps/overworld/world.tscn` to run the overworld builder.
- Kept the main-scene player spawn at `Vector2(512, 320)`.
- Updated architecture and audit documentation.

### Verification status
- [x] Visually inspected both source PNG sheets before selecting asset regions.
- [x] Changes committed directly to GitHub `main`.
- [ ] Run in Godot and inspect the full map, sprite-region boundaries, player spawn, movement, and debugger output.
- Runtime behavior remains **unverified**. Some region rectangles are initial selections and may need adjustment after visual inspection in Godot.

---

## 2026-10-14 — Build Starter Overworld and Set Player Spawn

### Changes
- Added `world/maps/overworld/world.gd` to generate a 64×40 grass field from the existing overworld TileSet and scatter grass-detail tiles with a deterministic layout.
- Updated `world/maps/overworld/world.tscn` to use the existing TileSet on its map layers and run the map builder.
- Moved the main-scene player spawn to the center of the generated overworld at `Vector2(512, 320)`.
- Updated the architecture and audit documents to describe the map builder and distinguish implementation from runtime verification.

### Verification status
- [x] Inspected current project settings, main scene, player scene/script, overworld scene, TileSet, and runtime verification record before editing.
- [x] Committed changes directly to GitHub `main`.
- [ ] Run in Godot to confirm the grass atlas coordinates render as intended, the detail tiles look correct, and the player spawns and moves normally.
- Runtime behavior is **not yet verified**. The generated map is a starter field, not a finished world layout.

---

# Development Log

This file is append-only. Add new entries at the top; do not remove or rewrite historical entries.

## 2026-10-14 — Show Alpha-Based Object Collisions in the Editor

### Changes
- Changed the overworld tool script to generate the same alpha-derived object collision shapes in editor mode and at runtime.
- Grouped generated `StaticBody2D` and `CollisionShape2D` nodes under `GeneratedObjectCollisions`.
- Assigned editor scene ownership to generated collision nodes so they appear in the Scene tree and can be selected to inspect their shapes.
- Clear and rebuild the generated container on refresh to avoid duplicate or stale colliders.
- Kept the existing alpha-mask logic: opaque sprite pixels collide, transparent pixels remain passable. Map boundaries remain runtime-only.

### Verification
- [x] Source and documentation changes committed to GitHub `main`.
- [ ] Pull `origin main`, open `world/maps/overworld/world.tscn`, and inspect `GeneratedObjectCollisions` and its child shapes in the 2D editor.
- [ ] Run the game and test movement around tree canopies, trunks, rocks, and bushes. Godot editor/runtime verification remains pending.

---


## 2026-10-14 — Documentation Paths and Runtime Verification Record

### Changes
- Renamed the runtime verification record from `docs/RUNTIME_VERIFIED.txt` to `docs/RUNTIME_VERIFIED.md` without changing the recorded verification claim.
- Updated `docs/ARCHITECTURE.md` to reference the Markdown filename and the actual root-level location of this development log.
- Updated `README.md` with direct links to the architecture guide, audit, runtime verification record, and development log.

### Verification status
- GitHub file contents and paths were inspected on `main`.
- Documentation changes are committed to GitHub `main`.
- Godot runtime behavior was not tested as part of this documentation-only change.

---

## 2026-10-14 — Slow Idle Animations and Confirm North-Facing Idle Fix

### Changes
- Reduced the idle animation playback speed from 6 FPS to 3 FPS across all four directions so the idle motion feels calmer.
- Kept walk and run animation speeds unchanged.
- Removed per-cell warnings when transparent sprite-sheet cells are skipped. These blank cells are expected in the idle sheet and were cluttering the debugger.

### Verification
- [x] User confirmed the north-facing idle animation no longer disappears.
- [ ] Verify the slower idle animation timing locally in Godot.
- [ ] Confirm the debugger no longer reports warnings for expected transparent idle cells.

---

# Development Log

This file is append-only. Add new entries at the top; do not remove or rewrite historical entries.

## 2026-10-13 — Fix North-Facing Idle Animation

### Diagnosis
- The issue occurs while facing north and standing still, so the affected animation is `idle_up`, not `walk_up`.
- Inspected `Unarmed_Idle_without_shadow.png`: the north-facing row has only four visible frames, while the animation configuration requests twelve. The remaining cells are transparent and caused the sprite to disappear during idle playback.

### Fix
- The player animation builder now skips fully transparent cells instead of adding them to the animation. This code change is already committed to `main`.

### Verification
- [x] Camera zoom at 2.5x verified locally in Godot (reported by user).
- [ ] Confirm `idle_up` no longer disappears after pulling the animation fix and running the game locally.

---

## 2026-10-13 — Fix Blank Player Animation Frames and Verify Camera Zoom

### Changes
- Updated player animation-frame construction to skip fully transparent or out-of-bounds sprite-sheet cells. This prevents a blank cell in a directional walk cycle from making the player disappear for a frame.
- Recorded the reported local runtime verification that the 2.5x camera zoom is implemented and passes verification.

### Verification
- [x] Camera zoom set to 2.5x and verified locally in Godot (reported by user).
- [ ] Northward walking animation: pending local runtime verification after pulling this fix.
- [ ] Confirm no new animation warnings/errors in the Godot debugger.

---

This file is append-only. Add new entries at the top; do not remove or rewrite historical entries.

## 2026-10-13 — Increase Overworld Camera Zoom to 2.5x

### Changed
- Set the player scene's Camera2D zoom to `Vector2(2.5, 2.5)` so the player appears larger on screen.
- Preserved camera position smoothing.

### Verification
- Source change committed to `main`.
- Camera zoom was subsequently reported as verified locally in Godot.

---

This file is append-only. Add new entries at the top; do not remove or rewrite historical entries.

## 2026-10-13 — Initial Overworld Runtime Verification Passed

### Verified locally in Godot
- [x] Project launches successfully.
- [x] Player movement works with both WASD and arrow keys.
- [x] Player collision and camera tracking work.
- [x] SpriteFrames and animation playback work without errors.
- [x] Overworld assets render at the intended scale.

### Gate result
**PASS — Initial overworld and player foundation.** All five runtime checks were reported as passed. The earlier pending verification notes below are historical and are superseded by this entry.

### Next steps
1. Continue with the next planned migration/development gate.
2. Keep new systems isolated and verify them in Godot before marking them complete.
3. Preserve this log's history; add future entries above this one.

---

This file is append-only. Add new entries at the top; do not remove or rewrite historical entries.

## 2026-10-13 — Initial Overworld and Player Foundation

### Completed
- Restored a clean project baseline before asset integration.
- Added initial sprite assets and an overworld map.
- Added a repository and asset audit report.
- Added a reusable player movement script with sprite-animation support.
- Created a standalone player scene with collision and a tracking camera.
- Created a main scene combining the overworld and player.
- Set the overworld scene as the project's startup scene.
- Added support for both WASD and arrow-key movement.
- Fixed a GDScript type-inference parse error in the player animation script.
- Removed the hard-coded `idle_down` animation selection from the player scene so animation selection can wait until SpriteFrames are configured.

### Current implementation state
- The repository has a Godot project foundation, initial visual assets, an overworld scene, and a controllable player scene.
- The player scene includes collision and a camera that tracks the player.
- Player movement input supports WASD and arrow keys.
- Animation playback is not yet confirmed working. The latest commit deliberately removes the scene's hard-coded animation name because the SpriteFrames resource is currently null.

### Verification status
- **Source changes committed to `main`:** confirmed by the recent GitHub commit history.
- **Godot runtime verification:** pending. Repository commits alone do not prove the project launches or that movement, collisions, camera tracking, and animations work in the editor.
- **Known issue to verify:** the latest reported run had an animation error for `idle_down`. The scene was changed to defer selecting an animation until frames are configured. Confirm that the animation error is gone and then configure/verify the actual animation resource.
- **Next gate:** pull `origin main`, open the project in Godot, run the overworld, test WASD and arrow-key movement, confirm collision and camera tracking, and check the debugger for parse/runtime errors. Do not mark this gate passed until the local runtime test succeeds.

### Next steps
1. Verify project settings and startup scene in Godot.
2. Verify player movement, collision shape, and camera behavior.
3. Configure the player SpriteFrames resource and confirm the required animation names match the script.
4. Verify the imported overworld map and sprite assets render at the intended scale.
5. Update the audit documentation only after checking the actual repository paths and assets.


## 2026-10-14 — Overworld layout trial pass

### Changes
- Rebuilt `world/maps/overworld/world.gd` to populate the existing `Ground`, `Details`, `Objects`, and `Foreground` layers without deleting or replacing scene nodes.
- Kept all rendering on the existing TileSet and registered atlas tiles; no `Polygon2D`, custom-drawn shapes, or guessed image crops were added.
- Added a deterministic grass-detail scatter, a central clearing and winding route, and a sparse boundary-object trial using registered exterior atlas coordinates.
- Preserved a clear player spawn area so the first visual test has room for movement.

### Verification
- **GitHub source update:** committed to `main`.
- **Godot runtime verification:** pending. The atlas regions have not been visually confirmed against the PNGs, so the first local run is a trial pass. Check whether the exterior atlas tiles look like coherent environment pieces; adjust the coordinate list based on what actually renders.


## 2026-10-14 — Serialize overworld tiles in the scene

### Changes
- Saved base terrain and deterministic detail placements directly into `world/maps/overworld/world.tscn` using the existing TileSet resource.
- Preserved all four existing TileMapLayer nodes: `Ground`, `Details`, `Objects`, and `Foreground`.
- Removed the scene's runtime map-builder attachment and made `world.gd` inert so it no longer regenerates tiles when the game starts.
- Left `Objects` and `Foreground` empty rather than placing unverified atlas fragments that could create incomplete trees or props.
- Used registered atlas coordinates only; no `Polygon2D` or custom-drawn shapes.

### Verification
- **GitHub source update:** committed to `main`.
- **Godot editor/runtime verification:** pending. Base tile appearance and detail selections still require inspection in the local editor because the PNG artwork could not be visually confirmed here.


## 2026-10-14 — Add Havenreach Town Scene Scaffold

### Changes
- Added `world/maps/towns/havenreach/havenreach.tscn` as a separate town scene.
- Added the `Ground`, `Details`, `Objects`, and `Foreground` TileMapLayer nodes, all using the existing shared overworld TileSet resource.
- Added `Buildings` and `NPCs` containers plus a `PlayerSpawn` Marker2D for future map construction.
- Set the foreground layer to a higher Z index so it can render above the player when the map is integrated.
- Left all layers empty. No unverified atlas coordinates, placeholder art, collision bounds, or transition logic were added.

### Verification
- **GitHub source update:** committed to `main`.
- **Godot editor/runtime verification:** pending. Open the new scene locally and confirm the TileSet resource loads and the layer hierarchy appears as expected.
- **Coordinate-reference issue:** the repository's chapel exterior PNG header reports 256×336 pixels, while the expected dimensions supplied by the user are 256×304. The source image was not cropped or modified because the intended 32-pixel difference has not been visually confirmed.


## 2026-10-14 — Correct Chapel Atlas SVG Dimensions

### Changes
- Updated `tools/generate_tileset_reference.py` so a reference can show a clipped region of a source image without scaling or distorting the embedded image.
- Corrected `chapel_exterior_labeled.svg` to display the intended 256×304 atlas region (16 columns × 19 rows). The source PNG remains unchanged at 256×336; the reference clips the extra 32 pixels at the bottom rather than deleting source artwork.
- Regenerated `chapel_walls_interior_labeled.svg` from the current source PNG dimensions of 160×528 (10 columns × 33 rows). The previous SVG showed only 160×416 and stretched the embedded image into that smaller viewport.
- Kept coordinate labels zero-based and each cell at 16×16 source pixels.

### Verification
- **GitHub source update:** committed to `main`.
- **Static checks:** SVG viewport sizes and row/column counts were generated from the intended display dimensions; the interior reference now includes the full 528-pixel source height.
- **Godot editor/runtime verification:** pending. These are documentation references and do not alter gameplay assets.
- **Source asset unchanged:** `Exterior.png` was not cropped or overwritten. If the actual PNG itself must be exactly 256×304, its source artwork still needs confirmation before changing it.


## 2026-10-14 — Add Town Architecture Tileset References

- Added `assets/tilesets/towns/towns/house_details.png` to the labeled tileset reference generator as `house_details_labeled.svg`.
- Added `assets/tilesets/towns/towns/walls_floor.png` to the labeled tileset reference generator as `walls_floor_labeled.svg`.
- Both references will use the existing 16×16 tile grid and zero-based `(column, row)` labels.
- The source PNGs are unchanged. Generated references and their coordinate catalogs still require local generation and visual inspection.
