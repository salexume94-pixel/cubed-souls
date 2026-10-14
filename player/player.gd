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
	var input_direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
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
	frames.clear() # Remove the default animation so only known animations are exposed.

	for animation_name in ANIMATIONS:
		var definition: Dictionary = ANIMATIONS[animation_name]
		var sheet := load(SHEET_DIR + str(definition["file"])) as Texture2D
		if sheet == null:
			push_error("Player sprite sheet could not be loaded: " + SHEET_DIR + str(definition["file"]))
			continue

		for row in range(DIRECTIONS.size()):
			var name := str(animation_name) + "_" + DIRECTIONS[row]
			frames.add_animation(name)
			frames.set_animation_speed(name, float(definition["fps"]))
			frames.set_animation_loop(name, true)
			for column in range(int(definition["frames"])):
				var atlas := AtlasTexture.new()
				atlas.atlas = sheet
				atlas.region = Rect2(
					column * frame_size.x,
					row * frame_size.y,
					frame_size.x,
					frame_size.y
				)
				frames.add_frame(name, atlas)

	return frames
