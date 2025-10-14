extends Control
class_name SignalTunerUI

@onready var no_signal_display: MarginContainer = %NoSignalDisplay
@onready var signal_tuner_display: MarginContainer = %SignalTunerDisplay

@onready var target_line: Line2D = %TargetLine
@onready var controlled_line: Line2D = %ControlledLine

var coarse_frequency: float = 4531
var cycles: float = 3.0
var amplitude: float = 0.4
var phase: float = 0.0

var data: SignalData

const SAMPLES := 256
const MARGIN  := 11

@export var lock_tolerance := 0.9

@export var anim_hz := 0.6
var _time_phase := 0.0

func _ready() -> void:
	no_signal_display.show()
	signal_tuner_display.hide()
	Signals.current_changed.connect(_on_current_signal_changed)

func _on_current_signal_changed(_old: SignalSource, new: SignalSource) -> void:
	if new == null:
		data = null
		no_signal_display.show()
		signal_tuner_display.hide()
	else:
		data = new.data
		no_signal_display.hide()
		signal_tuner_display.show()

func control(caller: Node3D, value: float):
	match caller.name:
		"CourseFrequency":
			if value >= 4000 and value <= 7000:
				coarse_frequency = value
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

func _process(delta: float) -> void:
	_time_phase = fposmod(_time_phase + TAU * anim_hz * delta, TAU)
	_draw_and_score()

func _draw_and_score() -> void:
	if not data:
		return
	
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

		var y_tgt := data.target_amplitude * sin(TAU * (data.target_cycles * t) + (PI * data.target_phase) + _time_phase)
		var y_ctl := amplitude * sin(TAU * (cycles * t) + (PI * phase) + _time_phase)

		var x := w / 2 - t * w
		pts_tgt[i] = Vector2(x, y_tgt * scale_y)
		pts_ctl[i] = Vector2(x, y_ctl * scale_y)

		err_acc += pow(y_tgt - y_ctl, 2.0)

	target_line.points = pts_tgt
	controlled_line.points = pts_ctl
	target_line.width = 3.0
	controlled_line.width = 3.0
	
	var diff := absf(coarse_frequency - data.target_coarse_frequency)

	var alpha := 1.0 - smoothstep(0.0, 50.0, diff)

	_set_line_alpha(target_line, alpha)
	_set_line_alpha(controlled_line, alpha)
	
	var rms := sqrt(err_acc / float(SAMPLES))
	var score := clampf(1.0 - (rms / lock_tolerance), 0.0, 1.0) * (1.0 - smoothstep(0.0, 50.0, diff))
	Signals.current.data.current_download_speed = score
	%ScoreLabel.text = "%d%%" % [int(round(score * 100.0))]

func _set_line_alpha(line: Line2D, a: float) -> void:
	var c := line.modulate
	c.a = clampf(a, 0.0, 1.0)
	line.modulate = c
