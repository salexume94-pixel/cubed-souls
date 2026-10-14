# Cubed Souls Architecture and Collaboration Guide

**Repository:** `salexume94-pixel/cubed-souls`  
**Primary branch:** `main`  
**Engine:** Godot 4.7, GDScript, GL Compatibility renderer  
**Purpose:** Keep implementation, verification, and communication consistent across ChatGPT, other agents, and local development.

## 1. Source of Truth

- GitHub `main` is the canonical source of truth.
- Before editing, inspect the current files on `main`; do not rely on old chat excerpts or assumed local state.
- Work directly on `main`. Do not create branches unless the user explicitly changes this rule.
- Never claim a change is committed, pushed, or runtime-tested unless the relevant action or evidence confirms it.
- The user runs Godot locally for runtime verification. A code review or successful commit is not runtime verification.
- Preserve user changes and existing history. Append to development logs; do not rewrite or remove earlier entries.

## 2. Current Project State

This repository is being rebuilt in stages. Gameplay systems must not be imported wholesale from the legacy Scripts repository. Identify and audit working systems first, then migrate them in the order below.

Current foundational files include:
- `project.godot`: project configuration and main-scene setting.
- `scenes/main.tscn`: main scene; currently instances the overworld and player.
- `scenes/tests/npc_test.tscn`: isolated NPC smoke-test scene; not configured as the game's startup scene.
- `player/player.tscn` and `player/player.gd`: player scene and movement/animation logic.
- `world/actors/npc/npc.tscn` and `world/actors/npc/npc.gd`: reusable NPC actor using shared player sprite sheets, capsule collision, stationary/civilian/guard/ally behavior profiles, obstacle probes, E-key dialogue, and optional story movement.
- `world/maps/overworld/world.tscn`: overworld scene.
- `world/maps/overworld/world.gd`: deterministic overworld generation, object collision, and the first Havenreach entry trigger.
- `systems/scene_manager.gd` and `systems/map_transition_trigger.gd`: persistent map swapping, fade overlay, and Player entry/exit placement; runtime verification is pending.
- `assets/`: source art, sprites, and tileset resources.
- `docs/AUDIT.md`: repository and asset audit, including explicit unverified items.
- `docs/OVERWORLD_TILESET_CATALOG.md`: required classification workflow and placement rules for overworld assets.
- `tools/generate_tileset_reference.py`: generates enlarged, coordinate-labelled references for the two overworld PNG sheets.

### Runtime verification record

- `docs/RUNTIME_VERIFIED.md` is the single source for recorded runtime-verified behavior.
- Keep runtime results out of this architecture document. Add only observed runtime behavior to the verification record, with date, evidence, result, and scope limits.
- Repository audits and sprite-sheet hypotheses belong in `docs/AUDIT.md`; they are not runtime verification.

## 3. Directory Responsibilities

Place each file according to its primary responsibility. Extend this structure only when a real system requires it.

| Path | Responsibility |
| --- | --- |
| `assets/sprites/` | Character, enemy, and other sprite images |
| `assets/tilesets/` | Tile images and Godot TileSet resources |
| `assets/audio/` | Music and sound assets |
| `player/` | Player scene, script, and player-specific resources |
| `world/actors/npc/` | Reusable NPC scene and configurable NPC behavior/dialogue |
| `world/maps/overworld/` | World/overworld maps and their scene resources |
| `world/maps/towns/` | Town maps |
| `world/maps/dungeons/` | Dungeon maps |
| `world/objects/` | Reusable world objects and interactable environment elements |
| `systems/` | Cross-scene gameplay services and managers, including map transitions |
| `ui/` | Menus, HUD, and interface scenes/scripts |
| `scenes/` | Main scene and high-level scene composition |
| `docs/` | Architecture, audits, runtime verification, migration decisions, and task handoffs |

Use paths that match the actual repository. Do not create speculative folders or placeholder systems merely because they appear in this table.

## 4. Migration Order and Verification Gates

Migrate only the necessary parts of each system, with resource paths and dependencies checked before moving on.

| Order | Component | Verification gate |
| ---: | --- | --- |
| 1 | Project settings and input | Renderer, viewport/window settings, input actions, and project configuration inspected and verified in Godot |
| 2 | Player | Movement, idle behavior, animation directions, collision, and scene references verified at runtime |
| 3 | Map loading and transitions | Map resources load, spawn/exit positions work, transitions behave correctly, and invalid map IDs fail clearly |
| 4 | Interaction and dialogue | Interaction targets, dialogue progression, and movement locks work without overlap or softlocks |
| 5 | Save/load and audio | Save/load restores required state; audio starts, changes, and persists as designed |
| 6 | Combat, party, inventory, progression | Core combat loop, party state, item state, rewards, and progression tested independently |
| 7 | Quests and story | Quest state, story flags, world state, prerequisites, and save/load integration remain distinct and consistent |
| 8 | Menus, polish, and debugging | Menus, settings, UI feedback, edge cases, and error handling verified |

