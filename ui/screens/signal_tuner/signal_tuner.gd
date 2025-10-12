extends Control

@onready var target_line: Line2D = $MarginContainer/VBoxContainer/MarginContainer/CenterContainer/Control/TargetLine
@onready var controlled_line: Line2D = $MarginContainer/VBoxContainer/MarginContainer/CenterContainer/Control/ControlledLine

var cycles: float = 3.0
var amplitude: float = 1.0
var phase: float = 0.0

func control(caller: Node3D, value: float):
	print(caller.name)
	match caller.name:
		"CourseFrequency":
			%CourseFrequencyLabel.text = str(value)
		"FineFrequency":
			if value >= 0.5 and value <= 5.0:
				cycles = value
		"Amplitude":
			if value >= 0.2 and value <= 1.0:
				amplitude = value
		"Phase":
			if value >= 0.0 and value <= 1.99:
				phase = value

func _process(_delta: float) -> void:
	var margin := 11
	
	var w := size.x - margin * 2
	var h := size.y - margin * 2
	var samples := 256

	var scale_y := h * 0.5 * 0.84

	var pts: PackedVector2Array = []
	pts.resize(samples)

	for i in samples:
		var t := float(i) / float(samples - 1)
		var y_norm := amplitude * sin(TAU * (cycles * t) + (PI * phase))
		pts[i] = Vector2(t * w - w/2, y_norm * scale_y)

	target_line.points = pts
	target_line.width = 4.0
