extends StaticBody3D

@export var func_godot_properties : Dictionary
@onready var sound: AudioStreamPlayer3D = $Sound
var signal_ID : String

func _ready() -> void:
	signal_ID = func_godot_properties.get("signal_ID", "0")
	$Screen.current_screen.set_text(signal_ID)

func interact(player: Player) -> void:
	sound.play()
	print(name + " sending signal: " + signal_ID)
