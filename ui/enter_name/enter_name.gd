extends Control

@onready var submit: Button = $UI/MarginContainer/MarginContainer/VBoxContainer/HBoxContainer/Submit
@onready var name_entry: LineEdit = $UI/MarginContainer/MarginContainer/VBoxContainer/HBoxContainer/NameEntry
@onready var name_warning: RichTextLabel = $NameWarning

var main_scene: PackedScene = preload("res://main.tscn")
var name_re := RegEx.new()

func _ready() -> void:
	name_re.compile("^[\\p{L} ]+$")
	submit.pressed.connect(_set_name_and_start)
	name_entry.grab_focus()

func _set_name_and_start() -> void:
	if name_entry.text == "":
		_show_warning("please enter your name")
	elif name_re.search(name_entry.text) == null:
		_show_warning("only letters and spaces allowed")
	else:
		Signals.player_name = name_entry.text
		get_tree().change_scene_to_packed(main_scene)

func _show_warning(text: String) -> void:
	name_warning.text = text
	name_warning.show()
	name_entry.grab_focus()
