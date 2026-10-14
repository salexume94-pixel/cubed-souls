# CubeDSouls

A 2D pixel-art fantasy RPG built with Godot.

## Structure
- `assets/` - Tilesets, sprites, and audio
- `world/` - Maps and reusable environmental objects
- `player/` - Player scripts and resources
- `systems/` - Gameplay systems
- `ui/` - User interface
- `scenes/` - Shared scenes
- `docs/` - Architecture, audits, checklists, and runtime verification records

## Project documentation
- [Implementation checklist](checklist.md)
- [Architecture and collaboration guide](ARCHITECTURE.md)
- [Repository and asset audit](AUDIT.md)
- [Runtime-verified behavior](RUNTIME_VERIFIED.md)
- [Development log](DEVELOPMENT_LOG.md)

## Working rules
- GitHub `main` is the source of truth.
- Runtime verification means the behavior was actually observed in Godot. Commits and static checks alone do not count.
- Preserve the development log history; add new entries rather than deleting or rewriting old ones.
