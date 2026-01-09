extends AnimatableBody3D

@export var func_godot_properties : Dictionary

var signal_ID : String
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
	origin = global_position
	dest = origin + func_godot_properties.get("move_offset", Vector3.ZERO);
	move_time = func_godot_properties.get("move_rate", 0.0);
	continuous = func_godot_properties.get("continuous", false)
	
	is_moving = continuous
	moving_to_end = continuous
	
	signal_ID = func_godot_properties.get("signal_ID", "0")
	
	audio_source = AudioStreamPlayer3D.new()
	add_child(audio_source)
	
	match(func_godot_properties.get("sound_ID", 0)):
		0:
			audio_source.stream = load("res://audio/sfx/elevator.wav")
		1:
			audio_source.stream = load("res://audio/sfx/gears.wav")
		_: # missing sound ID
			audio_source.stream = load("res://audio/music/intro_music.ogg")
	
	audio_source.max_distance = 10.0
	audio_source.unit_size = 4.0
	audio_source.pitch_scale = move_time / 2
	audio_source.volume_db = func_godot_properties.get("volume_db", 0.0);
	
	_connect_senders()

func _connect_senders() -> void:
	var timer := get_tree().create_timer(0.01) # silly fix as not all objects are done spawning once this is called
	await timer.timeout
	
	var sender_objs := get_tree().get_nodes_in_group("sender")
	for sender in sender_objs:
		if sender.signal_ID == signal_ID:
			sender.send_signal.connect(signal_recieved)
	
func _process(delta: float) -> void:
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
	
	global_position = global_position.move_toward(cur_dest, move_time * delta)
	
	if global_position == cur_dest:
		audio_source.stop()

		if continuous:
			at_end = moving_to_end
			moving_to_end = !moving_to_end
			wait_time = 1.0
		else:
			is_moving = false
			
		restarted = false

func signal_recieved(parameter: int) -> void:
	match parameter:
		0:
			_set_move(!moving_to_end)
		1:
			_set_move(false)
		2:
			_set_move(true)

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
