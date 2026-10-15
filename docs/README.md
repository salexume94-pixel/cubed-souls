# CubeDSouls

A 2D pixel-art fantasy RPG built with Godot.

## Structure
- `assets/` - Tilesets, sprites, and audio
- `world/` - Maps and reusable environmental objects
- `player/` - Player scripts and resources
- `systems/` - Gameplay systems
- `ui/` - User interface
- `scenes/` - Shared scenes
- `docs/` - Architecture, audits, tileset references, and runtime verification records

## Project documentation
- [Architecture and collaboration guide](ARCHITECTURE.md)
- [Repository and asset audit](AUDIT.md)
- [Map-making ruleset and tileset references](MAP_MAKING_RULESET.md)
- [Tileset catalog cross-check](TILESET_CROSSCHECK.md)
- [Runtime-verified behavior](RUNTIME_VERIFIED.md)
- [Development log](DEVELOPMENT_LOG.md)

## Working rules
- GitHub `main` is the source of truth.
- Runtime verification means the behavior was actually observed in Godot. Commits and static checks alone do not count.
- Preserve the development log history; add new entries rather than deleting or rewriting old ones.
