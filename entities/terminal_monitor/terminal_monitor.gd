extends Node3D

@onready var correct: AudioStreamPlayer3D = $Correct
@onready var incorrect: AudioStreamPlayer3D = $Incorrect

@onready var screen: Screen = $Screen

func _ready() -> void:
	if screen.current_screen is Terminal:
		screen.current_screen.correct_sound.connect(correct.play)
		screen.current_screen.incorrect_sound.connect(incorrect.play)
