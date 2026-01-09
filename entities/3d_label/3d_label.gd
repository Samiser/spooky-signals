@tool
extends Label3D
@export var func_godot_properties : Dictionary

func _ready() -> void:
	text = func_godot_properties.get("text", "n/a")
	modulate = func_godot_properties.get("colour", Color.WHITE)
	request_ready()
