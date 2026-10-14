# Player Movement Milestone

## Scope

This milestone establishes only the first playable foundation in the new Cubed Souls project:

- `player/Player.tscn`: CharacterBody2D, visible temporary sprite, and collision shape.
- `player/player_movement.gd`: normalized arrow-key movement and Shift-to-run.
- `world/world_presentation.gd`: Camera2D follows the Player.
- `scenes/PlayerMovementTest.tscn`: large test floor and solid obstacles.
- `project.godot`: 1152x648 reference viewport and movement test as startup scene.

The SVG in `assets/sprites/player_placeholder.svg` is temporary prototype art, not the final player design. Movement and camera behavior are implemented without bringing over old gameplay dependencies.

## Local Verification Gate

Pull `origin main`, open the project in Godot, then run the project.

- [ ] Project opens without parse or resource errors.
- [ ] The Player sprite is visible at startup.
- [ ] Arrow keys move the Player up, down, left, and right.
- [ ] Diagonal movement is not faster than straight movement.
- [ ] Holding Shift increases movement speed; releasing it restores walking speed.
- [ ] Releasing movement input stops the Player.
- [ ] Camera remains centered on the Player while moving in all directions.
- [ ] Player collision blocks against each test obstacle.
- [ ] Player can move around obstacles without getting trapped.
- [ ] No debugger errors appear during the test.

## Status

Implementation committed to `main`; local Godot runtime verification is pending. Do not treat this milestone as passed until the checklist is tested in the editor.