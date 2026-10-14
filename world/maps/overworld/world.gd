extends Node2D

# Builds a deterministic grass field and scatters the user's confirmed grass-leaf details.
# The ground and details use separate existing TileMapLayers and the existing TileSet.
# Leaf bundles are always placed as two adjacent atlas cells on adjacent map cells.

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

@onready var ground: TileMapLayer = $Ground
@onready var details: TileMapLayer = $Details

func _ready() -> void:
	_build_ground()
	_place_grass_leaves()

func _build_ground() -> void:
	# Fill the field with the base-grass tile confirmed by the user.
	ground.clear()
	for y in range(MAP_HEIGHT):
		for x in range(MAP_WIDTH):
			ground.set_cell(Vector2i(x, y), EXTERIOR_SOURCE_ID, GRASS_ATLAS_COORDS)

func _place_grass_leaves() -> void:
	# Rebuild only the detail layer so every launch produces the same layout.
	details.clear()

	# Each bundle uses two adjacent atlas cells placed in adjacent map cells.
	# Locations are distributed around the field, leaving the player spawn area clear.
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

	# Individual leaves are sprinkled between bundles without touching the spawn.
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
	details.set_cell(map_position + Vector2i.RIGHT, DETAILS_SOURCE_ID, Vector2i(left_atlas_x + 1, LEAF_ROW))

func _place_single_leaf(map_position: Vector2i, atlas_x: int) -> void:
	# Single-leaf accents use the two confirmed individual-leaf cells.
	details.set_cell(map_position, DETAILS_SOURCE_ID, Vector2i(atlas_x, LEAF_ROW))
