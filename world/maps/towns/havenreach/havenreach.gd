@tool
extends Node2D

# Havenreach is a seeded-random 64×40-tile settlement assembled only from catalogued PNG atlas cells.
# Keep this generator separate from the overworld so town-specific placements never clear overworld layers.

const TILE_SIZE: int = 16
const MAP_WIDTH: int = 64
const MAP_HEIGHT: int = 40

# Source IDs match assets/tilesets/overworld/background.tres.
const EXTERIOR_SOURCE_ID: int = 0
const GRASS_DETAILS_SOURCE_ID: int = 1
const CHAPEL_SOURCE_ID: int = 2
const GRASS_ATLAS: Vector2i = Vector2i(1, 12)

# Complete house bundle in the exterior atlas: 10 columns × 8 rows.
const HOUSE_ATLAS_ORIGIN: Vector2i = Vector2i(0, 0)
const HOUSE_SIZE: Vector2i = Vector2i(10, 8)

# Chapel bundle in the chapel exterior atlas: 8 columns × 10 rows.
const CHAPEL_ATLAS_ORIGIN: Vector2i = Vector2i(0, 0)
const CHAPEL_SIZE: Vector2i = Vector2i(8, 10)

# Exterior object bundles documented in MAP_MAKING_RULESET.md.
const TREE_LARGE: Vector2i = Vector2i(0, 38)
const TREE_SMALL: Vector2i = Vector2i(3, 39)
const ROCK_MEDIUM_A: Vector2i = Vector2i(3, 25)
const ROCK_MEDIUM_B: Vector2i = Vector2i(5, 25)
const BUSH_MEDIUM: Vector2i = Vector2i(10, 18)
const BUSH_SMALL: Vector2i = Vector2i(14, 14)

# A fixed seed gives Havenreach an irregular, randomized-looking layout that stays stable between runs.
const LAYOUT_SEED: int = 481516
const HOUSE_CANDIDATES: Array[Vector2i] = [
	Vector2i(5, 5), Vector2i(17, 5), Vector2i(42, 5), Vector2i(53, 14),
	Vector2i(17, 17), Vector2i(42, 17), Vector2i(53, 27), Vector2i(5, 28),
	Vector2i(17, 29), Vector2i(42, 29), Vector2i(5, 14), Vector2i(53, 5),
]

@onready var ground: TileMapLayer = $Ground
@onready var details: TileMapLayer = $Details
@onready var objects: TileMapLayer = $Objects
@onready var foreground: TileMapLayer = $Foreground

var _collision_root: Node2D
var _collision_specs: Array[Dictionary] = []


func _ready() -> void:
	# Rebuild all four layers in editor and runtime; the seeded layout is irregular but repeatable.
	_collision_specs.clear()
	_build_ground()
	_build_details()
	_build_objects()
	_create_object_collisions()

	# Runtime-only invisible boundaries keep the player inside the settlement.
	if not Engine.is_editor_hint():
		_create_map_boundaries()


func _build_ground() -> void:
	# Fill the map with the existing grass tile used by the overworld.
	ground.clear()
	for y in range(MAP_HEIGHT):
		for x in range(MAP_WIDTH):
			ground.set_cell(Vector2i(x, y), EXTERIOR_SOURCE_ID, GRASS_ATLAS)


func _build_details() -> void:
	# Keep the central green and the chapel approach open; scatter existing grass-leaf bundles around the edges.
	details.clear()
	_place_leaf_bundle(Vector2i(4, 13), 11)
	_place_leaf_bundle(Vector2i(18, 16), 13)
	_place_leaf_bundle(Vector2i(43, 16), 11)
	_place_leaf_bundle(Vector2i(57, 13), 13)
	_place_leaf_bundle(Vector2i(4, 26), 13)
	_place_leaf_bundle(Vector2i(18, 24), 11)
	_place_leaf_bundle(Vector2i(43, 24), 13)
	_place_leaf_bundle(Vector2i(57, 26), 11)
	_place_leaf_bundle(Vector2i(21, 5), 11)
	_place_leaf_bundle(Vector2i(41, 5), 13)

	# Small flower accents use documented individual cells from the exterior atlas.
	_place_detail_tile(Vector2i(21, 18), Vector2i(14, 39))
	_place_detail_tile(Vector2i(24, 21), Vector2i(8, 41))
	_place_detail_tile(Vector2i(39, 18), Vector2i(14, 42))
	_place_detail_tile(Vector2i(42, 21), Vector2i(14, 43))
	_place_detail_tile(Vector2i(25, 26), Vector2i(14, 44))
	_place_detail_tile(Vector2i(38, 26), Vector2i(9, 47))


