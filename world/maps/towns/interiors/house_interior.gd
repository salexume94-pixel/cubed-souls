extends Node2D

# The house interior is intentionally editor-authored.
# Do not clear or regenerate its TileMapLayers; manual tile placements must persist.

const ROOM_WIDTH: int = 24
const ROOM_HEIGHT: int = 16


func _ready() -> void:
	_configure_interior_camera()


func _configure_interior_camera() -> void:
	# Keep the room centered without following the Player around the interior.
	var scene_root := get_tree().current_scene
	if scene_root == null:
		return

	var player := scene_root.find_child("Player", true, false) as Node2D
	if player == null:
		return

	var camera := player.get_node_or_null("Camera2D") as Camera2D
	if camera != null:
		camera.center_on_map(Vector2i(ROOM_WIDTH, ROOM_HEIGHT), 2.5)
