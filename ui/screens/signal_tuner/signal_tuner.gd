extends Control

@onready var target_line: Line2D = $MarginContainer/VBoxContainer/MarginContainer/CenterContainer/Control/TargetLine
@onready var controlled_line: Line2D = $MarginContainer/VBoxContainer/MarginContainer/CenterContainer/Control/ControlledLine

var cycles: float = 3.0
var amplitude: float = 1.0
var phase: float = 0.0

const TGT_CYCLES := 2.25
const TGT_AMPL   := 0.7
const TGT_PHASE  := 0.35

const SAMPLES := 256
const MARGIN  := 11

@export var lock_tolerance := 0.9

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
	_draw_and_score()

func _draw_and_score() -> void:
	var w := size.x - MARGIN * 2.0
	var h := size.y - MARGIN * 2.0
	if w <= 2.0 or h <= 2.0:
		return

	var scale_y := h * 0.5 * 0.84

	var pts_tgt: PackedVector2Array = []
	var pts_ctl: PackedVector2Array = []
	pts_tgt.resize(SAMPLES)
	pts_ctl.resize(SAMPLES)

	var err_acc := 0.0

	for i in SAMPLES:
		var t := float(i) / float(SAMPLES - 1)

		var y_tgt := TGT_AMPL * sin(TAU * (TGT_CYCLES * t) + (PI * TGT_PHASE))
		var y_ctl := amplitude * sin(TAU * (cycles * t) + (PI * phase))

		var x := w / 2 - t * w
		pts_tgt[i] = Vector2(x, y_tgt * scale_y)
		pts_ctl[i] = Vector2(x, y_ctl * scale_y)

		err_acc += pow(y_tgt - y_ctl, 2.0)

	target_line.points = pts_tgt
	controlled_line.points = pts_ctl
	target_line.width = 3.0
	controlled_line.width = 3.0

	var rms := sqrt(err_acc / float(SAMPLES))
	var score := clampf(1.0 - (rms / lock_tolerance), 0.0, 1.0)
	print("Score: %d%% (rms=%.3f)" % [int(round(score * 100.0)), rms])
