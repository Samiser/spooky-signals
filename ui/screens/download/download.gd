extends Control
class_name DownloadUI

@onready var download_progress_bar: ProgressBar = %DownloadProgressBar
@onready var base_64_label: RichTextLabel = %Base64Label

@onready var download_display: MarginContainer = %DownloadDisplay
@onready var no_signal_display: MarginContainer = %NoSignalDisplay

@onready var disk_indicator: TextureRect = %DiskIndicator

var disk_in_drive: bool = false

var is_downloading: bool = false
signal downloading(status: bool)

func _ready() -> void:
	Signals.current_changed.connect(_on_current_signal_changed)
	Signals.current_downloaded.connect(_on_current_signal_downloaded)
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
	if Signals.has_current() and not Signals.current.data.downloaded and not disk_in_drive:
		var data: SignalData = Signals.current.data
		data.download_progress += 0.1 * data.current_download_speed
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

func _on_current_signal_downloaded(_current: SignalSource) -> void:
	print("here")
	disk_in_drive = true
	disk_indicator.show()

func disk_removed(d: FloppyDisk) -> void:
	# TODO: fix this
	#for disk in get_tree().get_nodes_in_group("floppy"):
		#if disk.inserted and disk != d:
			#return
	disk_in_drive = false
	disk_indicator.hide()
