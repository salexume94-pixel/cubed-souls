@tool
extends CharacterBody2D
class_name NPC

# Reusable NPC actor: shared player art, independent movement, and lightweight starter dialogue.
# Character-specific names, dialogue, movement mode, and patrol points are configured in the Inspector.

enum BehaviorProfile { STATIONARY, CIVILIAN, GUARD, ALLY }

## Proximity signals let party/story code react to Allies without coupling this actor to those systems.
signal ally_player_entered(ally: Node2D, player: Node2D)
signal ally_player_exited(ally: Node2D, player: Node2D)

@export_group("Identity")
@export var display_name: String = "Villager"
@export var dialogue_lines: PackedStringArray = PackedStringArray([
	"Good day, traveler."
])

@export_group("Behavior Profile")
@export var behavior_profile: BehaviorProfile = BehaviorProfile.STATIONARY
@export var move_speed: float = 45.0
## Maximum distance a civilian or ally normally wanders from its spawn point.
@export var wander_radius: float = 96.0
## Civilians and allies create space when the Player approaches this distance.
@export var personal_space: float = 36.0
## Patrol points are local positions relative to this NPC's parent. Guards without points stay at their post.
@export var patrol_points: Array[Vector2] = []
@export var think_interval: float = 0.45
@export var obstacle_probe_distance: float = 28.0
@export var ally_detection_radius: float = 56.0
## Story/cutscene movement can temporarily override autonomous movement.
var story_movement_active: bool = false
var story_ignore_world_collision: bool = false
var story_movement_target: Vector2 = Vector2.ZERO

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
var _movement_target: Vector2
var _move_direction: Vector2 = Vector2.ZERO
var _move_timer: float = 0.0
var _patrol_index: int = 0
var _stuck_time: float = 0.0
var _last_physics_position: Vector2 = Vector2.ZERO
var _escape_override_time: float = 0.0
var _escape_override_direction: Vector2 = Vector2.ZERO
var _ally_detection_area: Area2D
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	# Generate SpriteFrames from the same PNG sheets as the player, so NPCs need no duplicate art.
	sprite.sprite_frames = _build_sprite_frames()
	sprite.play("idle_down")
	_movement_origin = global_position
	_last_physics_position = global_position
	_rng.randomize()
	add_to_group("npc")
	add_to_group("interactable")

	# Separate collision layers let NPCs avoid world geometry and other NPCs without being shoved by the Player.
	collision_layer = 4
	collision_mask = 5
	interaction_area.collision_layer = 0
	interaction_area.collision_mask = 2
	interaction_area.body_entered.connect(_on_interaction_body_entered)
	interaction_area.body_exited.connect(_on_interaction_body_exited)

	if behavior_profile == BehaviorProfile.ALLY:
		_create_ally_detection_area()


func _physics_process(delta: float) -> void:
	# Editor previews display the actor but never run autonomous movement.
	if Engine.is_editor_hint():
		return

	if _dialogue_open or (behavior_profile == BehaviorProfile.STATIONARY and not story_movement_active):
		velocity = Vector2.ZERO
		move_and_slide()
		sprite.play("idle_" + facing)
		return

	if story_movement_active:
		var story_offset := story_movement_target - global_position
		_move_direction = Vector2.ZERO if story_offset.length() < 6.0 else story_offset.normalized()
	elif _escape_override_time > 0.0:
		_escape_override_time = maxf(0.0, _escape_override_time - delta)
		_move_direction = _escape_override_direction
	else:
		_move_timer -= delta
		if _move_timer <= 0.0:
			_move_timer = think_interval
			_choose_behavior_target()
		if global_position.distance_to(_movement_target) < 6.0:
			_move_direction = Vector2.ZERO
		else:
			_move_direction = global_position.direction_to(_movement_target)

	var safe_direction := _move_direction
	if not (story_movement_active and story_ignore_world_collision):
		safe_direction = _avoid_obstacles(_move_direction)
	velocity = safe_direction * move_speed
	move_and_slide()

	# Recover if collisions leave an actor stuck against a corner or another moving NPC.
	var moved_distance := global_position.distance_to(_last_physics_position)
	if not story_movement_active and not _move_direction.is_zero_approx() and moved_distance < 0.5:
		_stuck_time += delta
		if _stuck_time >= 0.45:
			_stuck_time = 0.0
			_escape_override_time = 0.6
			if is_instance_valid(_player_in_range):
				_escape_override_direction = (global_position - _player_in_range.global_position).normalized()
			else:
				_escape_override_direction = Vector2.RIGHT.rotated(_rng.randf_range(-PI, PI))
			if _escape_override_direction.is_zero_approx():
				_escape_override_direction = Vector2.RIGHT.rotated(_rng.randf_range(-PI, PI))
			_move_timer = think_interval
	else:
		_stuck_time = 0.0
	_last_physics_position = global_position

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


