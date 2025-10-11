extends Control
class_name Terminal

const interactable: bool = true

@onready var output_label: RichTextLabel = $%OutputTextLabel
@onready var input: LineEdit = %InputLineEdit

func error(msg: String) -> String:
	return "[b]Error:[/b] %s" % msg

func help(_params: Array[String]) -> String:
	return '''Commands:
	scan - list scannable objects in range
	scan [name] - scan an in-range scannable
	connect [host] - connect to in-range host
	clear - clear terminal output'''

func scan(params: Array[String]) -> String:
	pass
	return "boop"

func dna(params: Array[String]) -> String:
	pass
	return "boop"

func host_connect(params: Array[String]) -> String:
	pass
	return "boop"

func host_disconnect() -> String:
	pass
	return "boop"

func clear() -> String:
	output_label.clear()
	return ""

func parse_command(params: Array[String]) -> String:
	match params[0]:
		"help":
			return help(params)
		"scan":
			return scan(params)
		"dna":
			return dna(params)
		"connect":
			return host_connect(params)
		"clear":
			return clear()
		_:
			return error("[b]Unknown Command[/b], type 'help' to see all commands")

func text_submitted(text: String) -> void:
	var params := text.strip_edges().split(" ")
	var output := ""
	output_label.append_text("$ " + text + '\n')
	output = parse_command(params)
	output_label.append_text(output + '\n')
	input.clear()

func set_visibility(visibility: bool) -> void:
	if visibility:
		visible = true
		input.grab_focus()
	else:
		visible = false

func _ready() -> void:
	input.text_submitted.connect(text_submitted)
	input.grab_focus()
