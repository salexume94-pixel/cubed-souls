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

