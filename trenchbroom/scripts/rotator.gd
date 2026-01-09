extends AnimatableBody3D

@export var func_godot_properties : Dictionary

var is_moving := true
var rotate_dir : Vector3i
var rotate_speed : float

func _ready() -> void:
	rotate_dir = func_godot_properties.get("rotate_dir", Vector3.ZERO);
	rotate_speed = func_godot_properties.get("rotate_speed", 0.0);
	
func _process(delta: float) -> void:
	rotate(rotate_dir, delta * rotate_speed)
	
