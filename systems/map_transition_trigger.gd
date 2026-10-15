extends Area2D
## Reusable non-solid map edge/entry trigger.
##
## The owning map configures the destination path and Player spawn. The trigger
## detects only the Player's physics layer and delegates all swapping/fading to
## the persistent SceneManager autoload.

@export_file("*.tscn") var target_scene: String = ""
@export var target_player_position: Vector2 = Vector2.ZERO
@export var use_return_position: bool = false
@export var return_position_offset: Vector2 = Vector2.ZERO
@export var preserve_vertical_position: bool = false


func _ready() -> void:
	# The Player is on collision layer 2. This trigger should detect, not block.
	collision_layer = 0
	collision_mask = 2
	monitoring = true
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	# Ignore NPCs and other physics bodies; only the Player changes maps.
	if not body.is_in_group("player"):
		return
	# Keep the same relative height along matching horizontal map edges.
	# Global coordinates are used because Player and map triggers are siblings under Main.
	var destination_position := target_player_position
	if preserve_vertical_position:
		destination_position.y += body.global_position.y - global_position.y
	SceneManager.change_map(target_scene, destination_position, use_return_position, return_position_offset)