func _place_leaf_bundle(map_origin: Vector2i, atlas_left_x: int) -> void:
	# These grass leaves are a two-cell horizontal bundle on source 1, row 15.
	var atlas_source := details.tile_set.get_source(GRASS_DETAILS_SOURCE_ID) as TileSetAtlasSource
	if atlas_source == null:
		push_error("Havenreach: grass-details atlas source is missing.")
		return
	for offset_x in range(2):
		var atlas_coords := Vector2i(atlas_left_x + offset_x, 15)
		if atlas_source.has_tile(atlas_coords):
			details.set_cell(map_origin + Vector2i(offset_x, 0), GRASS_DETAILS_SOURCE_ID, atlas_coords)


func _place_detail_tile(map_position: Vector2i, atlas_coords: Vector2i) -> void:
	# Single decorative tiles are placed only when the actual atlas cell exists.
	var atlas_source := details.tile_set.get_source(EXTERIOR_SOURCE_ID) as TileSetAtlasSource
	if atlas_source != null and atlas_source.has_tile(atlas_coords):
		details.set_cell(map_position, EXTERIOR_SOURCE_ID, atlas_coords)


func _build_objects() -> void:
	# Shuffle candidate plots so houses feel organically scattered instead of arranged in matching corners.
	# The seed keeps placements stable between editor refreshes and game launches.
	var rng := RandomNumberGenerator.new()
	rng.seed = LAYOUT_SEED
	var house_plots: Array[Vector2i] = HOUSE_CANDIDATES.duplicate()
	house_plots.shuffle()
	for index in range(4):
		_place_house(house_plots[index], "House_%02d" % (index + 1))

	# The chapel uses its own registered atlas source and is the settlement's visual landmark.
	_place_chapel(Vector2i(28, 3), "HavenreachChapel")

	# Tree, rock, and bush bundles frame the settlement without blocking the central approach.
	_place_object_bundle("NorthwestTree", Vector2i(2, 2), TREE_LARGE, Vector2i(3, 3))
	_place_object_bundle("NortheastTree", Vector2i(59, 2), TREE_LARGE, Vector2i(3, 3))
	_place_object_bundle("SouthwestTree", Vector2i(2, 35), TREE_LARGE, Vector2i(3, 3))
	_place_object_bundle("SoutheastTree", Vector2i(59, 35), TREE_LARGE, Vector2i(3, 3))
	_place_object_bundle("NorthwestInnerTree", Vector2i(18, 7), TREE_SMALL, Vector2i(2, 2))
	_place_object_bundle("NortheastInnerTree", Vector2i(43, 7), TREE_SMALL, Vector2i(2, 2))

	_place_object_bundle("WestRockCluster", Vector2i(4, 17), ROCK_MEDIUM_A, Vector2i(2, 2))
	_place_object_bundle("EastRockCluster", Vector2i(57, 17), ROCK_MEDIUM_B, Vector2i(2, 2))
	_place_object_bundle("SouthWestRockCluster", Vector2i(19, 34), ROCK_MEDIUM_B, Vector2i(2, 2))
	_place_object_bundle("SouthEastRockCluster", Vector2i(42, 34), ROCK_MEDIUM_A, Vector2i(2, 2))

	_place_object_bundle("WestPlazaBush", Vector2i(20, 14), BUSH_MEDIUM, Vector2i(2, 2))
	_place_object_bundle("EastPlazaBush", Vector2i(42, 14), BUSH_MEDIUM, Vector2i(2, 2))
	_place_object_bundle("SouthWestPlazaBush", Vector2i(20, 25), BUSH_MEDIUM, Vector2i(2, 2))
	_place_object_bundle("SouthEastPlazaBush", Vector2i(42, 25), BUSH_MEDIUM, Vector2i(2, 2))
	_place_object_bundle("NorthEastSmallBush", Vector2i(56, 12), BUSH_SMALL, Vector2i(1, 1))
	_place_object_bundle("SouthWestSmallBush", Vector2i(5, 29), BUSH_SMALL, Vector2i(1, 1))