A gate is not complete just because code parses. Record what was tested, the result, and anything still unverified.

## 5. Implementation Rules

1. **Inspect before editing.** Read the target script/scene, its callers, referenced resources, and relevant project settings.
2. **Prefer minimal changes.** Fix the named problem without unrelated refactors or feature additions.
3. **Keep responsibilities clear.** Player movement belongs in `player/`; shared orchestration belongs in `systems/`; map-specific content belongs in `world/`; UI behavior belongs in `ui/`.
4. **Avoid duplicate authorities.** Reuse an existing manager or data resource when it already owns the responsibility. Do not introduce a second manager for the same state.
5. **Keep resource references valid.** Check `res://` paths, scene/resource dependencies, class names, signal connections, and node paths after edits.
6. **Use explicit GDScript types where inference may fail.** Avoid parser errors caused by ambiguous Variant inference.
7. **Comment intent, not the obvious.** Explain non-obvious logic, section responsibilities, assumptions, and why a workaround exists.
8. **Do not silently alter project settings.** In particular, preserve the intended renderer and viewport/window configuration unless the task explicitly requires a change.
9. **Do not treat debug scaffolding as production gameplay.** Clearly label temporary tests and keep them isolated.
10. **No unrequested migration.** Do not bring in legacy gameplay code until the system has been inventoried, dependencies identified, and migration approved.

### Collision-shape policy

- Player and NPC bodies should use `CapsuleShape2D` by default.
- Collision layers separate static world geometry (layer 1), the Player (layer 2), and NPC actors (layer 3 / bitmask value 4). The Player collides with world geometry and NPC actors; NPCs collide with world geometry and other NPCs but do not physically collide with or push the Player. NPC interaction sensors detect the Player on layer 2.
- Enemy collision shapes are assessed case by case based on sprite silhouette and gameplay needs.
- Fit collision to the visible character body, not blindly to the full sprite-sheet frame when it contains transparent padding.
- Godot does not provide a general automatic “wrap collision shape to sprite alpha” option for `CollisionShape2D`. The capsule dimensions and offset must be chosen/adjusted manually, using the sprite's visible bounds as a reference. A capsule is an approximation, not a pixel-perfect alpha outline.
- Keep collision geometry simple and stable for movement and physics; do not replace it with a polygon or static-body generation workflow just to trace sprite pixels.

## 6. Verification Protocol

For each code/resource change:

1. Inspect the relevant files and dependencies on `main`.
2. Make the smallest appropriate change.
3. Review the diff for unrelated edits, broken paths, and accidental deletions.
4. Run available static/resource checks when applicable.
5. Ask the user to run the project in the Godot editor when runtime behavior must be confirmed.
6. Report results with one of these statuses:
   - **Code-reviewed:** inspected, but not runtime-tested.
   - **Static-checked:** relevant static/resource checks passed.
   - **Runtime-verified:** behavior was actually observed in Godot.
   - **Blocked:** state the exact missing evidence or failure.
7. Append a dated entry to `docs/DEVELOPMENT_LOG.md`. Never erase earlier log entries. Runtime verification results must also be recorded in `docs/RUNTIME_VERIFIED.md`.

Do not report a test as passed if it was not run. If the user supplies runtime results, record them as user-reported runtime verification.

## 7. Efficient Communication Contract

Use this compact handoff format for tasks and agent-to-agent communication:

```text
GOAL:
TARGET FILES:
CURRENT EVIDENCE:
CHANGE MADE:
CHECKS RUN:
RUNTIME STATUS:
REMAINING RISKS:
NEXT STEP:
```

Communication rules:
- Start with the exact goal and current state; avoid retelling the entire project history.
- Separate **facts**, **assumptions**, and **proposals**.
- Name exact repository-relative paths and relevant function/node names.
- Report the specific error and line when debugging; include the smallest useful log excerpt.
- List files changed and why. Explicitly state when no files were changed.
- Do not repeat checks already verified unless a new change could invalidate them.
- When blocked, identify the single concrete blocker and the evidence needed to proceed.
- Keep status reports short. Put detailed implementation notes in documentation or the development log.

## 8. Definition of Done

A task is complete only when:
- The requested scope is implemented and unrelated scope remains untouched.
- Referenced files, scenes, resources, and node paths are valid to the extent checked.
- Appropriate static checks have passed or their limitations are stated.
- Runtime verification is clearly marked as verified, pending, or blocked.
- Documentation/log updates are made when required, preserving history.
- The final handoff includes changed files, verification status, and the next actionable step.

## 9. Related Documents

- `docs/AUDIT.md` — current asset/repository inventory and outstanding audit work.
- `docs/OVERWORLD_TILESET_CATALOG.md` — atlas coordinate system, ground/flora/terrain categories, and safe placement workflow.
- `docs/RUNTIME_VERIFIED.md` — sole record of behavior actually observed running in Godot.
- `DEVELOPMENT_LOG.md` — root-level chronological implementation notes; append entries only.
- `README.md` — brief project overview and top-level structure.
