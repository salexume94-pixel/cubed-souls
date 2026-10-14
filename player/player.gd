@tool
extends CharacterBody2D

# Movement is intentionally self-contained so this player can be reused on other maps.
# The speed is expressed in world pixels per second; the current overworld grid is 16 px.
@export var move_speed: float = 110.0
@export var run_speed_multiplier: float = 1.6
@export var frame_size: Vector2i = Vector2i(64, 64)

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const SHEET_DIR := "res://assets/sprites/player/"
const ANIMATIONS := {
	"idle": {"file": "Unarmed_Idle_without_shadow.png", "frames": 12, "fps": 3.0},
	"walk": {"file": "Unarmed_Walk_without_shadow.png", "frames": 6, "fps": 10.0},
	"run": {"file": "Unarmed_Run_without_shadow.png", "frames": 8, "fps": 14.0},
}
const DIRECTIONS := ["down", "left", "right", "up"]

var facing: String = "down"
var is_running: bool = false


func _ready() -> void:
	# Build frames in both the editor and game so the player sprite is visible before Play.
	sprite.sprite_frames = _build_sprite_frames()
	sprite.play("idle_down")


func _physics_process(_delta: float) -> void:
	# Tool scripts can process in the editor; never move the player while editing the scene.
	if Engine.is_editor_hint():
		return

	# Shift temporarily increases speed; no Input Map setup is needed.
	var input_direction := _get_move_input()
	is_running = Input.is_key_pressed(KEY_SHIFT) and input_direction != Vector2.ZERO
	var current_speed := move_speed * run_speed_multiplier if is_running else move_speed
	velocity = input_direction * current_speed
	move_and_slide()

	if input_direction != Vector2.ZERO:
		# Keep diagonal movement from changing the player's facing unpredictably.
		if absf(input_direction.x) > absf(input_direction.y):
			facing = "left" if input_direction.x < 0.0 else "right"
		else:
			facing = "up" if input_direction.y < 0.0 else "down"

		# Use the matching run cycle only while moving and holding Shift.
		var movement_animation := "run_" if is_running else "walk_"
		sprite.play(movement_animation + facing)
	else:
		sprite.play("idle_" + facing)


func _build_sprite_frames() -> SpriteFrames:
	# Construct SpriteFrames from the existing PNG sheets so no duplicate art resource is needed.
	var frames := SpriteFrames.new()
	frames.clear_all() # Remove the default animation so only known animations are exposed.

	for animation_name in ANIMATIONS:
		var definition: Dictionary = ANIMATIONS[animation_name]
		var sheet_path := SHEET_DIR + str(definition["file"])
		var sheet := load(sheet_path) as Texture2D
		if sheet == null:
			push_error("Player sprite sheet could not be loaded: " + sheet_path)
			continue

		# Some sprite sheets contain transparent cells; exclude them so the character
		# never disappears for a frame when an animation reaches an unused cell.
		var sheet_image := sheet.get_image()
		if sheet_image == null or sheet_image.is_empty():
			push_error("Player sprite sheet image is empty: " + sheet_path)
			continue

		for row in range(DIRECTIONS.size()):
			var animation_id: String = str(animation_name) + "_" + str(DIRECTIONS[row])
			frames.add_animation(animation_id)
			frames.set_animation_speed(animation_id, float(definition["fps"]))
			frames.set_animation_loop(animation_id, true)

			for column in range(int(definition["frames"])):
				var region := Rect2i(
					column * frame_size.x,
					row * frame_size.y,
					frame_size.x,
					frame_size.y
				)
				if region.position.x + region.size.x > sheet_image.get_width() or region.position.y + region.size.y > sheet_image.get_height():
					push_warning("Skipping out-of-bounds sprite frame in " + animation_id)
					continue
				# Transparent cells are expected in some rows, so skip silently
				# instead of flooding the debugger with a warning for every unused cell.
				if not _frame_has_visible_pixels(sheet_image, region):
					continue

				var atlas := AtlasTexture.new()
				atlas.atlas = sheet
				atlas.region = Rect2(region)
				frames.add_frame(animation_id, atlas)

			if frames.get_frame_count(animation_id) == 0:
				push_error("No visible sprite frames were found for animation: " + animation_id)

	return frames


func _frame_has_visible_pixels(sheet_image: Image, region: Rect2i) -> bool:
	# A fully transparent atlas cell renders as a missing character for one frame.
	for y in range(region.position.y, region.position.y + region.size.y):
		for x in range(region.position.x, region.position.x + region.size.x):
			if sheet_image.get_pixel(x, y).a > 0.01:
				return true
	return false


func _get_move_input() -> Vector2:
	# Support both WASD and arrow keys without requiring editor input-map setup.
	var direction := Vector2.ZERO
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		direction.x -= 1.0
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		direction.x += 1.0
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		direction.y -= 1.0
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		direction.y += 1.0
	return direction.normalized()