func _place_house(map_origin: Vector2i, collision_name: String) -> void:
	# Place the house as one 10×8 source bundle, preserving all atlas offsets and intentional gaps.
	var atlas_source := objects.tile_set.get_source(EXTERIOR_SOURCE_ID) as TileSetAtlasSource
	if atlas_source == null:
		push_error("Havenreach: exterior atlas source is missing.")
		return
	for y in range(HOUSE_SIZE.y):
		for x in range(HOUSE_SIZE.x):
			var atlas_coords := HOUSE_ATLAS_ORIGIN + Vector2i(x, y)
			if not atlas_source.has_tile(atlas_coords):
				continue
			var destination := map_origin + Vector2i(x, y)
			if y <= 4:
				foreground.set_cell(destination, EXTERIOR_SOURCE_ID, atlas_coords)
			else:
				objects.set_cell(destination, EXTERIOR_SOURCE_ID, atlas_coords)
	# Generate the foreground roof and lower building body as separate alpha masks.
	# The roof occupies rows 0–4 on Foreground; the wall/base occupies rows 5–7 on Objects.
	# Both masks use the same source alpha, so transparent pixels in either section remain walkable.
	_collision_specs.append({
		"name": collision_name + "_Roof",
		"map_origin": map_origin,
		"source_id": EXTERIOR_SOURCE_ID,
		"atlas_origin": HOUSE_ATLAS_ORIGIN,
		"dimensions": Vector2i(HOUSE_SIZE.x, 5),
	})
	_collision_specs.append({
		"name": collision_name + "_Body",
		"map_origin": map_origin + Vector2i(0, 5),
		"source_id": EXTERIOR_SOURCE_ID,
		"atlas_origin": HOUSE_ATLAS_ORIGIN + Vector2i(0, 5),
		"dimensions": Vector2i(HOUSE_SIZE.x, HOUSE_SIZE.y - 5),
	})


func _place_chapel(map_origin: Vector2i, collision_name: String) -> void:
	# Place the complete chapel bundle; upper rows render in Foreground and lower rows stay behind the player.
	var atlas_source := objects.tile_set.get_source(CHAPEL_SOURCE_ID) as TileSetAtlasSource
	if atlas_source == null:
		push_error("Havenreach: chapel atlas source is missing.")
		return
	for y in range(CHAPEL_SIZE.y):
		for x in range(CHAPEL_SIZE.x):
			var atlas_coords := CHAPEL_ATLAS_ORIGIN + Vector2i(x, y)
			if not atlas_source.has_tile(atlas_coords):
				continue
			var destination := map_origin + Vector2i(x, y)
			if y <= 5:
				foreground.set_cell(destination, CHAPEL_SOURCE_ID, atlas_coords)
			else:
				objects.set_cell(destination, CHAPEL_SOURCE_ID, atlas_coords)
	_collision_specs.append({
		"name": collision_name,
		"map_origin": map_origin,
		"source_id": CHAPEL_SOURCE_ID,
		"atlas_origin": CHAPEL_ATLAS_ORIGIN,
		"dimensions": CHAPEL_SIZE,
	})


