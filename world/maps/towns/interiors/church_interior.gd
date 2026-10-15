@tool
extends Node2D

# Construct the chapel interior from its documented floor, back-wall, portrait, and pillar bundles.
# Every source coordinate is from chapel_walls_interior_labeled.svg.
const ROOM_WIDTH := 32
const ROOM_HEIGHT := 20
const SOURCE_ID := 0
const FLOOR_ORIGIN := Vector2i(2, 31)
const BACK_WALL_ORIGIN := Vector2i(0, 11)
const PORTRAIT_ORIGIN := Vector2i(0, 25)
const PILLAR_ORIGIN := Vector2i(8, 4)

@onready var ground: TileMapLayer = $Ground
@onready var objects: TileMapLayer = $Objects


func _ready() -> void:
	# Rebuild the chapel room in the editor and runtime using catalogued assets only.
	_build_floor()
	_build_back_wall()
	_build_portrait()
	_build_pillars()


func _build_floor() -> void:
	ground.clear()
	for y in range(1, ROOM_HEIGHT - 1):
		for x in range(1, ROOM_WIDTH - 1):
			# Repeat the documented 2×2 floor bundle without changing its internal arrangement.
			var atlas := FLOOR_ORIGIN + Vector2i((x - 1) % 2, (y - 1) % 2)
			ground.set_cell(Vector2i(x, y), SOURCE_ID, atlas)


func _build_back_wall() -> void:
	objects.clear()
	# The complete 7×5 back-wall region is centered against the north end of the room.
	var origin := Vector2i((ROOM_WIDTH - 7) / 2, 1)
	for y in range(5):
		for x in range(7):
			objects.set_cell(origin + Vector2i(x, y), SOURCE_ID, BACK_WALL_ORIGIN + Vector2i(x, y))
	# Repeat the documented 1×4 wall section to extend the wall art on either side.
	for x in range(4, ROOM_WIDTH - 4):
		if x >= origin.x and x < origin.x + 7:
			continue
		for y in range(4):
			objects.set_cell(Vector2i(x, y + 1), SOURCE_ID, Vector2i(3, 12 + y))


func _build_portrait() -> void:
	# Place the complete 4×3 portrait bundle centered on the chapel back wall.
	var origin := Vector2i((ROOM_WIDTH - 4) / 2, 2)
	for y in range(3):
		for x in range(4):
			objects.set_cell(origin + Vector2i(x, y), SOURCE_ID, PORTRAIT_ORIGIN + Vector2i(x, y))


func _build_pillars() -> void:
	# Keep both 2×4 pillar bundles intact and away from the central aisle.
	for origin in [Vector2i(5, 6), Vector2i(ROOM_WIDTH - 7, 6)]:
		for y in range(4):
			for x in range(2):
				objects.set_cell(origin + Vector2i(x, y), SOURCE_ID, PILLAR_ORIGIN + Vector2i(x, y))
