# Implementation Checklist

This checklist tracks gameplay systems that still need to be built or ported into `cubed-souls`. Priority order is provisional and can be adjusted as implementation dependencies become clearer.

## Priority 1 — NPC scenes

- [ ] **Source implemented; runtime verification pending.** `world/actors/npc/npc.tscn` and `npc.gd` reuse the player's sprite sheets and capsule dimensions, with Stationary, Civilian, Guard, and Ally profiles. Civilian/Ally wander within a home radius and make room for the Player; Guards follow authored patrol points or remain at post. Movement includes multi-ray obstacle steering, stuck recovery, and optional story-target movement. E-key multiline dialogue pauses the Player. The isolated test scene now includes all three moving profiles.

## Priority 2 — Scene transitions

- [ ] **Status: Not ported.** Inspect the previous `Scripts` repository and port/adapt its scene-transition system into this project. Support changing between map scenes and define how the player spawn/entry point is selected.

## Priority 3 — Quest system

- [ ] **Status: Not ported.** Inspect the previous `Scripts` repository and port/adapt its quest system. Preserve the separation between quest progress, story flags, and world state; verify compatibility with the new NPC and scene-transition systems.

## Completion rules

- Do not mark an item complete merely because code is committed.
- Run the project in Godot and record runtime verification separately.
- Keep changes on `main`, and append development-log entries rather than rewriting history.
