extends Node2D

# Creates a starter overworld using only the two image assets in
# assets/tilesets/overworld. The art sheets contain transparent props and
# grass details, not a complete opaque ground tile, so the base terrain and
# paths are drawn as polygons underneath the sprites.

const MAP_WIDTH: float = 1024.0
const MAP_HEIGHT: float = 640.0
const EXTERIOR_PATH: String = "res://assets/tilesets/overworld/exterior.png"
const GRASS_DETAILS_PATH: String = "res://assets/tilesets/overworld/ground_grass_details.png"
const SPAWN := Vector2(512.0, 320.0)

var _rng := RandomNumberGenerator.new()
var _exterior: Texture2D
var _grass_details: Texture2D


func _ready() -> void:
	_rng.seed = 14102026
	_exterior = load(EXTERIOR_PATH) as Texture2D
	_grass_details = load(GRASS_DETAILS_PATH) as Texture2D
	_draw_terrain()
	_scatter_ground_details()
	_place_trees_and_props()


func _draw_terrain() -> void:
	# The source folder has transparent prop/detail sheets, not a grass base.
	# Use a flat grass-colored ground so the map is covered without inventing
	# a tile from an unrelated atlas region.
	var ground := Polygon2D.new()
	ground.name = "GrassGround"
	ground.color = Color("#477b38")
	ground.polygon = PackedVector2Array([
		Vector2(0, 0), Vector2(MAP_WIDTH, 0),
		Vector2(MAP_WIDTH, MAP_HEIGHT), Vector2(0, MAP_HEIGHT)
	])
	add_child(ground)

	# A winding dirt path gives the field a readable route without blocking
	# the player spawn or pretending a town layout already exists.
	var path := Polygon2D.new()
	path.name = "DirtPath"
	path.color = Color("#b7a078")
	path.polygon = PackedVector2Array([
		Vector2(0, 520), Vector2(0, 470), Vector2(150, 445),
		Vector2(275, 405), Vector2(360, 360), Vector2(445, 335),
		Vector2(525, 330), Vector2(610, 300), Vector2(700, 250),
		Vector2(805, 205), Vector2(930, 175), Vector2(1024, 160),
		Vector2(1024, 205), Vector2(940, 220), Vector2(830, 250),
		Vector2(730, 292), Vector2(630, 340), Vector2(540, 365),
		Vector2(450, 370), Vector2(380, 390), Vector2(300, 435),
		Vector2(170, 475)
	])
	add_child(path)

	# Add a small open clearing around the spawn so the player is immediately
	# visible and doesn't start beneath decorative art.
	var clearing := Polygon2D.new()
	clearing.name = "SpawnClearing"
	clearing.color = Color("#528443")
	clearing.polygon = PackedVector2Array([
		SPAWN + Vector2(-90, -64), SPAWN + Vector2(90, -64),
		SPAWN + Vector2(90, 64), SPAWN + Vector2(-90, 64)
	])
	add_child(clearing)


func _scatter_ground_details() -> void:
	# Scatter small transparent grass clumps from the grass-detail sheet.
	# Avoid the spawn clearing and the main path so details don't obscure play.
	for i in range(190):
		var pos := Vector2(_rng.randf_range(20.0, MAP_WIDTH - 20.0), _rng.randf_range(20.0, MAP_HEIGHT - 20.0))
		if pos.distance_to(SPAWN) < 105.0 or _near_path(pos):
			continue

		var col := _rng.randi_range(0, 20)
		var row := _rng.randi_range(9, 17)
		var detail := _make_region_sprite(_grass_details, Rect2(col * 16, row * 16, 16, 16))
		if detail == null:
			continue
		detail.name = "GrassDetail"
		detail.position = pos
		detail.z_index = 1
		detail.scale = Vector2.ONE
		add_child(detail)


func _place_trees_and_props() -> void:
	# Build a broken forest border from whole tree/shrub regions on the
	# exterior sheet. The open gaps keep the edges readable and traversable.
	var tree_regions: Array[Rect2] = [
		Rect2(0, 336, 48, 48),
		Rect2(64, 336, 48, 48),
		Rect2(128, 336, 48, 48),
		Rect2(176, 352, 32, 32),
		Rect2(0, 384, 32, 32),
		Rect2(48, 384, 32, 32),
		Rect2(96, 384, 32, 32),
		Rect2(160, 400, 32, 32),
		Rect2(192, 272, 32, 32)
	]

	# Place denser trees along the map edges.
	for x in range(24, int(MAP_WIDTH), 70):
		_add_tree(tree_regions, Vector2(x + _rng.randf_range(-12, 12), _rng.randf_range(22, 78)))
		_add_tree(tree_regions, Vector2(x + _rng.randf_range(-12, 12), _rng.randf_range(MAP_HEIGHT - 72, MAP_HEIGHT - 20)))
	for y in range(90, int(MAP_HEIGHT) - 80, 76):
		_add_tree(tree_regions, Vector2(_rng.randf_range(18, 65), y))
		_add_tree(tree_regions, Vector2(_rng.randf_range(MAP_WIDTH - 65, MAP_WIDTH - 18), y))

	# Small interior groves frame the path while leaving broad walking lanes.
	for pos in [
		Vector2(180, 180), Vector2(225, 205), Vector2(250, 165),
		Vector2(800, 430), Vector2(845, 455), Vector2(875, 415),
		Vector2(660, 105), Vector2(700, 125), Vector2(735, 95),
		Vector2(330, 545), Vector2(375, 565), Vector2(415, 535)
	]:
		if pos.distance_to(SPAWN) > 125.0 and not _near_path(pos):
			_add_tree(tree_regions, pos)

	# Scatter a few rocks from the same supplied exterior sheet.
	for pos in [Vector2(120, 330), Vector2(285, 285), Vector2(760, 350), Vector2(910, 500)]:
		var rock := _make_region_sprite(_exterior, Rect2(64, 640, 48, 48))
		if rock != null:
			rock.name = "Rock"
			rock.position = pos
			rock.z_index = 2
			add_child(rock)


func _add_tree(regions: Array[Rect2], pos: Vector2) -> void:
	var region: Rect2 = regions[_rng.randi_range(0, regions.size() - 1)]
	var tree := _make_region_sprite(_exterior, region)
	if tree == null:
		return
	tree.name = "OverworldTree"
	tree.position = pos
	tree.z_index = 2
	add_child(tree)


func _make_region_sprite(texture: Texture2D, region: Rect2) -> Sprite2D:
	# Sprite2D regions let this scene use complete sprites from the supplied
	# sheets without adding duplicate image files or guessing TileMap atlas IDs.
	if texture == null:
		return null
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.region_enabled = true
	sprite.region_rect = region
	sprite.centered = true
	return sprite


func _near_path(pos: Vector2) -> bool:
	# Approximate the path's centerline so details and trees leave room to walk.
	var path_points: Array[Vector2] = [
		Vector2(0, 495), Vector2(210, 455), Vector2(350, 390),
		Vector2(475, 350), Vector2(540, 347), Vector2(650, 320),
		Vector2(760, 270), Vector2(900, 215), Vector2(1024, 182)
	]
	for i in range(path_points.size() - 1):
		if _distance_to_segment(pos, path_points[i], path_points[i + 1]) < 42.0:
			return true
	return false


func _distance_to_segment(point: Vector2, start: Vector2, finish: Vector2) -> float:
	var segment := finish - start
	var length_squared := segment.length_squared()
	if length_squared == 0.0:
		return point.distance_to(start)
	var t := clampf((point - start).dot(segment) / length_squared, 0.0, 1.0)
	return point.distance_to(start + segment * t)