func _place_object_bundle(collision_name: String, map_origin: Vector2i, atlas_origin: Vector2i, dimensions: Vector2i) -> void:
	# Copy only registered cells from a documented bundle, preserving its exact source arrangement.
	var atlas_source := objects.tile_set.get_source(EXTERIOR_SOURCE_ID) as TileSetAtlasSource
	if atlas_source == null:
		push_error("Havenreach: exterior atlas source is missing.")
		return
	for y in range(dimensions.y):
		for x in range(dimensions.x):
			var atlas_coords := atlas_origin + Vector2i(x, y)
			if atlas_source.has_tile(atlas_coords):
				objects.set_cell(map_origin + Vector2i(x, y), EXTERIOR_SOURCE_ID, atlas_coords)
	_collision_specs.append({
		"name": collision_name,
		"map_origin": map_origin,
		"source_id": EXTERIOR_SOURCE_ID,
		"atlas_origin": atlas_origin,
		"dimensions": dimensions,
	})


func _create_object_collisions() -> void:
	# Rebuild generated colliders so layout changes always update house/chapel footprints.
	# This container is generated data; hand-authored collision nodes belong outside it.
	var existing_root := get_node_or_null("GeneratedObjectCollisions")
	if existing_root != null:
		_collision_root = existing_root as Node2D
		for child in _collision_root.get_children():
			_collision_root.remove_child(child)
			child.free()
	else:
		_collision_root = Node2D.new()
		_collision_root.name = "GeneratedObjectCollisions"
		add_child(_collision_root)
		if Engine.is_editor_hint():
			var edited_root := get_tree().edited_scene_root
			if edited_root != null:
				_collision_root.owner = edited_root

	# Buildings use the same source-alpha collision method as trees and bushes.
	# Opaque roof/wall pixels block movement; transparent pixels inside atlas cells stay passable.
	for spec in _collision_specs:
		_add_alpha_collision_for_bundle(
			str(spec["name"]),
			spec["map_origin"],
			int(spec["source_id"]),
			spec["atlas_origin"],
			spec["dimensions"]
		)


func _add_alpha_collision_for_bundle(collision_prefix: String, map_origin: Vector2i, source_id: int, atlas_origin: Vector2i, dimensions: Vector2i) -> void:
	# Build one combined alpha mask from the exact source cells used by this placed bundle.
	var atlas_source := objects.tile_set.get_source(source_id) as TileSetAtlasSource
	if atlas_source == null:
		push_error("Havenreach: cannot build collision; atlas source %d is missing." % source_id)
		return
	var texture := atlas_source.get_texture()
	var atlas_image := texture.get_image() if texture != null else null
	if atlas_image == null or atlas_image.is_empty():
		push_error("Havenreach: cannot read texture pixels for %s." % collision_prefix)
		return

	var pixel_width := dimensions.x * TILE_SIZE
	var pixel_height := dimensions.y * TILE_SIZE
	var opaque := PackedByteArray()
	opaque.resize(pixel_width * pixel_height)

	for tile_y in range(dimensions.y):
		for tile_x in range(dimensions.x):
			var atlas_coords := atlas_origin + Vector2i(tile_x, tile_y)
			if not atlas_source.has_tile(atlas_coords):
				continue
			# Sample the registered atlas cell directly from the source PNG.
			# Do not depend on the rendered tile region: the house roof is drawn on Foreground,
			# but its collision must still come from the exact source-atlas alpha pixels.
			var source_x := atlas_coords.x * TILE_SIZE
			var source_y := atlas_coords.y * TILE_SIZE
			for py in range(TILE_SIZE):
				for px in range(TILE_SIZE):
					var image_x := source_x + px
					var image_y := source_y + py
					if image_x >= atlas_image.get_width() or image_y >= atlas_image.get_height():
						continue
					var alpha := atlas_image.get_pixel(image_x, image_y).a
					if alpha > 0.05:
						var target_x := tile_x * TILE_SIZE + px
						var target_y := tile_y * TILE_SIZE + py
						opaque[target_y * pixel_width + target_x] = 1

	# Fail loudly if a requested bundle region produced no opaque pixels instead of silently
	# leaving an entire roof or object without collision.
	var opaque_pixel_count := 0
	for pixel_value in opaque:
		if pixel_value != 0:
			opaque_pixel_count += 1
	if opaque_pixel_count == 0:
		push_error("Havenreach: alpha collision for %s found no opaque pixels." % collision_prefix)
		return

	# Merge identical horizontal opaque runs vertically to keep the physics-shape count practical.
	var active_runs: Dictionary = {}
	var rectangle_index := 0
	for y in range(pixel_height):
		var row_runs: Array[Vector2i] = []
		var x := 0
		while x < pixel_width:
			if opaque[y * pixel_width + x] == 0:
				x += 1
				continue
			var run_start := x
			while x < pixel_width and opaque[y * pixel_width + x] != 0:
				x += 1
			row_runs.append(Vector2i(run_start, x - run_start))

		var next_active: Dictionary = {}
		for run in row_runs:
			var key := "%d:%d" % [run.x, run.y]
			if active_runs.has(key):
				var existing: Dictionary = active_runs[key]
				existing["height"] = int(existing["height"]) + 1
				next_active[key] = existing
			else:
				next_active[key] = {"x": run.x, "y": y, "width": run.y, "height": 1}
		for key in active_runs:
			if not next_active.has(key):
				var completed: Dictionary = active_runs[key]
				_add_alpha_rectangle(collision_prefix + "_" + str(rectangle_index), map_origin, completed)
				rectangle_index += 1
		active_runs = next_active

	for key in active_runs:
		_add_alpha_rectangle(collision_prefix + "_" + str(rectangle_index), map_origin, active_runs[key])
		rectangle_index += 1


