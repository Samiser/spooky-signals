@tool
extends StaticBody3D
class_name Screen

@onready var keypress_audio: AudioStreamPlayer3D = $KeypressAudio
@onready var keyrelease_audio: AudioStreamPlayer3D = $KeyreleaseAudio

@export var height: int = 1024:
	set(value):
		height = value
		if _viewport:
			_viewport.size.y = value
@export var width: int = 1024:
	set(value):
		width = value
		if _viewport:
			_viewport.size.x = value

@export var current_screen_scene: PackedScene:
	set(value):
		current_screen_scene = value
		if Engine.is_editor_hint():
			_replace_screen()

@export var viewport_override: SubViewport:
	set(value):
		viewport_override = value
		call_deferred("_replace_screen")

@onready var _viewport: SubViewport = $SubViewport
@onready var _filter: ColorRect = $SubViewport/ColorRect

var current_screen: Control
var _active: bool = false
var _player: Player

func _ready() -> void:
	$StaticAudio.pitch_scale += randf_range(-0.2, 0.2)
	_replace_screen()
	if _viewport:
		_viewport.size = Vector2(width, height)

func _replace_screen() -> void:	
	if !_viewport:
		return
	
	if !viewport_override and !current_screen_scene:
		return
	
	for c in _viewport.get_children():
		if c == _filter:
			continue
		else:
			c.queue_free()

	if viewport_override:
		var screen := TextureRect.new()
		screen.set_anchors_preset(Control.PRESET_FULL_RECT)
		screen.texture = viewport_override.get_texture()
		_viewport.add_child(screen)
	elif current_screen_scene:
		var screen := current_screen_scene.instantiate()
		current_screen = screen
		_viewport.add_child(screen)

func interact(player: Player) -> void:
	if current_screen is Terminal:
		_active = true
		_player = player
		if not player.is_zoomed:
			player.toggle_zoom()
		player.interacting = true

func stop_interact() -> void:
	_active = false
	_player.interacting = false
	if _player.is_zoomed:
		_player.toggle_zoom()
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
		if event.is_pressed() and not event.is_echo():
			keypress_audio.play()
		elif event.is_released():
			keyrelease_audio.play()
		_viewport.push_input(event)
		get_viewport().set_input_as_handled()
		return
