extends Control

@onready var submit: Button = $UI/MarginContainer/MarginContainer/VBoxContainer/HBoxContainer/Submit

var main_scene: PackedScene = preload("res://main.tscn")

func _ready() -> void:
	submit.pressed.connect(_set_name_and_start)

func _set_name_and_start() -> void:
	get_tree().change_scene_to_packed(main_scene)
