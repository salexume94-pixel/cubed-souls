# Runtime-Verified Record

**Repository:** `salexume94-pixel/cubed-souls`  
**Canonical branch:** `main`

## Purpose

This file is the single record of behavior that has been observed running in Godot. Keep runtime evidence separate from architecture, repository audits, static checks, assumptions, and proposed behavior.

## Rules

- Add an item only after behavior has actually been observed in the Godot runtime.
- User-reported tests count when explicitly reported by the user; label them as user-reported.
- Record the date, exact behavior tested, result, and any limits to what the test proves.
- Do not infer that neighboring features are verified.
- If a regression occurs, retain the history and append a dated regression/retest entry. Do not silently erase earlier results.
- Code review, successful commits, file presence, resource references, and static checks are not runtime verification.
- Keep unverified tests and hypotheses in the relevant audit or task notes, not here.

## Runtime-Verified Items

### 2026-10-14 — Havenreach Return Transition Retest

**Status:** PARTIALLY VERIFIED — user-reported; return transition now succeeds.

**Evidence:** The user reported that after the SceneManager active-map lookup fix, leaving Havenreach returns the Player to the overworld and the Godot debugger shows no errors.

**Result:** Havenreach → overworld map return is working in the tested build without reported errors.

**Scope limits:** The user has not yet confirmed that the Player returns to the exact saved overworld position. All four Havenreach edge exits, house-door access, and doorway approach clearance have not been individually verified by this report.

---


### 2026-10-14 — Havenreach Transition Partial Test and Exit Regression

**Status:** PARTIALLY VERIFIED — user-reported; exit regression observed.

**Evidence:** The user confirmed that entering Havenreach from the overworld and its transition effect worked. The user then reported that leaving Havenreach failed.

**Result:** Overworld → Havenreach entry is verified for the tested build. Havenreach → overworld return is not working reliably in that build and must not be marked complete until retested.

**Follow-up:** Exit triggers were widened and moved inward across the full town edges; house doorway collision and approach clearance were updated. These source fixes remain unverified until the user pulls and tests them in Godot.

---


### 2026-10-14 — NPC Movement and Collision Smoke Test

**Status:** VERIFIED — user-reported.

**Evidence:** The user ran the NPC test scene in Godot and reported no errors, working collision, and working NPC movement.

**Result:** NPC scripts parse successfully in the tested build; Player/NPC collision and NPC movement behavior are working.

**Scope limits:** This does not yet verify E-key dialogue progression, movement locking during dialogue, or visibility/placement of the NPC instances in the Havenreach town scene.

---

### 2026-10-14 — Source-Alpha Object Collision Trial

**Status:** VERIFIED — user-reported.

**Evidence:** The user explicitly reported that the alpha-based object collision trial is runtime verified in Godot.

**Result:** Record the re-enabled alpha-derived collision trial for overworld and Havenreach as tested in the user's current build.

**Scope limits:** This records the user's confirmation that the trial ran as expected at the time of testing. It does not independently establish pixel-perfect collision on every asset or verify later NPC movement changes.

---

### 2026-10-14 — Preserve Manual Overworld Collision Adjustments

**Status:** VERIFIED — user-reported.

**Evidence:** The user pulled the updated `main` branch, tested the project in Godot, and confirmed that their collision adjustments persisted.

**Result:** Existing `GeneratedObjectCollisions` adjustments are preserved by the updated generation logic in the tested project after pulling the change and running the game.

**Scope limits:** This verifies persistence only. Final collision sizing, obstacle coverage, and movement clearance still need to be tuned and tested by the user. It does not establish that every overworld object collision is correctly fitted.

---


### 2026-10-14 — Shift-to-Run Movement

**Status:** VERIFIED — user-reported.

**Evidence:** The user explicitly confirmed that the run feature works in Godot.

**Result:** Holding Shift while moving activates the run behavior and directional run animation. Releasing Shift returns to walking, and stopping returns to idle.

**Scope limits:** This verifies the behavior tested by the user. It does not independently verify every keyboard/direction combination or other movement systems.

---

### 2026-10-14 — Universal Tile-Map Camera Bounds

**Status:** VERIFIED — user-reported.

**Evidence:** The user explicitly confirmed that the reusable camera-bounds implementation works in Godot.

**Result:** The player camera stays within the bounds calculated from populated `TileMapLayer` nodes, preventing the grey area outside the map from appearing in the tested build.

**Scope limits:** This verifies the camera behavior in the tested map/build. Other maps must use populated `TileMapLayer` nodes and should be tested when introduced; scenes without such bounds are intentionally left unrestricted.

---


### 2026-10-14 — Player idle slowdown

**Status:** VERIFIED — user-reported.

**Evidence:** The user explicitly reported that idle slowdown is runtime verified.

**Result:** Treat the idle slowdown issue as resolved for the tested build.

**Scope limits:** This confirms only the idle slowdown behavior reported by the user. It does not verify movement in every direction, animations, collisions, map loading, transitions, or other gameplay systems.

---

### 2026-10-14 — Player capsule collision and character collision policy

**Status:** VERIFIED — user-reported.

**Evidence:** The user explicitly confirmed that the player/NPC capsule-collision decision and the related collision setup are verified.

**Result:** Record the current player capsule collision setup as verified for the user's tested build. The standing design policy is to use `CapsuleShape2D` for player and NPC bodies by default, while assessing enemy collision shapes individually.

**Scope limits:** This does not establish that every NPC has already been converted to a capsule, nor does it verify any enemy collision shape. NPC-by-NPC implementation and enemy collision sizing remain to be checked when those actors are added or audited.
### 2026-10-14 — Overworld perimeter collision

**Status:** VERIFIED — user-reported.

**Evidence:** The user explicitly confirmed that the overworld boundary fix is working in the Godot runtime after the boundary implementation was changed.

**Result:** The four runtime-created perimeter walls prevent the player from leaving the overworld map in the tested build.

**Scope limits:** This confirms the boundary behavior tested by the user. It does not verify collision behavior on other maps or unrelated player/world interactions.

---

