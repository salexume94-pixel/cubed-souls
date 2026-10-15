@tool
extends Node2D

# Build a reusable wooden-floor room from the catalogued walls_floor atlas.
# The @tool annotation keeps the room visible in the editor as well as at runtime.
const ROOM_WIDTH := 24
const ROOM_HEIGHT := 16
const SOURCE_ID := 0
const FLOOR_TILES: Array[Vector2i] = [
	Vector2i(7, 4), Vector2i(8, 4), Vector2i(7, 5), Vector2i(8, 5),
	Vector2i(6, 10), Vector2i(7, 10), Vector2i(8, 10)
]

@onready var ground: TileMapLayer = $Ground
@onready var objects: TileMapLayer = $Objects


func _ready() -> void:
	# Rebuild the documented room layout so changes stay deterministic in editor and runtime.
	_build_floor()
	_build_walls()
	_configure_interior_camera()


func _build_floor() -> void:
	ground.clear()
	for y in range(1, ROOM_HEIGHT - 1):
		for x in range(1, ROOM_WIDTH - 1):
			var atlas := FLOOR_TILES[(x + y) % FLOOR_TILES.size()]
			ground.set_cell(Vector2i(x, y), SOURCE_ID, atlas)


func _build_walls() -> void:
	objects.clear()
	# The room has one back wall across the north edge, not stone walls down both sides.
	# Repeat the catalogued vertical wall bundle horizontally to form that back wall.
	for x in range(1, ROOM_WIDTH - 1):
		var wall_atlas_x: int = (x - 1) % 3
		objects.set_cell(Vector2i(x, 1), SOURCE_ID, Vector2i(wall_atlas_x, 6))
		objects.set_cell(Vector2i(x, 2), SOURCE_ID, Vector2i(wall_atlas_x, 7))


func _configure_interior_camera() -> void:
	# The interior is a fixed room view. The Player can move without dragging the camera.
	var player := get_tree().current_scene.find_child("Player", true, false) as Node2D
	if player == null:
		return
	var camera := player.get_node_or_null("Camera2D") as Camera2D
	if camera != null:
		camera.center_on_map(Vector2i(ROOM_WIDTH, ROOM_HEIGHT), 2.5)
