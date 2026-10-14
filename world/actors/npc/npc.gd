@tool
extends CharacterBody2D
class_name NPC

# Reusable NPC actor: shared player art, independent movement, and lightweight starter dialogue.
# Character-specific names, dialogue, movement mode, and patrol points are configured in the Inspector.

enum MovementMode { STATIONARY, WANDER, PATROL }

@export_group("Identity")
@export var display_name: String = "Villager"
@export_multiline var dialogue_lines: PackedStringArray = PackedStringArray([
	"Good day, traveler."
])

@export_group("Movement")
@export var movement_mode: MovementMode = MovementMode.STATIONARY
@export var move_speed: float = 45.0
@export var wander_radius: float = 48.0
@export var patrol_points: Array[Vector2] = []

@export_group("Animation")
@export var frame_size: Vector2i = Vector2i(64, 64)

const SHEET_DIR := "res://assets/sprites/player/"
const ANIMATIONS := {
	"idle": {"file": "Unarmed_Idle_without_shadow.png", "frames": 12, "fps": 3.0},
	"walk": {"file": "Unarmed_Walk_without_shadow.png", "frames": 6, "fps": 10.0},
	"run": {"file": "Unarmed_Run_without_shadow.png", "frames": 8, "fps": 14.0},
}
const DIRECTIONS := ["down", "left", "right", "up"]

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = $InteractionArea

var facing: String = "down"
var _player_in_range: Node2D
var _dialogue_layer: CanvasLayer
var _dialogue_panel: PanelContainer
var _name_label: Label
var _line_label: Label
var _dialogue_index: int = 0
var _dialogue_open: bool = false
var _movement_origin: Vector2
var _move_direction: Vector2 = Vector2.ZERO
var _move_timer: float = 0.0
var _patrol_index: int = 0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	# Generate SpriteFrames from the same PNG sheets as the player, so NPCs need no duplicate art.
	sprite.sprite_frames = _build_sprite_frames()
	sprite.play("idle_down")
	_movement_origin = global_position
	_rng.randomize()
	interaction_area.body_entered.connect(_on_interaction_body_entered)
	interaction_area.body_exited.connect(_on_interaction_body_exited)


func _physics_process(delta: float) -> void:
	# Tool mode should show the actor in the editor but never run NPC movement there.
	if Engine.is_editor_hint():
		return
	if _dialogue_open or movement_mode == MovementMode.STATIONARY:
		velocity = Vector2.ZERO
		move_and_slide()
		sprite.play("idle_" + facing)
		return

	_update_movement(delta)
	velocity = _move_direction * move_speed
	move_and_slide()

	if velocity.length_squared() > 1.0:
		if absf(velocity.x) > absf(velocity.y):
			facing = "left" if velocity.x < 0.0 else "right"
		else:
			facing = "up" if velocity.y < 0.0 else "down"
		sprite.play("walk_" + facing)
	else:
		sprite.play("idle_" + facing)


func _unhandled_input(event: InputEvent) -> void:
	# E starts a conversation when close enough, then advances each line.
	if not event is InputEventKey or not event.pressed or event.echo or event.keycode != KEY_E:
		return
	if _dialogue_open:
		_advance_dialogue()
	elif is_instance_valid(_player_in_range) and bool(_player_in_range.get("movement_enabled")):
		# Prevent overlapping interaction areas from opening multiple dialogue panels at once.
		_start_dialogue()
		get_viewport().set_input_as_handled()


func _update_movement(delta: float) -> void:
	if movement_mode == MovementMode.PATROL:
		_update_patrol()
		return

	# Wandering alternates short walking bursts and pauses, staying near the spawn position.
	_move_timer -= delta
	if _move_timer > 0.0:
		return
	if _move_direction != Vector2.ZERO:
		_move_direction = Vector2.ZERO
		_move_timer = _rng.randf_range(0.7, 1.8)
	else:
		var offset := global_position - _movement_origin
		if offset.length() >= wander_radius:
			_move_direction = (-offset).normalized()
		else:
			var angle := _rng.randf_range(0.0, TAU)
			_move_direction = Vector2(cos(angle), sin(angle))
		_move_timer = _rng.randf_range(0.8, 1.8)


func _update_patrol() -> void:
	# Patrol points are local positions relative to the NPC's parent. Empty paths safely idle.
	if patrol_points.is_empty():
		_move_direction = Vector2.ZERO
		return
	var target: Vector2 = get_parent().to_global(patrol_points[_patrol_index])
	var difference := target - global_position
	if difference.length() <= 5.0:
		_patrol_index = (_patrol_index + 1) % patrol_points.size()
		_move_direction = Vector2.ZERO
		return
	_move_direction = difference.normalized()


