extends Node3D

@onready var screen: Screen = $Screen

var download: DownloadUI

func _ready() -> void:
	if screen.current_screen:
		download = screen.current_screen
		download.downloading.connect(_on_downloading_change)

func _on_downloading_change(status: bool):
	print(status)
	$DownloadingSound.playing = status
