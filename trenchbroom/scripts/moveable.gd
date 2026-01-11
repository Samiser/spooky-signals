extends Reciever

@export var func_godot_properties : Dictionary
var signal_ID : String

@onready var body: AnimatableBody3D = $"."

var at_end := false
var moving_to_end := false
var is_moving := false
var restarted := false
var continuous := false
var origin : Vector3
var dest := Vector3.ZERO
var move_time := 1.0
var wait_time := 0.0
var audio_source : AudioStreamPlayer3D

func _ready() -> void:
	origin = body.global_position
	dest = origin + func_godot_properties.get("move_offset", Vector3.ZERO);
	move_time = func_godot_properties.get("move_rate", 0.0);
	continuous = func_godot_properties.get("continuous", false)
	
	is_moving = continuous
	moving_to_end = continuous
	
	signal_ID = func_godot_properties.get("signal_ID", "0")
	
	audio_source = AudioStreamPlayer3D.new()
	add_child(audio_source)
	
	var sound_path : String = func_godot_properties.get("sound_path", "0")
	if !sound_path.contains("res://"): # missing sound path
		sound_path = "res://audio/sfx/elevator.wav"
	
	audio_source.stream = load(sound_path)
	
	audio_source.max_distance = 10.0
	audio_source.unit_size = 4.0
	audio_source.pitch_scale = move_time / 2
	audio_source.volume_db = func_godot_properties.get("volume_db", 0.0);
	
	connect_senders(signal_ID, signal_recieved)
	
func _physics_process(delta: float) -> void:
	if(!is_moving): 
		return
	
	if wait_time > 0.0:
		wait_time -= delta
		return
	elif !restarted:
		audio_source.play()
		restarted = true
		
	var cur_dest := origin
	if moving_to_end:
		cur_dest = dest
	
	body.global_position = body.global_position.move_toward(cur_dest, move_time * delta)
	
	if body.global_position == cur_dest:
		audio_source.stop()

		if continuous:
			at_end = moving_to_end
			moving_to_end = !moving_to_end
			wait_time = 1.0
		else:
			is_moving = false
			
		restarted = false

func signal_recieved(parameters: String) -> void:
	var param_list : PackedStringArray = parameters.split(', ', false)
	for parameter in param_list:
		match parameter:
			"move_switch":
				_set_move(!moving_to_end)
			"move_end":
				_set_move(true)
			"move_start":
				_set_move(false)
			"move_stop":
				is_moving = false
				audio_source.stop()
				restarted = false
			"move_speed_up":
				move_time *= 1.2
			"move_speed_down":
				move_time /= 1.2
				if move_time < 0.1:
					move_time = 0.1

func _set_move(to_end: bool) -> void:
	if is_moving:
		return
	
	moving_to_end = to_end
	is_moving = true
	wait_time = 0.0

func _toggle_move() -> void:
	if is_moving:
		return
	_set_move(!moving_to_end)