func _on_interaction_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		_player_in_range = body


func _on_interaction_body_exited(body: Node2D) -> void:
	if body == _player_in_range:
		_player_in_range = null


func _start_dialogue() -> void:
	if dialogue_lines.is_empty():
		return
	_dialogue_index = 0
	_dialogue_open = true
	_move_direction = Vector2.ZERO
	_set_player_movement_enabled(false)
	_build_dialogue_ui()
	_dialogue_panel.visible = true
	_show_dialogue_line()


func _advance_dialogue() -> void:
	_dialogue_index += 1
	if _dialogue_index >= dialogue_lines.size():
		_close_dialogue()
	else:
		_show_dialogue_line()
	get_viewport().set_input_as_handled()


func _close_dialogue() -> void:
	_dialogue_open = false
	if is_instance_valid(_dialogue_panel):
		_dialogue_panel.visible = false
	_set_player_movement_enabled(true)


func _show_dialogue_line() -> void:
	_name_label.text = display_name
	_line_label.text = dialogue_lines[_dialogue_index]


func _set_player_movement_enabled(enabled: bool) -> void:
	# The player exposes this flag so NPC dialogue can pause movement without owning player input.
	var player := get_tree().get_first_node_in_group("player")
	if player != null:
		player.set("movement_enabled", enabled)


func _build_dialogue_ui() -> void:
	# Create the simple reusable bottom-of-screen dialogue panel only when first needed.
	if is_instance_valid(_dialogue_layer):
		return
	_dialogue_layer = CanvasLayer.new()
	_dialogue_layer.name = "DialogueLayer"
	add_child(_dialogue_layer)

	var screen := Control.new()
	screen.name = "DialogueScreen"
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dialogue_layer.add_child(screen)

	_dialogue_panel = PanelContainer.new()
	_dialogue_panel.name = "DialoguePanel"
	_dialogue_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_dialogue_panel.offset_left = 32.0
	_dialogue_panel.offset_top = -142.0
	_dialogue_panel.offset_right = -32.0
	_dialogue_panel.offset_bottom = -20.0
	_dialogue_panel.visible = false
	screen.add_child(_dialogue_panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	_dialogue_panel.add_child(content)

	_name_label = Label.new()
	_name_label.name = "SpeakerName"
	_name_label.add_theme_font_size_override("font_size", 18)
	content.add_child(_name_label)

	_line_label = Label.new()
	_line_label.name = "DialogueText"
	_line_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_line_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(_line_label)


func _build_sprite_frames() -> SpriteFrames:
	# Reuse the player animation sheet layout and omit transparent cells to prevent blank frames.
	var frames := SpriteFrames.new()
	frames.clear_all()
	for animation_name in ANIMATIONS:
		var definition: Dictionary = ANIMATIONS[animation_name]
		var sheet_path := SHEET_DIR + str(definition["file"])
		var sheet := load(sheet_path) as Texture2D
		if sheet == null:
			push_error("NPC sprite sheet could not be loaded: " + sheet_path)
			continue
		var sheet_image := sheet.get_image()
		if sheet_image == null or sheet_image.is_empty():
			push_error("NPC sprite sheet image is empty: " + sheet_path)
			continue
		for row in range(DIRECTIONS.size()):
			var animation_id := str(animation_name) + "_" + str(DIRECTIONS[row])
			frames.add_animation(animation_id)
			frames.set_animation_speed(animation_id, float(definition["fps"]))
			frames.set_animation_loop(animation_id, true)
			for column in range(int(definition["frames"])):
				var region := Rect2i(column * frame_size.x, row * frame_size.y, frame_size.x, frame_size.y)
				if region.end.x > sheet_image.get_width() or region.end.y > sheet_image.get_height():
					continue
				if not _frame_has_visible_pixels(sheet_image, region):
					continue
				var atlas := AtlasTexture.new()
				atlas.atlas = sheet
				atlas.region = Rect2(region)
				frames.add_frame(animation_id, atlas)
			if frames.get_frame_count(animation_id) == 0:
				push_error("NPC has no visible frames for animation: " + animation_id)
	return frames


func _frame_has_visible_pixels(sheet_image: Image, region: Rect2i) -> bool:
	# Transparent cells are not animation frames; skip them just as the player script does.
	for y in range(region.position.y, region.position.y + region.size.y):
		for x in range(region.position.x, region.position.x + region.size.x):
			if sheet_image.get_pixel(x, y).a > 0.01:
				return true
	return false
