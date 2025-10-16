extends Control
class_name Terminal

const interactable: bool = true

var initialised: bool = false

@onready var output_label: RichTextLabel = $%OutputTextLabel
@onready var input: LineEdit = %InputLineEdit

signal correct_sound
signal incorrect_sound

func error(msg: String) -> String:
	return "[b]Error:[/b] %s" % msg

func help(_params: Array[String]) -> String:
	return '''Commands:
	frequency [frequency] - set signal scanning frequency
	read - displays raw disk data
	decode [start address] [end address] - decode drive data
	output - outputs decoded disk drive data to the monitor
	clear - clear terminal output
	
	protocol - show detailed protocol instructions
	decoding - show detailed decoding instructions'''

func read_disk(params: Array[String]) -> String:
	var disk = _check_disk()
	if disk:
		var data: SignalData = disk.data
		correct_sound.emit()
		return data.encoded_content
	incorrect_sound.emit()
	return "No disk drive found."

func output_disk_data(params: Array[String]) -> String:
	var disk = _check_disk()
	if disk:
		var data: SignalData = disk.data
		if data.decoded:
			Signals.display_data(data)
			correct_sound.emit()
			return "Displaying decoded data."
		else:
			incorrect_sound.emit()
			return "Data not decoded, use the 'decode' command."
	incorrect_sound.emit()
	return "No disk drive found."

func frequency(params: Array[String]) -> String:
	if params.size() != 2:
		return "Usage: frequency [frequency value]"
	
	var regex = RegEx.new()
	regex.compile("[^0-9]")
	var result = regex.search(params[1])
	
	if result:
		return "Frequency must be a number"
	
	Signals.current_act = -1

	match params[1]:
		"1":
			Signals.current_act = 0
		"2":
			Signals.current_act = 1
		"3":
			Signals.current_act = 2
	
	correct_sound.emit()
	return("Frequency set to %s" % params[1])

func protocol() -> String:
	return '''

[b]1) Set scanner frequency to emergency comms[/b]
Use the [i]frequency[/i] command to set the frequency of your signal scanner to the emergency comms channel [b](1)[/b]. You may be instructed to change the frequency if the situation changes.

[b]2) Acquire signal lock[/b]
Use the [b]Signal Targeting System[/b] (to the right of this terminal) to find signal beacons. The arrow will guide you to a signal. The radar shows all signals on the current frequency.

[b]3) Download and decode signals[/b]
Use the [b]Signal Tuner[/b] (to the left of this terminal) to tune into the signal's precise frequency. First set the coarse signal, then match the signal's waveform with the three fine-tuning knobs to increase download speed.

Once downloaded, use the [b]Disk Writer[/b] to insert the created disk into this terminal. There must be no disk in the terminal. For instructions on decoding, run the [i]decoding[/i] command.
'''

func decoding() -> String:
	return '''
Raw signal data on a disk will be noisy. You can use the [i]decode[/i] command to extract the data. First, use the [i]read[/i] command to see a hexdump of the raw disk data, it will look like this:

0010  2f 20 5b 5b 4e 6f 76 61 20 53 65 63 74 6f 72 5d
0020  a0 8c e2 a0 80 [color=red]30 30 30[/color] 4f 52 49 47 49 4e 20 2f
0030  5d 20 2f 2f 20 47 52 49 44 20 4d 31 34 2d 31 32
0040  [color=red]30 30 30[/color] 0a e2 a0 95 e2 a0 a5 e2 a0 9e e2 a0 80
0050  54 49 4d 45 43 4f 44 45 20 32 31 35 36 2e 30 33

Signal data starts and ends with the byte sequence [b]30 30 30[/b], which has been highlighted in the above example.

To decode, pass the data start and end addresses to the [i]decode[/i] command, in this case [i]decode 0020 0040[/i]

With the signal decoded, you can display its contents on the [b]Signal Data Display[/b] with the [i]output[/i] command. Now return to step 2 of the protocol.
'''

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
				correct_sound.emit()
				return "Data decoded, display with the 'output' command."
			else:
				incorrect_sound.emit()
				return "Failed to decode any relevant data, try different addresses."
	incorrect_sound.emit()
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
		"clear":
			return clear()
		"read":
			return read_disk(params)
		"frequency":
			return frequency(params)
		"decode":
			return decode_disk(params)
		"output":
			return output_disk_data(params)
		"protocol":
			return protocol()
		"decoding":
			return decoding()
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
	print(Signals.player_name)
	output_label.text = output_label.text.replace("{{PLAYER_NAME}}", Signals.player_name)
	input.text_submitted.connect(text_submitted)
	output_label.visible_ratio = 0

func initialise() -> void:
	$MusicPlayer.play()
	var tween := create_tween()
	tween.tween_property(output_label, "visible_ratio", 1.0, 21.818)
	initialised = true
	await tween.finished
	input.grab_focus()
