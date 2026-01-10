extends Reciever

@export var func_godot_properties : Dictionary
var signal_ID : String

var is_moving := true
var rotate_dir : Vector3i
var rotate_speed : float

var power_level := 0.0
var target_power_level := 1.0

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
	
	audio_source.max_distance = func_godot_properties.get("sound_dist", 12.0)
	audio_source.unit_size = audio_source.max_distance / 2.6
	audio_source.play()
	
	connect_senders(signal_ID, signal_recieved)
	
func _physics_process(delta: float) -> void:
	if !is_moving:
		power_level = move_toward(power_level, 0.0, delta)
	else:
		power_level = move_toward(power_level, target_power_level, delta)
	
	$".".rotation += rotate_dir * delta * rotate_speed * power_level
	
	var pitch_level : float = abs(power_level) * rotate_speed
	if pitch_level > 0.0:
		if !audio_source.playing:
			audio_source.play()
		audio_source.pitch_scale = abs(power_level) * rotate_speed
	else:
		audio_source.stop()

func signal_recieved(parameters: String) -> void:
	var param_list : PackedStringArray = parameters.split(', ', false)
	for parameter in param_list:
		match parameter:
			"rotate_start":
				is_moving = true
			"rotate_stop":
				is_moving = false
			"rotate_toggle":
				is_moving = !is_moving
			"rotate_flip":
				target_power_level = target_power_level * -1
