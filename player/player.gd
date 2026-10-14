extends CharacterBody2D

# Movement is intentionally self-contained so this player can be reused on other maps.
# The speed is expressed in world pixels per second; the current overworld grid is 16 px.
@export var move_speed: float = 110.0
@export var frame_size: Vector2i = Vector2i(64, 64)

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const SHEET_DIR := "res://assets/sprites/player/"
const ANIMATIONS := {
	"idle": {"file": "Unarmed_Idle_without_shadow.png", "frames": 12, "fps": 6.0},
	"walk": {"file": "Unarmed_Walk_without_shadow.png", "frames": 6, "fps": 10.0},
	"run": {"file": "Unarmed_Run_without_shadow.png", "frames": 8, "fps": 14.0},
}
const DIRECTIONS := ["down", "left", "right", "up"]

var facing: String = "down"
var is_running: bool = false


func _ready() -> void:
	# Build frames from the existing sprite sheets instead of duplicating art assets.
	sprite.sprite_frames = _build_sprite_frames()
	sprite.play("idle_down")


func _physics_process(_delta: float) -> void:
	# Use the standard Godot input actions so keyboard remapping remains possible.
	var input_direction := _get_move_input()
	velocity = input_direction * move_speed
	move_and_slide()

	if input_direction != Vector2.ZERO:
		# Keep diagonal movement from changing the player's facing unpredictably.
		if absf(input_direction.x) > absf(input_direction.y):
			facing = "left" if input_direction.x < 0.0 else "right"
		else:
			facing = "up" if input_direction.y < 0.0 else "down"
		sprite.play("walk_" + facing)
	else:
		sprite.play("idle_" + facing)


func _build_sprite_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.clear_all() # Remove the default animation so only known animations are exposed.

	for animation_name in ANIMATIONS:
		var definition: Dictionary = ANIMATIONS[animation_name]
		var sheet := load(SHEET_DIR + str(definition["file"])) as Texture2D
		if sheet == null:
			push_error("Player sprite sheet could not be loaded: " + SHEET_DIR + str(definition["file"]))
			continue

		for row in range(DIRECTIONS.size()):
			var animation_id: String = str(animation_name) + "_" + str(DIRECTIONS[row])
			frames.add_animation(animation_id)
			frames.set_animation_speed(animation_id, float(definition["fps"]))
			frames.set_animation_loop(animation_id, true)
			for column in range(int(definition["frames"])):
				var atlas := AtlasTexture.new()
				atlas.atlas = sheet
				atlas.region = Rect2(
					column * frame_size.x,
					row * frame_size.y,
					frame_size.x,
					frame_size.y
				)
				frames.add_frame(animation_id, atlas)

	return frames


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
