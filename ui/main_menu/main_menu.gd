extends Control

@onready var menu_music: AudioStreamPlayer = $MenuMusic
@onready var glitch_music: AudioStreamPlayer = $GlitchMusic
@onready var static_audio: AudioStreamPlayer = $StaticAudio
@onready var start_button: Button = $UI/MarginContainer/MarginContainer/VBoxContainer/Start
@onready var options_button: Button = $UI/MarginContainer/MarginContainer/VBoxContainer/Options
@onready var options_menu: Control = $OptionsMenu
@onready var crt_filter: ColorRect = $ColorRect

@onready var timer: Timer = $Timer

var name_entry_scene: PackedScene = preload("res://ui/enter_name/enter_name.tscn")

var start_pressed: bool = false

func _ready() -> void:
	start_button.pressed.connect(start)
	timer.timeout.connect(func() -> void:
		print("finished!")
		if not start_pressed:
			glitch_music.play(0.0)
	)
	glitch_music.finished.connect(func() -> void: get_tree().change_scene_to_packed(name_entry_scene))
	options_button.pressed.connect(options_menu.show)

func start() -> void:
	if not start_pressed:
		start_pressed = true
		_switch_audio()

func _switch_audio() -> void:
	var tween := create_tween()
	tween.tween_property(menu_music, "volume_linear", 0, 3)
	tween.parallel().tween_property(glitch_music, "volume_linear", 1, 3)
	tween.parallel().tween_method(_set_static_intensity, 0.06, 1, timer.time_left)
	tween.parallel().tween_property(static_audio, "volume_db", -10, timer.time_left)
	await tween.finished

func _set_static_intensity(intensity: float):
	crt_filter.material.set_shader_parameter("static_noise_intensity", intensity)
