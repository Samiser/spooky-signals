@tool
extends Node3D

@onready var screen: Screen = $Screen
@onready var joystick: Joystick = $"Tracking Joystick"

@export var signal_camera_viewport: SubViewport:
	set(value):
		signal_camera_viewport = value
		if Engine.is_editor_hint() and value and screen and joystick:
			screen.viewport_override = value
			joystick.control_target = value.get_child(0)

func _ready() -> void:
	if signal_camera_viewport:
		screen.viewport_override = signal_camera_viewport
		joystick.control_target = signal_camera_viewport.get_child(0)
