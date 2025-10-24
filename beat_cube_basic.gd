extends Area3D

@export var speed: float = 4.0                    
@export var travel_limit: float = 40.0            

var _traveled: float = 0.0
var _alive: bool = true
var _move_dir: Vector3 = Vector3(0, 0, -1)   

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var sfx: AudioStreamPlayer3D = $AudioStreamPlayer3D

func set_move_dir(v: Vector3) -> void:
	if v.length() > 0.0:
		_move_dir = v.normalized()

func _ready() -> void:
	set_physics_process(true)

	area_entered.connect(_on_area_entered)
	if sfx != null:
		if not sfx.is_connected("finished", Callable(self, "_on_sfx_finished")):
			sfx.finished.connect(_on_sfx_finished)

func _physics_process(delta: float) -> void:
	var step: float = speed * delta
	global_translate(_move_dir * step)
	_traveled += step
	if _traveled >= travel_limit:
		queue_free()

func _on_area_entered(_other: Area3D) -> void:
	if not _alive:
		return
	_alive = false
	monitoring = false
	if mesh != null:
		mesh.visible = false

	if sfx != null and sfx.stream != null:
		sfx.global_position = global_position
		sfx.play()
	else:
		queue_free()

func _on_sfx_finished() -> void:
	queue_free()
