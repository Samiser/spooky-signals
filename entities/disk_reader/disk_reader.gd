extends Node3D

func _ready() -> void:
	Signals.current_downloaded.connect(current_downloaded)

func current_downloaded(signal_source: SignalSource) -> void:
	spawn_disk(signal_source.data)

func spawn_disk(data: SignalData) -> void:
	var floppy_scene :PackedScene= load("res://entities/floppy/floppy_disk.tscn")
	var floppy_disk :FloppyDisk= floppy_scene.instantiate()
	get_tree().root.add_child(floppy_disk)
	
	floppy_disk.data = data.duplicate(true)
	floppy_disk.global_position = $disk_pos.global_position
	floppy_disk.global_rotation = $disk_pos.global_rotation
