@tool
extends Node2D

# This is an @tool script so the generated tiles are visible in the 2D editor,
# not only after pressing Play. The same deterministic layout is used at runtime.
# Ground and details use the existing TileMapLayers and registered TileSet cells.
# Each bundle is always placed as two adjacent atlas cells on adjacent map cells.

const EXTERIOR_SOURCE_ID: int = 0
const DETAILS_SOURCE_ID: int = 1
const GRASS_ATLAS_COORDS: Vector2i = Vector2i(1, 12)
const LEAF_ROW: int = 15
const BUNDLE_A_LEFT_X: int = 11
const BUNDLE_B_LEFT_X: int = 13
const SINGLE_LEAF_A_X: int = 15
const SINGLE_LEAF_B_X: int = 16
const MAP_WIDTH: int = 64
const MAP_HEIGHT: int = 40
const TILE_SIZE: int = 16

# Exterior atlas coordinates documented in docs/MAP_MAKING_RULESET.md.
# Multi-cell assets are placed as complete contiguous bundles.
const TREE_LARGE_ATLAS: Vector2i = Vector2i(0, 38)
const TREE_SMALL_ATLAS: Vector2i = Vector2i(3, 39)
const ROCK_LARGE_ATLAS: Vector2i = Vector2i(0, 25)
const ROCK_MEDIUM_A_ATLAS: Vector2i = Vector2i(3, 25)
const ROCK_MEDIUM_B_ATLAS: Vector2i = Vector2i(5, 25)
const BUSH_MEDIUM_ATLAS: Vector2i = Vector2i(10, 18)
const BUSH_SMALL_ATLAS: Vector2i = Vector2i(14, 14)

@onready var ground: TileMapLayer = $Ground
@onready var details: TileMapLayer = $Details
@onready var objects: TileMapLayer = $Objects

func _ready() -> void:
	# Keep map artwork generated in the editor, but create physics walls only at runtime.
	_build_ground()
	_place_grass_leaves()
	_place_objects()
	if not Engine.is_editor_hint():
		_create_map_boundaries()

func _build_ground() -> void:
	# Fill the field with the base-grass tile confirmed by the user.
	ground.clear()
	for y in range(MAP_HEIGHT):
		for x in range(MAP_WIDTH):
			ground.set_cell(Vector2i(x, y), EXTERIOR_SOURCE_ID, GRASS_ATLAS_COORDS)

func _place_grass_leaves() -> void:
	# Rebuild only the detail layer so every editor load and launch uses the same layout.
	details.clear()

	# Each bundle uses adjacent atlas cells on adjacent map cells.
	# Locations are spread around the field, keeping the player spawn clear.
	_place_bundle(Vector2i(5, 5), BUNDLE_A_LEFT_X)
	_place_bundle(Vector2i(18, 4), BUNDLE_B_LEFT_X)
	_place_bundle(Vector2i(35, 6), BUNDLE_A_LEFT_X)
	_place_bundle(Vector2i(52, 5), BUNDLE_B_LEFT_X)
	_place_bundle(Vector2i(8, 12), BUNDLE_B_LEFT_X)
	_place_bundle(Vector2i(24, 11), BUNDLE_A_LEFT_X)
	_place_bundle(Vector2i(44, 13), BUNDLE_B_LEFT_X)
	_place_bundle(Vector2i(56, 17), BUNDLE_A_LEFT_X)
	_place_bundle(Vector2i(4, 25), BUNDLE_A_LEFT_X)
	_place_bundle(Vector2i(17, 31), BUNDLE_B_LEFT_X)
	_place_bundle(Vector2i(37, 33), BUNDLE_A_LEFT_X)
	_place_bundle(Vector2i(53, 29), BUNDLE_B_LEFT_X)

	# Individual leaves are scattered between bundles.
	_place_single_leaf(Vector2i(12, 8), SINGLE_LEAF_A_X)
	_place_single_leaf(Vector2i(29, 5), SINGLE_LEAF_B_X)
	_place_single_leaf(Vector2i(47, 9), SINGLE_LEAF_A_X)
	_place_single_leaf(Vector2i(59, 11), SINGLE_LEAF_B_X)
	_place_single_leaf(Vector2i(13, 18), SINGLE_LEAF_B_X)
	_place_single_leaf(Vector2i(29, 14), SINGLE_LEAF_A_X)
	_place_single_leaf(Vector2i(49, 21), SINGLE_LEAF_B_X)
	_place_single_leaf(Vector2i(9, 33), SINGLE_LEAF_A_X)
	_place_single_leaf(Vector2i(28, 35), SINGLE_LEAF_B_X)
	_place_single_leaf(Vector2i(45, 36), SINGLE_LEAF_A_X)
	_place_single_leaf(Vector2i(60, 34), SINGLE_LEAF_B_X)

func _place_bundle(map_position: Vector2i, left_atlas_x: int) -> void:
	# A bundle is two neighboring 16×16 tiles, never separated on the map.
	details.set_cell(map_position, DETAILS_SOURCE_ID, Vector2i(left_atlas_x, LEAF_ROW))
	details.set_cell(map_position + Vector2i(1, 0), DETAILS_SOURCE_ID, Vector2i(left_atlas_x + 1, LEAF_ROW))

