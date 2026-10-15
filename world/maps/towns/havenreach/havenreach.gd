extends Node2D

# Havenreach is a manually authored map workspace.
# Keep reusable camera and boundary/transition behavior here, but never generate
# or clear TileMapLayer cells: editor-authored placements must remain untouched.

const TILE_SIZE: int = 16
const MAP_WIDTH: int = 64
const MAP_HEIGHT: int = 40

func _ready() -> void:
	# Reuse the player's normal outdoor camera behavior when this map is active.
	_restore_outdoor_camera()

	# Runtime-only boundary bodies avoid cluttering the editable scene tree.
	if not Engine.is_editor_hint():
		_create_map_boundaries()


func _restore_outdoor_camera() -> void:
	var scene_root := get_tree().current_scene
	if scene_root == null:
		return

	var player := scene_root.find_child("Player", true, false) as Node2D
	if player == null:
		return

	var camera := player.get_node_or_null("Camera2D") as Camera2D
	if camera != null:
		camera.follow_player()


func _create_map_boundaries() -> void:
	# Keep the town enclosed and allow only the west edge to return to the test overworld.
	_add_boundary("WestBoundary", Vector2(-TILE_SIZE / 2.0, MAP_HEIGHT * TILE_SIZE / 2.0), Vector2(TILE_SIZE, MAP_HEIGHT * TILE_SIZE + TILE_SIZE))
	_add_boundary("EastBoundary", Vector2(MAP_WIDTH * TILE_SIZE + TILE_SIZE / 2.0, MAP_HEIGHT * TILE_SIZE / 2.0), Vector2(TILE_SIZE, MAP_HEIGHT * TILE_SIZE + TILE_SIZE))
	_add_boundary("NorthBoundary", Vector2(MAP_WIDTH * TILE_SIZE / 2.0, -TILE_SIZE / 2.0), Vector2(MAP_WIDTH * TILE_SIZE + TILE_SIZE, TILE_SIZE))
	_add_boundary("SouthBoundary", Vector2(MAP_WIDTH * TILE_SIZE / 2.0, MAP_HEIGHT * TILE_SIZE + TILE_SIZE / 2.0), Vector2(MAP_WIDTH * TILE_SIZE + TILE_SIZE, TILE_SIZE))

	_add_map_transition_trigger(
		"WestExit",
		Vector2(32.0, MAP_HEIGHT * TILE_SIZE / 2.0),
		Vector2(64.0, MAP_HEIGHT * TILE_SIZE)
	)


func _add_map_transition_trigger(trigger_name: String, trigger_position: Vector2, trigger_size: Vector2) -> void:
	# Preserve vertical position when returning to the east edge of the debug overworld.
	var trigger := Area2D.new()
	trigger.name = trigger_name
	trigger.set_script(preload("res://systems/map_transition_trigger.gd"))
	trigger.set("target_scene", "res://world/maps/overworld/world.tscn")
	trigger.set("target_player_position", Vector2(960.0, 320.0))
	trigger.set("use_return_position", false)
	trigger.set("preserve_vertical_position", true)
	trigger.position = trigger_position

	var collision := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = trigger_size
	collision.shape = rectangle
	trigger.add_child(collision)
	add_child(trigger)


func _add_boundary(boundary_name: String, boundary_position: Vector2, boundary_size: Vector2) -> void:
	# Boundary bodies use the Player's existing collision layer.
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
