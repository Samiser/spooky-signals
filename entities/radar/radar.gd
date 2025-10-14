@tool
extends Node3D

@onready var radar_interface: Node3D = $RadarInterface

@export var radar_viewport: SubViewport:
	set(value):
		radar_viewport = value
		if Engine.is_editor_hint() and value and radar_interface:
			radar_interface.sprite.texture = value.get_texture()

func _ready() -> void:
	if radar_viewport:
		radar_interface.sprite.texture = radar_viewport.get_texture()
