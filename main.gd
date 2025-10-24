extends Node3D

const DESIRED_DISTANCE_TO_CUBE := 3.0

func _ready() -> void:
	var oxr := XRServer.find_interface("OpenXR")
	if oxr:
		oxr.connect("pose_recentered", Callable(self, "_on_openxr_pose_recentered"))
	else:
		push_warning("OpenXR interface not found. Recenter will not be handled.")

func _on_openxr_pose_recentered() -> void:
	print("Pose recentered: aligning player to the flying cube")

	var origin: XROrigin3D = $XROrigin3D
	if origin == null:
		push_warning("XROrigin3D not found. Cannot align player.")
		return

	origin.center_on_hmd(true, true, true)

	var target_cube: Node3D = _get_nearest_cube()
	if target_cube == null:
		return

	var player_pos: Vector3 = origin.global_position
	var cube_pos: Vector3 = target_cube.global_position

	var dir: Vector3 = cube_pos - player_pos
	dir.y = 0.0
	if dir.length() == 0.0:
		return
	dir = dir.normalized()

	origin.look_at(origin.global_position + dir, Vector3.UP)

	var forward: Vector3 = -origin.global_transform.basis.z
	forward.y = 0.0
	if forward.length() != 0.0:
		forward = forward.normalized()
	else:
		forward = dir

	var desired_player_pos: Vector3 = cube_pos - forward * DESIRED_DISTANCE_TO_CUBE
	desired_player_pos.y = player_pos.y
	origin.global_position = desired_player_pos

func _get_nearest_cube() -> Node3D:
	var candidates: Array[Node3D] = []

	var red := $"CubeSpawnerRed"
	if red != null:
		for child in red.get_children():
			if child is Node3D:
				candidates.append(child)

	var blue := $"CubeSpawnerBlue"
	if blue != null:
		for child in blue.get_children():
			if child is Node3D:
				candidates.append(child)

	if candidates.is_empty():
		return null

	var origin: XROrigin3D = $XROrigin3D
	if origin == null:
		return candidates[0]

	var best: Node3D = null
	var best_dist: float = INF

	for c in candidates:
		var d: float = origin.global_position.distance_to(c.global_position)
		if d < best_dist:
			best_dist = d
			best = c

	return best
