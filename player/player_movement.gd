extends CharacterBody2D
## Owns the first-pass player movement for Cubed Souls.
## Kept independent from combat, dialogue, inventory, and other systems so this
## scene can be verified before gameplay dependencies are introduced.

# Walking speed in world pixels per second.
@export var move_speed: float = 225.0

# Holding Shift multiplies walking speed by this amount.
@export var run_speed_multiplier: float = 1.6

# Track the last non-zero input so the sprite can retain its facing direction.
var facing_direction: Vector2 = Vector2.DOWN


func _physics_process(_delta: float) -> void:
	# Read the standard Godot directional actions; these are mapped to arrows by default.
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# Shift temporarily increases speed without changing the input direction.
	var is_running := direction != Vector2.ZERO and Input.is_key_pressed(KEY_SHIFT)
	var current_speed := move_speed
	if is_running:
		current_speed *= run_speed_multiplier

	# Preserve the last facing direction when no movement key is held.
	if direction != Vector2.ZERO:
		facing_direction = direction

	# CharacterBody2D handles collision response through move_and_slide().
	velocity = direction * current_speed
	move_and_slide()
