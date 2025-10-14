extends Control
class_name Terminal

const interactable: bool = true

var initialised: bool = false

@onready var output_label: RichTextLabel = $%OutputTextLabel
@onready var input: LineEdit = %InputLineEdit

func error(msg: String) -> String:
	return "[b]Error:[/b] %s" % msg

func help(_params: Array[String]) -> String:
	return '''Commands:
	scan - list scannable objects in range
	scan [name] - scan an in-range scannable
	connect [host] - connect to in-range host
	read - displays raw disk data
	decode [start address] [end address] - decode drive data
	output - outputs decoded disk drive data to the monitor
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
	var disk = _check_disk()
	if disk:
		var data: SignalData = disk.data
		return data.encoded_content
	return "No disk drive found."

func output_disk_data(params: Array[String]) -> String:
	var disk = _check_disk()
	if disk:
		var data: SignalData = disk.data
		if data.decoded:
			Signals.display_data(data)
			return "Displaying decoded data."
		else:
			return "Data not decoded, use the 'decode' command."
	return "No disk drive found."

func decode_disk(params: Array[String]) -> String:
	var disk = _check_disk()

	if disk:
		if params.size() < 3:
			return "Enter a start and end address."
		else:
			var data: SignalData = disk.data
			if data.decoded:
				return "Data already decoded, display with the 'output' command."
			if params[1] == data.start_address and params[2] == data.end_address:
				if Signals.current and Signals.current.data == data:
					Signals.set_current_decoded()
				else:
					data.decoded = true
				return "Data decoded, display with the 'output' command."
			else:
				return "Failed to decode any relevant data, try different addresses."
	return "No disk drive found."

func _check_disk() -> Node3D:
	for disk in get_tree().get_nodes_in_group("floppy"):
		if disk.inserted:
			return disk
	return null

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
		"output":
			return output_disk_data(params)
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
	output_label.visible_ratio = 0

func initialise() -> void:
	$MusicPlayer.play()
	var tween := create_tween()
	tween.tween_property(output_label, "visible_ratio", 1.0, 21.818)
	initialised = true
	await tween.finished
	input.grab_focus()
