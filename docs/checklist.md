# Implementation Checklist

This checklist tracks gameplay systems that still need to be built or ported into `cubed-souls`. Priority order is provisional and can be adjusted as implementation dependencies become clearer.

## Priority 1 — NPC scenes

- [ ] **Source implemented; runtime verification pending.** Added `world/actors/npc/npc.tscn` and `npc.gd` with the player’s sprite sheets/animation layout, matching capsule body dimensions, configurable stationary/wander/patrol movement, and E-key multi-line dialogue. Dialogue pauses player movement. Pull and test in Godot before checking this item off.

## Priority 2 — Scene transitions

- [ ] **Status: Not ported.** Inspect the previous `Scripts` repository and port/adapt its scene-transition system into this project. Support changing between map scenes and define how the player spawn/entry point is selected.

## Priority 3 — Quest system

- [ ] **Status: Not ported.** Inspect the previous `Scripts` repository and port/adapt its quest system. Preserve the separation between quest progress, story flags, and world state; verify compatibility with the new NPC and scene-transition systems.

## Completion rules

- Do not mark an item complete merely because code is committed.
- Run the project in Godot and record runtime verification separately.
- Keep changes on `main`, and append development-log entries rather than rewriting history.
