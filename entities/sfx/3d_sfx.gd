extends Reciever
@onready var sfx: AudioStreamPlayer3D = $"."
@export var func_godot_properties : Dictionary
var signal_ID : String

func _ready() -> void:
	signal_ID = func_godot_properties.get("signal_ID", "0")
	
	sfx.stream = load(func_godot_properties.get("sfx_file_path", "res://audio/music/intro_music.ogg"))
	sfx.volume_db = func_godot_properties.get("volume_db", 0.0)
	sfx.pitch_scale = func_godot_properties.get("pitch_level", 1.0)
	sfx.playing = func_godot_properties.get("autoplay", false)
	sfx.unit_size = func_godot_properties.get("range", 10.0)
	sfx.panning_strength = func_godot_properties.get("pan_strength", 1.0)
	
	connect_senders(signal_ID, signal_recieved)

func signal_recieved(parameters: String) -> void:
	var param_list : PackedStringArray = parameters.split(', ', false)
	for parameter in param_list:
		match parameter:
			"sfx_play":
				sfx.play()
			"sfx_stop":
				sfx.stop()
