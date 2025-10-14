extends Control
class_name PadScreen

@onready var output_text_label: RichTextLabel = %OutputTextLabel

func set_text(text: String) -> void:
	output_text_label.text = text
