extends Reciever

@export var func_godot_properties : Dictionary
var signal_ID : String

var is_moving := true
var rotate_dir : Vector3i
var rotate_speed : float

var audio_source : AudioStreamPlayer3D

func _ready() -> void:
	signal_ID = func_godot_properties.get("signal_ID", "0")
	
	rotate_dir = func_godot_properties.get("rotate_dir", Vector3.ZERO)
	rotate_speed = func_godot_properties.get("rotate_speed", 0.0)
	
	audio_source = AudioStreamPlayer3D.new()
	add_child(audio_source)
	
	var sound_path : String = func_godot_properties.get("sound_path", "0")
	if !sound_path.contains("res:"):
		sound_path = "res://audio/sfx/fan.wav"
	audio_source.stream = load(sound_path)
	
	is_moving = func_godot_properties.get("autostart", true)
	
	audio_source.max_distance = 12.0
	audio_source.unit_size = 3.0
	audio_source.pitch_scale = clampf(abs(rotate_speed / 10.0), 0.0, 10.0) 
	audio_source.play()
	
	connect_senders(signal_ID, signal_recieved)
	
func _process(delta: float) -> void:
	if !is_moving:
		return
	
	$".".rotate_object_local(rotate_dir, delta * rotate_speed)

func signal_recieved(parameters: String) -> void:
	var param_list : PackedStringArray = parameters.split(', ', false)
	for parameter in param_list:
		match parameter:
			"rotate_start":
				is_moving = true
				audio_source.play()
			"rotate_stop":
				is_moving = false
				audio_source.stop()
			"rotate_toggle":
				is_moving = !is_moving
				if is_moving:
					audio_source.play()
				else:
					audio_source.stop()
