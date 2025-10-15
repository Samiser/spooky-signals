extends Control

@onready var back_button: Button = $MarginContainer/MarginContainer/VBoxContainer/BackButton

func _ready() -> void:
	back_button.pressed.connect(self.hide)
