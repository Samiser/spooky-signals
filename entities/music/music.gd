extends Reciever
@onready var music: AudioStreamPlayer = $"."
@export var func_godot_properties : Dictionary
var fade_time := 1.0
var fade_tween : Tween

func _ready() -> void:
	music.stream = load(func_godot_properties.get("music_file_path", "res://audio/music/intro_music.ogg"))
	music.volume_db = func_godot_properties.get("volume_db", 0.0)
	music.playing = func_godot_properties.get("autoplay", false)
	
	connect_senders("music", signal_recieved)

func signal_recieved(parameters: String) -> void:
	var param_list : PackedStringArray = parameters.split(', ', false)
	for parameter in param_list:
		match parameter:
			"music_play":
				music.play()
			"music_stop":
				music.stop()
			"music_fade_out":
				if music.playing:
					var fade_tween := get_tree().create_tween()
					fade_tween.tween_property(music, "volume_linear", 0.0, fade_time)
			_:
				var param_additional : PackedStringArray = parameter.split(': ', false)

				if parameter.contains("music_set"):
					print("playing music: " + param_additional[1])
					
					if fade_tween != null && fade_tween.is_running():
						fade_tween.stop()
					
					if music.playing: # fade current music out
						fade_tween = get_tree().create_tween()
						fade_tween.tween_property(music, "volume_linear", 0.0, fade_time)
						await fade_tween.finished
					music.stream = load(param_additional[1])

					music.playing = true
					
					fade_tween = get_tree().create_tween()
					fade_tween.tween_property(music, "volume_linear", 1.0, fade_time)
					await fade_tween.finished
				
				if parameter.contains("music_fade_time"):
					fade_time = param_additional[1].to_float()
