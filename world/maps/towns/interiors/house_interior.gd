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
const WALL_VERTICAL: Array[Vector2i] = [
	Vector2i(0, 6), Vector2i(0, 7),
	Vector2i(1, 6), Vector2i(1, 7),
	Vector2i(2, 6), Vector2i(2, 7)
]
const OPEN_DOOR := Vector2i(5, 6)

@onready var ground: TileMapLayer = $Ground
@onready var objects: TileMapLayer = $Objects


func _ready() -> void:
	# Rebuild the documented room layout so changes stay deterministic in editor and runtime.
	_build_floor()
	_build_walls()


func _build_floor() -> void:
	ground.clear()
	for y in range(1, ROOM_HEIGHT - 1):
		for x in range(1, ROOM_WIDTH - 1):
			var atlas := FLOOR_TILES[(x + y) % FLOOR_TILES.size()]
			ground.set_cell(Vector2i(x, y), SOURCE_ID, atlas)


func _build_walls() -> void:
	objects.clear()
	# Repeat only the documented vertical stone-wall bundle along both side walls.
	for y in range(2, ROOM_HEIGHT - 2, 2):
		# Each selected source column is a complete 1×2 vertical wall bundle.
		var wall_atlas_x := (y / 2) % 3
		objects.set_cell(Vector2i(1, y), SOURCE_ID, Vector2i(wall_atlas_x, 6))
		objects.set_cell(Vector2i(1, y + 1), SOURCE_ID, Vector2i(wall_atlas_x, 7))
		objects.set_cell(Vector2i(ROOM_WIDTH - 2, y), SOURCE_ID, Vector2i(wall_atlas_x, 6))
		objects.set_cell(Vector2i(ROOM_WIDTH - 2, y + 1), SOURCE_ID, Vector2i(wall_atlas_x, 7))
	# Place the documented 2×2 open-door bundle centered on the south wall.
	for dy in range(2):
		for dx in range(2):
			objects.set_cell(Vector2i(ROOM_WIDTH / 2 - 1 + dx, ROOM_HEIGHT - 2 + dy), SOURCE_ID, OPEN_DOOR + Vector2i(dx, dy))