func _add_alpha_rectangle(collision_name: String, map_origin: Vector2i, rectangle_data: Dictionary) -> void:
	# Convert a merged alpha rectangle from bundle-local pixels into world-space collision.
	var body := StaticBody2D.new()
	body.name = collision_name
	body.position = Vector2(map_origin.x * TILE_SIZE, map_origin.y * TILE_SIZE) + Vector2(
		float(rectangle_data["x"]) + float(rectangle_data["width"]) / 2.0,
		float(rectangle_data["y"]) + float(rectangle_data["height"]) / 2.0
	)
	body.collision_layer = 1
	body.collision_mask = 0

	var collision := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(float(rectangle_data["width"]), float(rectangle_data["height"]))
	collision.shape = rectangle
	body.add_child(collision)
	_collision_root.add_child(body)
	if Engine.is_editor_hint():
		var edited_root := get_tree().edited_scene_root
		if edited_root != null:
			body.owner = edited_root
			collision.owner = edited_root


func _create_map_boundaries() -> void:
	# Place boundary bodies just outside the 64×40-tile map.
	_add_boundary("WestBoundary", Vector2(-TILE_SIZE / 2.0, MAP_HEIGHT * TILE_SIZE / 2.0), Vector2(TILE_SIZE, MAP_HEIGHT * TILE_SIZE + TILE_SIZE))
	_add_boundary("EastBoundary", Vector2(MAP_WIDTH * TILE_SIZE + TILE_SIZE / 2.0, MAP_HEIGHT * TILE_SIZE / 2.0), Vector2(TILE_SIZE, MAP_HEIGHT * TILE_SIZE + TILE_SIZE))
	_add_boundary("NorthBoundary", Vector2(MAP_WIDTH * TILE_SIZE / 2.0, -TILE_SIZE / 2.0), Vector2(MAP_WIDTH * TILE_SIZE + TILE_SIZE, TILE_SIZE))
	_add_boundary("SouthBoundary", Vector2(MAP_WIDTH * TILE_SIZE / 2.0, MAP_HEIGHT * TILE_SIZE + TILE_SIZE / 2.0), Vector2(MAP_WIDTH * TILE_SIZE + TILE_SIZE, TILE_SIZE))


func _add_boundary(boundary_name: String, boundary_position: Vector2, boundary_size: Vector2) -> void:
	# Boundary bodies use the player's existing collision layer and do not query other bodies.
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
