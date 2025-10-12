extends Control
class_name Terminal

const interactable: bool = true

@onready var output_label: RichTextLabel = $%OutputTextLabel
@onready var input: LineEdit = %InputLineEdit

var data_string : String = '''
00000000  30 31 32 33 34 35 36 37
00000010  0a 2f 2a 20 2a 2a 2a 2a 
00000020  2a 2a 2a 2a 2a 2a 2a 2a
00000030  2a 2a 2a 2a 2a 2a 2a 2a 
00000040  2a 2a 20 2a 2f 0a 09 54
00000050  68 20 54 41 42 73 20 28
00000060  32 09 09 33 0a 09 33 2e
00000070  39 2e 34 32 0a'''

func error(msg: String) -> String:
	return "[b]Error:[/b] %s" % msg

func help(_params: Array[String]) -> String:
	return '''Commands:
	scan - list scannable objects in range
	scan [name] - scan an in-range scannable
	connect [host] - connect to in-range host
	read - displays disk data
	decode [start address] [end address] - decode a disk drives data
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

func read_disk(params: Array[String]) -> String:
	for disk in get_tree().get_nodes_in_group("floppy"):
		if disk.inserted:
			return disk.jumbled_data
	return "No disk drive found."

func decode_disk(params: Array[String]) -> String:
	for disk in get_tree().get_nodes_in_group("floppy"):
		if disk.inserted:
			if params.size() < 3:
				return "Enter a start and end address."
			else:
				if params[1] == disk.start_address and params[2] == disk.end_address:
					return disk.data
	return "No disk drive found."

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
		"read":
			return read_disk(params)
		"decode":
			return decode_disk(params)
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
	
