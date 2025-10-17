extends Node3D

@onready var end_transition: ColorRect = $EndTransition
@onready var end_music: AudioStreamPlayer = $EndMusic

func _ready() -> void:
	Signals.game_end.connect(end_game)
	
func end_game():
	await get_tree().create_timer(15).timeout
	var tween := create_tween()
	tween.tween_property(end_transition, "modulate:a", 1.0, end_music.stream.get_length())
	end_music.play()
	await tween.finished
	get_tree().change_scene_to_file("res://ui/game_end/game_end.tscn")
