extends Camera2D

# Apply the current map's tile bounds to this reusable player camera.
# Any map built from TileMapLayer nodes can use the same player scene without
# hard-coding that map's dimensions into the player or camera scene.

func _ready() -> void:
	# Defer until map scripts have populated their TileMapLayers and used rects.
	call_deferred("_apply_map_bounds")


func _apply_map_bounds() -> void:
	var current_scene := get_tree().current_scene
	if current_scene == null:
		return

	var layers := current_scene.find_children("*", "TileMapLayer", true, false)
	var found_bounds := false
	var min_x := 0.0
	var min_y := 0.0
	var max_x := 0.0
	var max_y := 0.0

	for node in layers:
		var layer := node as TileMapLayer
		if layer == null or layer.tile_set == null:
			continue

		var used_rect: Rect2i = layer.get_used_rect()
		if used_rect.size == Vector2i.ZERO:
			continue

		# get_used_rect() ends at an exclusive cell coordinate. Convert the
		# outer cell edges, rather than cell centers, into world coordinates.
		var half_tile := Vector2(layer.tile_set.tile_size) * 0.5
		var local_top_left := layer.map_to_local(used_rect.position) - half_tile
		var local_bottom_right := layer.map_to_local(used_rect.end) - half_tile
		var corners: Array[Vector2] = [
			layer.to_global(local_top_left),
			layer.to_global(Vector2(local_bottom_right.x, local_top_left.y)),
			layer.to_global(local_bottom_right),
			layer.to_global(Vector2(local_top_left.x, local_bottom_right.y)),
		]

		for corner in corners:
			if not found_bounds:
				min_x = corner.x
				min_y = corner.y
				max_x = corner.x
				max_y = corner.y
				found_bounds = true
			else:
				min_x = minf(min_x, corner.x)
				min_y = minf(min_y, corner.y)
				max_x = maxf(max_x, corner.x)
				max_y = maxf(max_y, corner.y)

	if not found_bounds:
		# Leave the camera unrestricted for scenes that do not use TileMapLayer.
		return

	# Camera2D limits are world-space pixel edges, calculated per active map.
	limit_left = floori(min_x)
	limit_top = floori(min_y)
	limit_right = ceili(max_x)
	limit_bottom = ceili(max_y)
