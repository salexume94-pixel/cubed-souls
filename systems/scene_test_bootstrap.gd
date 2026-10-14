extends Node

# Standalone scene testing lets F6 launch a map directly while still giving it a player.
# The normal main scene already owns its player, so this bootstrap only fills in missing players.
const PLAYER_SCENE: PackedScene = preload("res://player/player.tscn")


func _ready() -> void:
	# Wait until Godot has installed the selected scene before checking it.
	get_tree().scene_changed.connect(_on_scene_changed)
	call_deferred("_ensure_player_for_scene", get_tree().current_scene)


func _on_scene_changed(scene_root: Node) -> void:
	# Handle F6 and other whole-scene launches without changing child-map transitions.
	call_deferred("_ensure_player_for_scene", scene_root)


func _ensure_player_for_scene(scene_root: Node) -> void:
	# Ignore stale scene notifications and scenes that are not active anymore.
	if scene_root == null or scene_root != get_tree().current_scene:
		return

	# Find the conventional spawn marker anywhere in the selected scene.
	var spawn_marker := scene_root.find_child("PlayerSpawnMarker", true, false) as Marker2D
	if spawn_marker == null:
		spawn_marker = scene_root.find_child("PlayerSpawn", true, false) as Marker2D

	# Main game scenes may not have a map spawn marker; leave their existing setup alone.
	if spawn_marker == null:
		return

	# Reuse an existing player when present; otherwise instantiate one for standalone map testing.
	var player := scene_root.find_child("Player", true, false) as CharacterBody2D
	if player == null:
		player = PLAYER_SCENE.instantiate() as CharacterBody2D
		if player == null:
			push_error("SceneTestBootstrap: could not instantiate player/player.tscn.")
			return
		scene_root.add_child(player)

	# Place the player after adding it to the active scene so global coordinates are valid.
	player.global_position = spawn_marker.global_position
