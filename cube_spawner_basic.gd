extends Node3D

@export var cube_scene: PackedScene
@export var player_camera: NodePath
@export var spawn_z: float = 12.0
@export var x_range: Vector2 = Vector2(-1.2, 1.2)
@export var y_range: Vector2 = Vector2(-0.3, 0.6)
@export var min_interval: float = 0.5
@export var max_interval: float = 2.0
@export var use_negative_z_forward: bool = true

var _timer: Timer

func _ready() -> void:
	randomize()
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_on_timeout)
	add_child(_timer)
	_arm_timer()

func _arm_timer() -> void:
	var wait_time: float = randf_range(min_interval, max_interval)
	_timer.start(wait_time)

func _on_timeout() -> void:
	_spawn_one()
	_arm_timer()

func _spawn_one() -> void:
	if cube_scene == null:
		push_error("Spawner: cube_scene unset")
		return

	var cam: Node3D = get_node_or_null(player_camera) as Node3D
	if cam == null:
		push_error("Spawner: player_camera unset or not Node3D")
		return

	var cam_pos: Vector3 = cam.global_transform.origin
	var x_off: float = randf_range(x_range.x, x_range.y)
	var y_off: float = randf_range(y_range.x, y_range.y)

	var spawn_pos: Vector3 = Vector3(
		cam_pos.x + x_off,
		cam_pos.y + y_off,
		cam_pos.z + spawn_z
	)

	var dir: Vector3 = Vector3(0, 0, -1)
	if not use_negative_z_forward:
		dir = Vector3(0, 0, 1)

	var cube: Node3D = cube_scene.instantiate() as Node3D
	if cube == null:
		push_error("Spawner: fail")
		return

	get_tree().current_scene.add_child(cube)
	cube.global_transform.origin = spawn_pos

	if cube.has_method("set_move_dir"):
		cube.call("set_move_dir", dir)
