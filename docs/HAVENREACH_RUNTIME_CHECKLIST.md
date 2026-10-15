# Havenreach Runtime Verification Checklist

Run this checklist locally after pulling the latest `main`. These checks cannot be marked passed from static GitHub inspection alone.

## 1. Pull and import

- [ ] Run `git pull origin main`; confirm the working tree is clean before testing.
- [ ] Open `project.godot` in Godot 4.7.2 stable mono.
- [ ] Wait for asset imports to finish.
- [ ] Confirm there are no parse/import errors for `assets/tilesets/overworld/background.tres`, `assets/tilesets/towns/house_interior.tres`, `assets/tilesets/towns/church_interior.tres`, Havenreach scripts/scenes, or either interior script/scene.
- [ ] Open `world/maps/towns/havenreach/havenreach_test.tscn` and use **F6 / Run Current Scene**.

## 2. Map appearance

- [ ] Grass fills the 64 × 40 map without blank cells.
- [ ] Four complete house bundles appear in an irregular, scattered layout with no missing tiles or altered bundle arrangements.
- [ ] Chapel uses the real chapel exterior PNG and appears as one complete 8 × 10 bundle.
- [ ] Trees, rocks, bushes, and leaf/flower details use only existing atlas assets.
- [ ] The central approach remains open and the player spawns near the center of the settlement.
- [ ] House and chapel layers render as intended; collisions follow opaque roof and wall pixels, not the full rectangular footprint.
- [ ] No duplicated, missing, or offset collision nodes appear after reopening the scene.

## 3. Movement and collisions

- [ ] Move in all four directions using the configured movement keys.
- [ ] Hold Shift while moving; running is faster than walking.
- [ ] Trees, rocks, bushes, houses, and chapel block only on opaque sprite pixels, using the same alpha-derived collision method.
- [ ] Transparent gaps inside all object sprites, including buildings, remain passable where the source artwork is transparent.
- [ ] The player can walk around each building and object without getting trapped.
- [ ] The four map edges prevent the player from leaving the 64 × 40 map.
- [ ] No debugger errors appear during movement or collision tests.

## 4. Camera and viewport

- [ ] Window opens at the configured 1152 × 648 baseline (16:9).
- [ ] Camera follows the player smoothly.
- [ ] Camera remains within the map at all four corners.
- [ ] The camera does not reveal empty space beyond the map edges.
- [ ] The settlement remains readable at the player camera's configured zoom.

## 5. Building and church interiors

- [ ] Walk to each visible house door; verify its entrance trigger can be reached and loads `house_interior.tscn`.
- [ ] Verify the house interior floor and single north back wall render correctly; there should be no interior door artwork or stone side walls.
- [ ] Walk through the house interior exit; verify the Player returns outside the same house instead of immediately re-entering.
- [ ] Walk to the chapel's centered entrance; verify the door is reachable and loads `church_interior.tscn`.
- [ ] Verify the church floor, back wall, portrait, and two pillar bundles render correctly and leave a clear central aisle.
- [ ] Walk through the church interior exit; verify the Player returns outside the chapel without a transition loop.
- [ ] Confirm the interior room boundaries block movement at the room edges while the south exit trigger remains reachable.
- [ ] Confirm each interior camera is centered on the room and remains fixed while the Player moves; returning to Havenreach restores player-follow camera behavior.
- [ ] Add the catalogued half-rug asset at each interior exit and align the exit collision to it.
- [ ] Confirm transition messages identify the home and chapel correctly.
- [ ] No debugger errors appear during any entry or exit.

## 6. Report

Record each section as PASS or FAIL. For failures, include the exact debugger error and a screenshot of the affected map region. Do not mark any new interior or doorway check passed until it has been run in Godot. Re-run these checks after layout/collision changes to catch regressions.

**Known scope limit:** interior camera centering and the house back-wall correction are committed but need local Godot runtime verification. The half-rug atlas coordinates must be identified from `assets/tilesets/towns/towns/Interior.png` before adding rug artwork. The church NPC and save system are intentionally deferred to later stages.
