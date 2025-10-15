extends Node3D

@onready var signal_audio: AudioStreamPlayer3D = $SignalAudio
@onready var screen: Node = $Screen

var signal_tuner_ui: SignalTunerUI = null

# audio generator config
@export var sample_hz := 44100.0
@export var buffer_length := 0.12

var _pb: AudioStreamGeneratorPlayback
var _phase_acc := 0.0

func _ready() -> void:
	_init_audio()
	_grab_ui()

func _process(_delta: float) -> void:
	if screen is Screen and screen.current_screen != null and screen.current_screen != signal_tuner_ui:
		_grab_ui()
	_fill_buffer()

func _grab_ui() -> void:
	if screen is Screen and screen.current_screen and screen.current_screen is SignalTunerUI:
		signal_tuner_ui = screen.current_screen
	else:
		signal_tuner_ui = null

func _init_audio() -> void:
	var gen := AudioStreamGenerator.new()
	gen.mix_rate = sample_hz
	gen.buffer_length = buffer_length
	signal_audio.stream = gen
	signal_audio.play()
	_pb = signal_audio.get_stream_playback() as AudioStreamGeneratorPlayback

func _fill_buffer() -> void:
	if signal_tuner_ui == null:
		return
	
	if signal_tuner_ui.data == null:
		return
	
	if signal_tuner_ui.data.downloaded:
		return
	
	if _pb == null:
		return

	var frames := _pb.get_frames_available()
	if frames <= 0:
		return

	var freq_hz := 0.0
	var amp := 0.0
	var phase_offset := 0.0

	freq_hz = clampf(signal_tuner_ui.coarse_frequency, 1.0, 20000.0) / 3.0
	amp = clampf(signal_tuner_ui.amplitude, 0.0, 1.0)
	phase_offset = PI * signal_tuner_ui.phase

	var fine_hz: float = signal_tuner_ui.cycles * 100.0
	freq_hz += fine_hz

	var incr := TAU * freq_hz / sample_hz

	for i in frames:
		var s := sin(_phase_acc + phase_offset) * amp
		_pb.push_frame(Vector2(s, s))
		_phase_acc = fposmod(_phase_acc + incr, TAU)
