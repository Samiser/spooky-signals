extends StaticBody3D
signal send_signal

@export var func_godot_properties : Dictionary
@onready var sound: AudioStreamPlayer3D = $Sound
var signal_ID : String
var signal_parameter : String

func _ready() -> void:
	signal_ID = func_godot_properties.get("signal_ID", "0")
	signal_parameter = func_godot_properties.get("signal_parameter", "0")
	$Screen.current_screen.set_text(signal_ID)

func interact(player: Player) -> void:
	print(name + " sending signal: " + signal_ID)
	sound.play()
	send_signal.emit(signal_parameter)
