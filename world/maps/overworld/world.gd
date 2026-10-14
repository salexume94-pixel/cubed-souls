extends Node2D

# Keep the original TileMapLayer workflow. All map visuals come from the
# existing TileSet resources; this script does not draw substitute shapes or
# crop guessed sprite regions from the source PNGs.

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
	# Populate the base grass and decorative detail layers from the TileSet.
	_build_ground()
	_scatter_grass_details()


func _build_ground() -> void:
	# Fill the field with the existing base grass tile.
	for y in range(MAP_HEIGHT):
		for x in range(MAP_WIDTH):
			ground.set_cell(Vector2i(x, y), GRASS_SOURCE_ID, GRASS_ATLAS_COORDS)


func _scatter_grass_details() -> void:
	# A fixed seed keeps the detail placement stable between launches.
	var rng := RandomNumberGenerator.new()
	rng.seed = 24032026
	var spawn_cell := Vector2i(MAP_WIDTH / 2, MAP_HEIGHT / 2)

	for y in range(MAP_HEIGHT):
		for x in range(MAP_WIDTH):
			var cell := Vector2i(x, y)

			# Keep the player's starting area clear.
			if abs(cell.x - spawn_cell.x) <= SPAWN_CLEAR_RADIUS.x and abs(cell.y - spawn_cell.y) <= SPAWN_CLEAR_RADIUS.y:
				continue
			if rng.randf() > DETAIL_CHANCE:
				continue

			# Use the existing grass-detail TileSet source. Object placement is
			# intentionally omitted until the atlas regions are identified.
			var atlas_coords := Vector2i(rng.randi_range(0, 20), rng.randi_range(0, 7))
			details.set_cell(cell, DETAIL_SOURCE_ID, atlas_coords)
