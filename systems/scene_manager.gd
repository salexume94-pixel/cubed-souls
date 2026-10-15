extends Node
## Coordinates map-to-map transitions while keeping the Player alive.
##
## The current project keeps the Player as a child of the main scene and swaps
## only the active map node. This differs from the previous project, where each
## destination scene could own its own Player instance. Keeping one Player avoids
## duplicating runtime state when entering or leaving a map.

var transition_in_progress: bool = false
var return_player_position: Vector2 = Vector2.ZERO
var has_return_player_position: bool = false

var transition_overlay: ColorRect
var transition_label: Label


func _ready() -> void:
	# A persistent overlay prevents a one-frame map swap from appearing as a pop.
	var canvas := CanvasLayer.new()
	canvas.name = "MapTransitionCanvas"
	canvas.layer = 200
	add_child(canvas)

	transition_overlay = ColorRect.new()
	transition_overlay.name = "MapTransitionOverlay"
	transition_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	transition_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	transition_overlay.visible = false
	canvas.add_child(transition_overlay)

	transition_label = Label.new()
	transition_label.name = "MapTransitionMessage"
	transition_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	transition_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	transition_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	transition_label.add_theme_font_size_override("font_size", 28)
	transition_overlay.add_child(transition_label)


func change_map(
	scene_path: String,
	player_position: Vector2,
	use_return_position: bool = false,
	return_position_offset: Vector2 = Vector2.ZERO
) -> void:
	# Ignore overlapping trigger signals while a transition is running.
	if transition_in_progress:
		return
	if scene_path.is_empty():
		push_error("SceneManager cannot change to an empty map scene path.")
		return

	var packed_scene := load(scene_path) as PackedScene
	if packed_scene == null:
		push_error("SceneManager could not load map scene: %s" % scene_path)
		return

	var root := get_tree().current_scene
	if root == null or root.find_child("Player", true, false) == null:
		push_error("SceneManager needs an active scene containing a Player node.")
		return

	# Locate the map by its structure instead of assuming its root is always named "World".
	var active_map := _find_active_map(root)
	if active_map == null:
		push_error("SceneManager could not identify the active map containing a Ground TileMapLayer.")
		return

	# Leaving a map normally restores the exact position saved when it was entered.
	if use_return_position and has_return_player_position:
		player_position = return_player_position
		has_return_player_position = false
	elif not use_return_position:
		var player := root.find_child("Player", true, false) as Node2D
		return_player_position = player.position + return_position_offset
		has_return_player_position = true

	transition_in_progress = true
	call_deferred("_perform_map_change", packed_scene, scene_path, player_position)


func _perform_map_change(
	packed_scene: PackedScene,
	scene_path: String,
	destination_position: Vector2
) -> void:
	# Fade out before replacing the map so the swap is hidden from the player.
	transition_label.text = _get_transition_message(scene_path)
	transition_overlay.visible = true
	transition_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	await _fade_to(Color(0.0, 0.0, 0.0, 1.0), 0.12)

	var root := get_tree().current_scene
	if root == null:
		push_error("SceneManager lost the active scene during a map transition.")
		_finish_transition()
		return

	# Use the same structural lookup here so validation and swapping agree.
	var old_map := _find_active_map(root)
	if old_map == null:
		push_error("SceneManager could not identify the active map during the transition.")
		_finish_transition()
		return

	# The destination scenes contain map content only. Reparenting the new map
	# under Main preserves the single Player, menus, and other persistent nodes.
	var new_map := packed_scene.instantiate()
	new_map.name = "World"
	var map_parent := old_map.get_parent()
	var old_index := old_map.get_index()
	map_parent.add_child(new_map)
	map_parent.move_child(new_map, old_index)
	old_map.queue_free()

	# Wait one frame for the new map and its generated collision to initialize.
	await get_tree().process_frame
	var player := root.find_child("Player", true, false) as Node2D
	if player == null:
		push_error("SceneManager could not find the Player after swapping maps.")
		_finish_transition()
		return
	player.position = destination_position

	await get_tree().create_timer(0.12).timeout
	await _fade_to(Color(0.0, 0.0, 0.0, 0.0), 0.18)
	_finish_transition()


func _find_active_map(root: Node) -> Node2D:
	# Map scenes have a direct Ground TileMapLayer; the player does not.
	# Check the root itself first, then descendants to support different map root names.
	if root is Node2D and root.get_node_or_null("Ground") is TileMapLayer:
		return root as Node2D

	for candidate in root.find_children("*", "Node2D", true, false):
		if candidate.name == "Player":
			continue
		if candidate.get_node_or_null("Ground") is TileMapLayer:
			return candidate as Node2D

	return null


func _fade_to(target_color: Color, duration: float) -> void:
	# Tween the overlay; no frame-blocking wait is needed.
	var tween := create_tween()
	tween.tween_property(transition_overlay, "color", target_color, duration)
	await tween.finished


func _finish_transition() -> void:
	transition_overlay.visible = false
	transition_in_progress = false


func _get_transition_message(destination_path: String) -> String:
	# Keep labels generic so new map scenes do not need manager changes.
	if destination_path.contains("/towns/"):
		return "Entering Havenreach"
	if destination_path.contains("/overworld/"):
		return "Leaving settlement"
	return "Changing area"
