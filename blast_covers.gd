extends MeshInstance3D
var is_down := false
var is_moving := false

func button_trigger(pad: ButtonPad) -> void:
	toggle_open()
	var pad_text := "Lower"
	if is_down:
		pad_text = "Raise"
	
	pad.set_display(pad_text, true)

func toggle_open() -> void:
	if is_moving:
		return
	
	is_moving = true
	is_down = !is_down
		
	var target_height := 2.858
	if is_down:
		target_height = 0.0

	var tween := get_tree().create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position:y", target_height, 3.4)
	await tween.finished
	
	is_moving = false
	
