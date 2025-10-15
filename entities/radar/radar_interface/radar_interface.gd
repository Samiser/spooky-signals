@tool
extends Node3D

@onready var sprite: Sprite3D = $Sprite3D
var ping_rate := 3.0
var ping_time := 0.0

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	ping_time += delta
	if ping_time > ping_rate:
		sprite.modulate = Color.WHITE
		ping_time = 0.0
		$AudioStreamPlayer3D.play()
	else:
		sprite.modulate = Color.WHITE * (ping_rate - ping_time)
