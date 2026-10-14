extends Node2D

# Build the overworld only from tiles already registered in background.tres.
# The map is deterministic so each test run shows the same layout.
const MAP_WIDTH: int = 64
const MAP_HEIGHT: int = 40
const TERRAIN_SOURCE_ID: int = 0
const GRASS_ATLAS := Vector2i(3, 0)
const DETAIL_SOURCE_ID: int = 1
const DETAIL_DENSITY: float = 0.035
const SPAWN_CELL := Vector2i(32, 20)
const SPAWN_CLEAR_X: int = 5
const SPAWN_CLEAR_Y: int = 4

@onready var ground: TileMapLayer = $Ground
@onready var details: TileMapLayer = $Details
@onready var objects: TileMapLayer = $Objects
@onready var foreground: TileMapLayer = $Foreground


func _ready() -> void:
	# Preserve the four authored TileMapLayer nodes and populate them in order.
	_build_base_terrain()
	_build_grass_details()
	_build_environment_objects()


func _build_base_terrain() -> void:
	# Fill the entire play area with the currently selected base grass tile.
	for y in range(MAP_HEIGHT):
		for x in range(MAP_WIDTH):
			ground.set_cell(Vector2i(x, y), TERRAIN_SOURCE_ID, GRASS_ATLAS)


func _build_grass_details() -> void:
	# Use only the complete 21-by-8 region registered in the grass-detail atlas.
	# A fixed seed makes the scatter repeatable and keeps the start area readable.
	var rng := RandomNumberGenerator.new()
	rng.seed = 24032026

	for y in range(MAP_HEIGHT):
		for x in range(MAP_WIDTH):
			var cell := Vector2i(x, y)
			if _is_spawn_clear(cell):
				continue
			if _is_main_path(cell) or _is_opening_clearing(cell):
				continue
			if rng.randf() > DETAIL_DENSITY:
				continue

			var atlas := Vector2i(rng.randi_range(0, 20), rng.randi_range(0, 7))
			details.set_cell(cell, DETAIL_SOURCE_ID, atlas)


func _build_environment_objects() -> void:
	# Start with a clear, navigable central corridor and a broad northern
	# and southern tree-line trial layout. Only registered atlas cells are used.
	# These are intentionally sparse until the first in-editor visual check.
	var rng := RandomNumberGenerator.new()
	rng.seed = 14062026

	for x in range(2, MAP_WIDTH - 2):
		for y in [2, 3, MAP_HEIGHT - 4, MAP_HEIGHT - 3]:
			if _is_main_path(Vector2i(x, y)):
				continue
			if rng.randf() < 0.72:
				var atlas := _pick_exterior_tile(rng)
				if _tile_is_registered(TERRAIN_SOURCE_ID, atlas):
					objects.set_cell(Vector2i(x, y), TERRAIN_SOURCE_ID, atlas)

	# Side thickets frame the map without blocking the main route or spawn.
	for y in range(5, MAP_HEIGHT - 5):
		for x in [2, 3, MAP_WIDTH - 4, MAP_WIDTH - 3]:
			if abs(y - SPAWN_CELL.y) <= SPAWN_CLEAR_Y + 2:
				continue
			if rng.randf() < 0.62:
				var atlas := _pick_exterior_tile(rng)
				if _tile_is_registered(TERRAIN_SOURCE_ID, atlas):
					objects.set_cell(Vector2i(x, y), TERRAIN_SOURCE_ID, atlas)


func _pick_exterior_tile(rng: RandomNumberGenerator) -> Vector2i:
	# Pick from the registered top atlas rows during this first visual pass.
	# These coordinates are all defined in background.tres; no guessed crops.
	var candidates: Array[Vector2i] = [
		Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0),
		Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1), Vector2i(5, 1), Vector2i(6, 1),
		Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2), Vector2i(5, 2), Vector2i(6, 2), Vector2i(7, 2), Vector2i(8, 2),
		Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3), Vector2i(4, 3), Vector2i(5, 3), Vector2i(6, 3), Vector2i(7, 3), Vector2i(8, 3), Vector2i(9, 3)
	]
	return candidates[rng.randi_range(0, candidates.size() - 1)]


func _tile_is_registered(source_id: int, atlas: Vector2i) -> bool:
	# Query the TileSet itself instead of assuming atlas coordinates exist.
	return ground.tile_set.has_source(source_id) and ground.tile_set.get_source(source_id) is TileSetAtlasSource and (ground.tile_set.get_source(source_id) as TileSetAtlasSource).has_tile(atlas)


func _is_spawn_clear(cell: Vector2i) -> bool:
	return abs(cell.x - SPAWN_CELL.x) <= SPAWN_CLEAR_X and abs(cell.y - SPAWN_CELL.y) <= SPAWN_CLEAR_Y


func _is_opening_clearing(cell: Vector2i) -> bool:
	# A small open approach gives the player room to orient themselves.
	return cell.x >= 25 and cell.x <= 39 and cell.y >= 15 and cell.y <= 25


func _is_main_path(cell: Vector2i) -> bool:
	# Keep a winding, mostly east-west route through the center of the map.
	var path_y := 20
	if cell.x < 15:
		path_y = 18
	elif cell.x < 27:
		path_y = 19
	elif cell.x > 43:
		path_y = 21
	return abs(cell.y - path_y) <= 1
