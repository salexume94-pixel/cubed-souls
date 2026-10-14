extends Node2D
## Keeps camera presentation separate from player movement.
## The camera follows a configurable Node2D target and centers on it immediately.

@export var target_path: NodePath = NodePath("../Player")
@onready var camera: Camera2D = $Camera2D

var target: Node2D


func _ready() -> void:
	# Resolve the target through an exported path so this camera can be reused.
	target = get_node_or_null(target_path) as Node2D
	if target == null:
		push_error("WorldPresentation could not find camera target: %s" % target_path)
		return

	# Make this the active camera and avoid an initial frame showing the world origin.
	camera.enabled = true
	camera.make_current()
	camera.global_position = target.global_position


func _physics_process(_delta: float) -> void:
	# Follow after physics movement so camera position reflects the latest player position.
	if is_instance_valid(target):
		camera.global_position = target.global_position
