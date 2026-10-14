# Havenreach Runtime Verification Checklist

Run this checklist locally after pulling the latest `main`. These checks cannot be marked passed from static GitHub inspection alone.

## 1. Pull and import

- [ ] Run `git pull origin main`; confirm the working tree is clean before testing.
- [ ] Open `project.godot` in Godot 4.7.2 stable mono.
- [ ] Wait for asset imports to finish.
- [ ] Confirm there are no parse/import errors for `assets/tilesets/overworld/background.tres`, `world/maps/towns/havenreach/havenreach.gd`, or either Havenreach scene.
- [ ] Open `world/maps/towns/havenreach/havenreach_test.tscn` and use **F6 / Run Current Scene**.

## 2. Map appearance

- [ ] Grass fills the 64 × 40 map without blank cells.
- [ ] Four complete house bundles appear with no missing tiles or altered bundle arrangements.
- [ ] Chapel uses the real chapel exterior PNG and appears as one complete 8 × 10 bundle.
- [ ] Trees, rocks, bushes, and leaf/flower details use only existing atlas assets.
- [ ] The central approach remains open and the player spawns near the center of the settlement.
- [ ] House and chapel upper sections render over the player where intended; lower wall sections render behind the player.
- [ ] No duplicated, missing, or offset collision nodes appear after reopening the scene.

## 3. Movement and collisions

- [ ] Move in all four directions using the configured movement keys.
- [ ] Hold Shift while moving; running is faster than walking.
- [ ] Opaque tree, rock, bush, house, and chapel pixels block the player.
- [ ] Transparent gaps inside object sprites remain passable where the source artwork is transparent.
- [ ] The player can walk around each building and object without getting trapped.
- [ ] The four map edges prevent the player from leaving the 64 × 40 map.
- [ ] No debugger errors appear during movement or collision tests.

## 4. Camera and viewport

- [ ] Window opens at the configured 1152 × 648 baseline (16:9).
- [ ] Camera follows the player smoothly.
- [ ] Camera remains within the map at all four corners.
- [ ] The camera does not reveal empty space beyond the map edges.
- [ ] The settlement remains readable at the player camera's configured zoom.

## 5. Report

Record each section as PASS or FAIL. For failures, include the exact debugger error and a screenshot of the affected map region. Do not mark collision or camera behavior verified until it has been physically tested in-game.

**Known scope limit:** this test scene validates the map and player movement. Building-door scene transitions and interior entry are not implemented by this map scaffold.
