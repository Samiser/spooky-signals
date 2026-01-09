extends AnimatableBody3D

@export var func_godot_properties : Dictionary

var is_moving := true
var rotate_dir : Vector3i
var rotate_speed : float

func _ready() -> void:
	rotate_dir = func_godot_properties.get("rotate_dir", Vector3.ZERO);
	rotate_speed = func_godot_properties.get("rotate_speed", 0.0);
	
	var	audio_source := AudioStreamPlayer3D.new()
	add_child(audio_source)
	audio_source.stream = load("res://audio/sfx/fan.wav")
	audio_source.max_distance = 10.0
	audio_source.unit_size = 1.0
	audio_source.pitch_scale = clampf(abs(rotate_speed / 10.0), 0.0, 10.0) 
	audio_source.play()
	
func _process(delta: float) -> void:
	rotate_object_local(rotate_dir, delta * rotate_speed)
	
