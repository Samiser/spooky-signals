extends AnimatableBody3D

@export var func_godot_properties : Dictionary

var at_end := false
var is_moving := true
var restarted := false
var origin : Vector3
var dest := Vector3.ZERO
var move_time := 1.0
var wait_time := 0.0
var audio_source : AudioStreamPlayer3D

func _ready() -> void:
	origin = global_position
	wait_time = 1.0
	dest = origin + func_godot_properties.get("move_offset", Vector3.ZERO);
	move_time = func_godot_properties.get("move_rate", 0.0);
	
	audio_source = AudioStreamPlayer3D.new()
	add_child(audio_source)
	audio_source.stream = load("res://audio/sfx/elevator.wav")
	audio_source.max_distance = 10.0
	audio_source.unit_size = 4.0
	
func _process(delta: float) -> void:
	if(!is_moving): return
	
	if wait_time > 0.0:
		wait_time -= delta
		return
	elif !restarted:
		audio_source.play()
		restarted = true
		
	var cur_dest := dest
	if at_end:
		cur_dest = origin
	
	global_position = global_position.move_toward(cur_dest, move_time * delta)
	
	if global_position == cur_dest:
		audio_source.stop()
		wait_time = 1.0
		at_end = !at_end
		restarted = false
