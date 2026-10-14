extends Node2D

# Builds a deterministic starter field using the user-confirmed base-grass atlas cell.
# TileMapLayer cells are populated at runtime so the scene keeps its four existing layers.
# No prop coordinates are guessed; trees, paths, and decorations can be added after their
# exact source regions are visually confirmed from the labelled atlas reference.

const GROUND_SOURCE_ID: int = 0
const GRASS_ATLAS_COORDS: Vector2i = Vector2i(1, 12)
const MAP_WIDTH: int = 64
const MAP_HEIGHT: int = 40

@onready var ground: TileMapLayer = $Ground

func _ready() -> void:
	_build_ground()

func _build_ground() -> void:
	# Clear only the ground layer before rebuilding, making the result repeatable.
	ground.clear()
	for y in range(MAP_HEIGHT):
		for x in range(MAP_WIDTH):
			ground.set_cell(Vector2i(x, y), GROUND_SOURCE_ID, GRASS_ATLAS_COORDS)
