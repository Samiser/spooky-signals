extends StaticBody3D
class_name ButtonPad

@export var targets : Array[Node3D]
@export var default_pad_text : String

func _ready() -> void:
	$Screen.current_screen.set_text(default_pad_text)

func interact(player: Player) -> void:
	for target in targets:
		if target.has_method("button_trigger"):
			target.button_trigger(self)

func set_display(text: String, origin: bool) -> void:
	$Screen.current_screen.set_text(text)
	
	if !origin:
		return
	
	for target in targets:
		if target is ButtonPad:
			target.set_display(text, false)
