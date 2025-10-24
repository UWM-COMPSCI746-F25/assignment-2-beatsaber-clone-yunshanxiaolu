extends Node3D

@export var input_action: String = "ax_button"   
@export var controller: NodePath                
@export var start_on: bool = true
@export var disable_layers_when_off: bool = true

var _is_on: bool = true
var _was_pressed: bool = false
var _orig_layer: int = 0
var _orig_mask: int = 0

var blade_mesh: MeshInstance3D
var area: Area3D
var ctrl: XRController3D

func _ready() -> void:
	blade_mesh = get_node_or_null("BladeMesh_MeshInstance3D") as MeshInstance3D
	if blade_mesh == null:
		push_error("LaserSword: cannot find 'BladeMesh_MeshInstance3D'")
		return

	area = get_node_or_null("Area3D") as Area3D
	if area == null:
		push_error("LaserSword: cannot find 'Area3D'")
		return

	ctrl = get_node_or_null(controller) as XRController3D
	if ctrl == null:
		push_warning("LaserSword: 'controller' unset ")

	_orig_layer = area.collision_layer
	_orig_mask  = area.collision_mask

	_is_on = start_on
	_apply_state()

func _physics_process(_delta: float) -> void:
	if ctrl == null:
		return

	var pressed: bool = ctrl.get_input(StringName(input_action)) > 0.5
	if pressed and not _was_pressed:
		if _is_on:
			_is_on = false
		else:
			_is_on = true
		_apply_state()

	_was_pressed = pressed

func _apply_state() -> void:
	blade_mesh.visible = _is_on
	area.monitoring = _is_on

	if disable_layers_when_off:
		if _is_on:
			area.collision_layer = _orig_layer
			area.collision_mask  = _orig_mask
		else:
			area.collision_layer = 0
			area.collision_mask  = 0