func _place_single_leaf(map_position: Vector2i, atlas_x: int) -> void:
	# Single-leaf accents use the two confirmed individual-leaf cells.
	details.set_cell(map_position, DETAILS_SOURCE_ID, Vector2i(atlas_x, LEAF_ROW))


func _place_objects() -> void:
	# Use only catalogued atlas regions from the exterior tileset.
	# Large objects sit around the perimeter, preserving a broad open center.
	objects.clear()
	_place_bundle_object(Vector2i(2, 2), TREE_LARGE_ATLAS, Vector2i(3, 3))
	_place_bundle_object(Vector2i(18, 2), TREE_SMALL_ATLAS, Vector2i(2, 2))
	_place_bundle_object(Vector2i(42, 2), TREE_LARGE_ATLAS, Vector2i(3, 3))
	_place_bundle_object(Vector2i(59, 3), TREE_SMALL_ATLAS, Vector2i(2, 2))
	_place_bundle_object(Vector2i(2, 17), TREE_SMALL_ATLAS, Vector2i(2, 2))
	_place_bundle_object(Vector2i(59, 20), TREE_LARGE_ATLAS, Vector2i(3, 3))
	_place_bundle_object(Vector2i(3, 34), TREE_LARGE_ATLAS, Vector2i(3, 3))
	_place_bundle_object(Vector2i(19, 35), TREE_SMALL_ATLAS, Vector2i(2, 2))
	_place_bundle_object(Vector2i(42, 35), TREE_LARGE_ATLAS, Vector2i(3, 3))
	_place_bundle_object(Vector2i(59, 34), TREE_SMALL_ATLAS, Vector2i(2, 2))

	# Rock clusters frame the field edges without closing the route through the middle.
	_place_bundle_object(Vector2i(10, 3), ROCK_LARGE_ATLAS, Vector2i(3, 3))
	_place_bundle_object(Vector2i(29, 2), ROCK_MEDIUM_A_ATLAS, Vector2i(2, 2))
	_place_bundle_object(Vector2i(51, 10), ROCK_MEDIUM_B_ATLAS, Vector2i(2, 2))
	_place_bundle_object(Vector2i(10, 34), ROCK_MEDIUM_B_ATLAS, Vector2i(2, 2))
	_place_bundle_object(Vector2i(51, 33), ROCK_LARGE_ATLAS, Vector2i(3, 3))

	# Bushes add low vegetation, away from the central walking corridor.
	_place_bundle_object(Vector2i(7, 9), BUSH_MEDIUM_ATLAS, Vector2i(2, 2))
	objects.set_cell(Vector2i(56, 13), EXTERIOR_SOURCE_ID, BUSH_SMALL_ATLAS)
	_place_bundle_object(Vector2i(24, 31), BUSH_MEDIUM_ATLAS, Vector2i(2, 2))
	objects.set_cell(Vector2i(6, 29), EXTERIOR_SOURCE_ID, BUSH_SMALL_ATLAS)
	objects.set_cell(Vector2i(56, 28), EXTERIOR_SOURCE_ID, BUSH_SMALL_ATLAS)

func _place_bundle_object(map_position: Vector2i, atlas_origin: Vector2i, dimensions: Vector2i) -> void:
	# Copy each cell in the catalogued rectangle to the same relative map position.
	for y in range(dimensions.y):
		for x in range(dimensions.x):
			objects.set_cell(map_position + Vector2i(x, y), EXTERIOR_SOURCE_ID, atlas_origin + Vector2i(x, y))

func _create_map_boundaries() -> void:
	# Build physics nodes in code to avoid fragile .tscn parent-path parsing.
	# The map spans 64×40 tiles at 16 pixels per tile; walls sit just outside its edges.
	_add_boundary("WestBoundary", Vector2(-TILE_SIZE / 2.0, MAP_HEIGHT * TILE_SIZE / 2.0), Vector2(TILE_SIZE, MAP_HEIGHT * TILE_SIZE + TILE_SIZE))
	_add_boundary("EastBoundary", Vector2(MAP_WIDTH * TILE_SIZE + TILE_SIZE / 2.0, MAP_HEIGHT * TILE_SIZE / 2.0), Vector2(TILE_SIZE, MAP_HEIGHT * TILE_SIZE + TILE_SIZE))
	_add_boundary("NorthBoundary", Vector2(MAP_WIDTH * TILE_SIZE / 2.0, -TILE_SIZE / 2.0), Vector2(MAP_WIDTH * TILE_SIZE + TILE_SIZE, TILE_SIZE))
	_add_boundary("SouthBoundary", Vector2(MAP_WIDTH * TILE_SIZE / 2.0, MAP_HEIGHT * TILE_SIZE + TILE_SIZE / 2.0), Vector2(MAP_WIDTH * TILE_SIZE + TILE_SIZE, TILE_SIZE))

func _add_boundary(boundary_name: String, boundary_position: Vector2, boundary_size: Vector2) -> void:
	# Each wall is a StaticBody2D on the player's collision layer, with no scene-file child paths.
	var wall := StaticBody2D.new()
	wall.name = boundary_name
	wall.position = boundary_position
	wall.collision_layer = 1
	wall.collision_mask = 0

	var collision := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = boundary_size
	collision.shape = rectangle
	wall.add_child(collision)
	add_child(wall)
