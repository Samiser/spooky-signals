extends Reciever
@onready var music: AudioStreamPlayer = $"."
@export var func_godot_properties : Dictionary
var signal_ID := "music"

func _ready() -> void:
	signal_ID = func_godot_properties.get("signal_ID", "0")
	
	music.stream = load(func_godot_properties.get("music_file_path", "res://audio/music/intro_music.ogg"))
	music.volume_db = func_godot_properties.get("volume_db", 0.0)
	music.playing = func_godot_properties.get("autoplay", false)
	
	connect_senders(signal_ID, signal_recieved)

func signal_recieved(parameters: String) -> void:
	var param_list : PackedStringArray = parameters.split(', ', false)
	for parameter in param_list:
		match parameter:
			"music_play":
				music.play()
			"music_stop":
				music.stop()
			_:
				var param_additional : PackedStringArray = parameter.split(': ', false)

				if parameter.contains("music_set"):
					music.stream = load(param_additional[1])
