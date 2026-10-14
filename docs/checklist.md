# Implementation Checklist

This checklist tracks gameplay systems that still need to be built or ported into `cubed-souls`. Priority order is provisional and can be adjusted as implementation dependencies become clearer.

## Priority 1 — NPC scenes

- [x] **Runtime verified by user:** NPC scripts parse without errors; Player/NPC collision and NPC movement behavior work in the isolated test scene.
- [ ] **Still needs runtime verification:** E-key multiline dialogue, Player movement lock during dialogue, and the three NPCs' visibility/placement in the actual Havenreach scene.
- **Implemented in source:** Stationary, Civilian, Guard, and Ally profiles; bounded civilian/ally wandering; guard patrol routes; obstacle steering and stuck recovery; optional story-target movement; reusable NPC scene and individual per-instance dialogue.

## Priority 2 — Scene transitions

- [x] Added the persistent `SceneManager` autoload and reusable `MapTransitionTrigger`.
- [x] Added the overworld east-edge entry into Havenreach and four Havenreach exits that return to the saved safe overworld position.
- [x] **Runtime verified by user:** overworld → Havenreach entry and fade work.
- [ ] **Regression/fix pending runtime retest:** leaving Havenreach failed in the user's test. Exit trigger strips have been widened and moved farther inside the map; verify all four exits, safe return position, fade overlay, and absence of debugger errors.

## Priority 3 — Quest system

- [ ] **Status: Not ported.** Inspect the previous `Scripts` repository and port/adapt its quest system. Preserve the separation between quest progress, story flags, and world state; verify compatibility with the new NPC and scene-transition systems.

## Completion rules

- Do not mark an item complete merely because code is committed.
- Run the project in Godot and record runtime verification separately.
- Keep changes on `main`, and append development-log entries rather than rewriting history.
