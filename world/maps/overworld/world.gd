extends Node2D

# Builds a starter overworld from the existing 16x16 overworld TileSet.
# The map is intentionally generated here so the PNG assets stay the source art,
# rather than baking duplicate tile images or introducing a separate map format.

const MAP_WIDTH: int = 64
const MAP_HEIGHT: int = 40
const GRASS_SOURCE_ID: int = 0
const GRASS_ATLAS_COORDS := Vector2i(3, 0)
const DETAIL_SOURCE_ID: int = 1
const DETAIL_CHANCE: float = 0.075
const SPAWN_CLEAR_RADIUS: Vector2i = Vector2i(5, 4)

@onready var ground: TileMapLayer = $Ground
@onready var details: TileMapLayer = $Details


func _ready() -> void:
	_build_ground()
	_scatter_grass_details()


func _build_ground() -> void:
	# Fill the whole walkable field with a single base grass tile.
	for y in range(MAP_HEIGHT):
		for x in range(MAP_WIDTH):
			ground.set_cell(Vector2i(x, y), GRASS_SOURCE_ID, GRASS_ATLAS_COORDS)


func _scatter_grass_details() -> void:
	# Use a fixed seed so the overworld layout stays stable between launches.
	var rng := RandomNumberGenerator.new()
	rng.seed = 24032026
	var spawn_cell := Vector2i(MAP_WIDTH / 2, MAP_HEIGHT / 2)

	for y in range(MAP_HEIGHT):
		for x in range(MAP_WIDTH):
			var cell := Vector2i(x, y)

			# Leave the starting area visually clear around the player spawn.
			if abs(cell.x - spawn_cell.x) <= SPAWN_CLEAR_RADIUS.x and abs(cell.y - spawn_cell.y) <= SPAWN_CLEAR_RADIUS.y:
				continue
			if rng.randf() > DETAIL_CHANCE:
				continue

			# The grass-detail atlas is source 1 in the existing background TileSet.
			var atlas_coords := Vector2i(rng.randi_range(0, 20), rng.randi_range(0, 7))
			details.set_cell(cell, DETAIL_SOURCE_ID, atlas_coords)
