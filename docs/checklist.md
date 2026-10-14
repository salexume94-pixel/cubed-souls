# Implementation Checklist

This checklist tracks gameplay systems that still need to be built or ported into `cubed-souls`. Priority order is provisional and can be adjusted as implementation dependencies become clearer.

## Priority 1 — NPC scenes

- [ ] **Status: Not implemented.** Create reusable NPC scene(s) with a base script, sprite/animation setup, collision, and an interaction hook. Keep character identity and role-specific behavior configurable so NPC roles can be assigned afterward.

## Priority 2 — Scene transitions

- [ ] **Status: Not ported.** Inspect the previous `Scripts` repository and port/adapt its scene-transition system into this project. Support changing between map scenes and define how the player spawn/entry point is selected.

## Priority 3 — Quest system

- [ ] **Status: Not ported.** Inspect the previous `Scripts` repository and port/adapt its quest system. Preserve the separation between quest progress, story flags, and world state; verify compatibility with the new NPC and scene-transition systems.

## Completion rules

- Do not mark an item complete merely because code is committed.
- Run the project in Godot and record runtime verification separately.
- Keep changes on `main`, and append development-log entries rather than rewriting history.
