extends Node3D
@export var can_interact : bool = true
var is_moving : bool = false
var is_open : bool = false

func button_trigger(pad: ButtonPad) -> void:
	toggle_open()
	var pad_text := "Open"
	if is_open:
		pad_text = "Lock"
	
	pad.set_display(pad_text, true)

func toggle_open() -> void:
	if !can_interact or is_moving:
		return
	
	is_moving = true
	is_open = !is_open
		
	var target_door_pos := 0.0
	if is_open:
		target_door_pos = 0.66

	var tween := get_tree().create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($AnimatableBody3D, "position:x", target_door_pos, 2.0)
	await tween.finished
	
	is_moving = false
	
