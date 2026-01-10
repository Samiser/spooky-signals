extends AudioStreamPlayer3D

@export var func_godot_properties : Dictionary

func _ready() -> void:
	stream = load(func_godot_properties.get("sfx_file_path", "res://audio/music/intro_music.ogg"))
	volume_db = func_godot_properties.get("volume_db", 0.0)
	pitch_scale = func_godot_properties.get("pitch_level", 1.0)
	playing = func_godot_properties.get("autoplay", false)
	unit_size = func_godot_properties.get("range", 10.0)
	panning_strength = func_godot_properties.get("pan_strength", 1.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
