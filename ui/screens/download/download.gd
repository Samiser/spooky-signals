extends Control
class_name DownloadUI

@onready var download_progress_bar: ProgressBar = %DownloadProgressBar
@onready var base_64_label: RichTextLabel = %Base64Label

@onready var download_display: MarginContainer = %DownloadDisplay
@onready var no_signal_display: MarginContainer = %NoSignalDisplay

var is_downloading: bool = false
signal downloading(status: bool)

func _ready() -> void:
	Signals.current_changed.connect(_on_current_signal_changed)
	no_signal_display.show()
	download_display.hide()

func _on_current_signal_changed(_old: SignalSource, new: SignalSource) -> void:
	if new == null:
		no_signal_display.show()
		download_display.hide()
		if is_downloading:
			is_downloading = false
			downloading.emit(false)
	else:
		no_signal_display.hide()
		download_display.show()

func _process(_delta: float) -> void:
	if Signals.has_current() and not Signals.current.data.downloaded:
		var data: SignalData = Signals.current.data
		data.download_progress += 0.5 * data.current_download_speed
		download_progress_bar.value = data.download_progress
		base_64_label.visible_ratio = data.download_progress / 100
		if data.download_progress >= 100.0:
			Signals.set_current_downloaded()
		if data.current_download_speed > 0 and not is_downloading and not data.downloaded:
			is_downloading = true
			downloading.emit(true)
		elif (data.current_download_speed <= 0 and is_downloading) or data.downloaded:
			is_downloading = false
			downloading.emit(false)
