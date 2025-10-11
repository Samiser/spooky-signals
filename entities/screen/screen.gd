@tool
extends StaticBody3D

@export var current_screen_scene: PackedScene:
	set(value):
		current_screen_scene = value
		if Engine.is_editor_hint():
			_replace_screen()

@onready var _viewport: SubViewport = $SubViewport
@onready var _filter: ColorRect = $SubViewport/ColorRect

var current_screen: Control
var _active: bool = false
var _player: Player

func _ready() -> void:
	if current_screen_scene:
		_replace_screen()

func _replace_screen() -> void:
	if !current_screen_scene:
		return
	
	if !_viewport:
		return
	
	for c in _viewport.get_children():
		if c == _filter:
			continue
		else:
			c.queue_free()

	var screen := current_screen_scene.instantiate()
	current_screen = screen
	_viewport.add_child(screen)

func interact(player: Player) -> void:
	if current_screen is Terminal:
		_active = true
		_player = player
		player.interacting = true

func stop_interact() -> void:
	_active = false
	_player.interacting = false
	_player = null

func _input(event: InputEvent) -> void:
	if !_active:
		return

	if event.is_action_pressed("ui_cancel"):
		stop_interact()
		get_viewport().set_input_as_handled()
		return
	
	if event is InputEventMouseMotion:
		_viewport.push_input(event)
		get_viewport().set_input_as_handled()
		return
	
	if event is InputEventKey or event is InputEventShortcut:
		_viewport.push_input(event)
		get_viewport().set_input_as_handled()
		return