func _choose_behavior_target() -> void:
	# Guards follow their authored route. A guard without patrol points stays at its post.
	if behavior_profile == BehaviorProfile.GUARD:
		_choose_patrol_target()
		return

	# Civilians and Allies wander within a bounded home area and step away from the Player's personal space.
	if behavior_profile in [BehaviorProfile.CIVILIAN, BehaviorProfile.ALLY]:
		var home_offset := global_position - _movement_origin
		if home_offset.length() >= wander_radius * 0.85:
			_movement_target = _movement_origin
			return

		var player := get_tree().get_first_node_in_group("player") as Node2D
		if player != null:
			var player_distance := global_position.distance_to(player.global_position)
			if player_distance <= personal_space:
				var away := (global_position - player.global_position).normalized()
				if away.is_zero_approx():
					away = Vector2.RIGHT.rotated(_rng.randf_range(-PI, PI))
				var retreat_target := global_position + away * minf(wander_radius, personal_space * 1.5)
				var retreat_offset := retreat_target - _movement_origin
				var home_limit := wander_radius * 0.75
				if retreat_offset.length() > home_limit:
					retreat_target = _movement_origin + retreat_offset.normalized() * home_limit
				_movement_target = retreat_target
				return

		# Sample uniformly across the circular home area, rather than favoring its center.
		var angle := _rng.randf_range(-PI, PI)
		var distance := sqrt(_rng.randf()) * wander_radius
		_movement_target = _movement_origin + Vector2.RIGHT.rotated(angle) * distance
		return

	_movement_target = _movement_origin


func _choose_patrol_target() -> void:
	# Patrol coordinates are local to the parent so routes can be authored in the map scene.
	if patrol_points.is_empty():
		_movement_target = _movement_origin
		return
	var patrol_parent := get_parent() as Node2D
	if patrol_parent == null:
		_movement_target = _movement_origin
		return
	var target := patrol_parent.to_global(patrol_points[_patrol_index])
	if global_position.distance_to(target) <= 6.0:
		_patrol_index = (_patrol_index + 1) % patrol_points.size()
		_move_timer = 0.35
		_movement_target = patrol_parent.to_global(patrol_points[_patrol_index])
	else:
		_movement_target = target


func _create_ally_detection_area() -> void:
	# Allies expose proximity events independently of body collision or dialogue.
	_ally_detection_area = Area2D.new()
	_ally_detection_area.name = "AllyDetectionArea"
	_ally_detection_area.position = Vector2(0, -24)
	_ally_detection_area.collision_layer = 0
	_ally_detection_area.collision_mask = 2
	_ally_detection_area.monitoring = true
	_ally_detection_area.monitorable = false
	var sensor_shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = ally_detection_radius
	sensor_shape.shape = circle
	_ally_detection_area.add_child(sensor_shape)
	add_child(_ally_detection_area)
	_ally_detection_area.body_entered.connect(_on_ally_detection_body_entered)
	_ally_detection_area.body_exited.connect(_on_ally_detection_body_exited)


func _on_ally_detection_body_entered(body: Node2D) -> void:
	if behavior_profile == BehaviorProfile.ALLY and body.is_in_group("player"):
		ally_player_entered.emit(self, body)


func _on_ally_detection_body_exited(body: Node2D) -> void:
	if behavior_profile == BehaviorProfile.ALLY and body.is_in_group("player"):
		ally_player_exited.emit(self, body)


func move_to_story_target(target_position: Vector2, ignore_world_collision: bool = false) -> void:
	# Story code can override autonomous movement without owning the NPC's locomotion logic.
	story_movement_active = true
	story_ignore_world_collision = ignore_world_collision
	story_movement_target = target_position
	if ignore_world_collision:
		collision_mask = 4
	else:
		collision_mask = 5


func clear_story_movement() -> void:
	# Resume the selected profile and restore normal world/NPC collision after a scripted move.
	story_movement_active = false
	story_ignore_world_collision = false
	collision_mask = 5
	_movement_target = _movement_origin
	_move_timer = 0.0


func _avoid_obstacles(direction: Vector2) -> Vector2:
	if obstacle_probe == null or direction.is_zero_approx():
		return direction
	if _is_direction_clear(direction):
		return direction
	for angle in [PI / 4.0, -PI / 4.0, PI / 2.0, -PI / 2.0, PI * 3.0 / 4.0, -PI * 3.0 / 4.0, PI]:
		var alternative := direction.rotated(angle)
		if _is_direction_clear(alternative):
			return alternative
	return Vector2.ZERO


func _is_direction_clear(direction: Vector2) -> bool:
	# Three parallel raycasts approximate the width of the capsule and catch wall edges.
	var original_position := obstacle_probe.position
	var lateral := direction.rotated(PI / 2.0).normalized() * 8.0
	for offset in [Vector2.ZERO, lateral, -lateral]:
		obstacle_probe.position = original_position + offset
		obstacle_probe.target_position = direction.normalized() * obstacle_probe_distance
		obstacle_probe.force_raycast_update()
		if obstacle_probe.is_colliding():
			obstacle_probe.position = original_position
			return false
	obstacle_probe.position = original_position
	return true


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
