extends Node3D
@export var can_interact : bool = true
var is_moving : bool = false
var is_open : bool = false

@onready var open_sound: AudioStreamPlayer3D = $OpenSound
@onready var close_sound: AudioStreamPlayer3D = $CloseSound

func button_trigger(pad: ButtonPad) -> void:
	toggle_open()
	var pad_text := "Open"
	if is_open:
		pad_text = "Lock"
	
	pad.set_display(pad_text, true)

func toggle_open() -> void:
	if !can_interact or is_moving:
		return
	
	if is_open:
		close_sound.play()
	else:
		open_sound.play()
	
	is_moving = true
	is_open = !is_open
		
	var target_door_pos := 0.0
	if is_open:
		target_door_pos = -0.66

	var tween := get_tree().create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property($AnimatableBody3D, "position:x", target_door_pos, 0.5)
	await tween.finished
	
	is_moving = false
	
