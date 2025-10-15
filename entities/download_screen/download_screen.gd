extends Node3D

@onready var screen: Screen = $Screen
@export var disk_reader: DiskReader

var download: DownloadUI

func _ready() -> void:
	if screen.current_screen:
		download = screen.current_screen
		download.downloading.connect(_on_downloading_change)
	
		if disk_reader:
			disk_reader.disk_removed.connect(download.disk_removed)

func _on_downloading_change(status: bool):
	$DownloadingSound.playing = status
