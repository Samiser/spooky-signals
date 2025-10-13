extends Control

@onready var download_progress_bar: ProgressBar = %DownloadProgressBar
@onready var base_64_label: RichTextLabel = %Base64Label

func _process(_delta: float) -> void:
	if Signals.has_current() and not Signals.current.data.downloaded:
		var data: SignalData = Signals.current.data
		data.download_progress += 0.01 * data.current_download_speed
		download_progress_bar.value = data.download_progress
		base_64_label.visible_ratio = data.download_progress / 100
		if data.download_progress >= 100.0:
			data.downloaded = true
