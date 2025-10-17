extends Control

@onready var thanks: RichTextLabel = $UI/Thanks

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	await get_tree().create_timer(5).timeout
	thanks.show()
