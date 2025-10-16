extends Node3D
class_name DiskReader

var current_disk: FloppyDisk

signal disk_removed(disk: FloppyDisk)

func _ready() -> void:
	Signals.current_downloaded.connect(current_downloaded)

func current_downloaded(signal_source: SignalSource) -> void:
	spawn_disk(signal_source.data)

func spawn_disk(data: SignalData) -> void:
	var floppy_scene :PackedScene= load("res://entities/floppy/floppy_disk.tscn")
	var floppy_disk :FloppyDisk= floppy_scene.instantiate()
	current_disk = floppy_disk
	get_tree().root.add_child(floppy_disk)
	
	current_disk.interacted.connect(_remove_disk)
	floppy_disk.data = data.duplicate(true)
	floppy_disk.name = "Raw Signal Data Disk"
	floppy_disk.global_position = $disk_pos.global_position
	floppy_disk.global_rotation = $disk_pos.global_rotation

func _remove_disk() -> void:
	current_disk.interacted.disconnect(_remove_disk)
	disk_removed.emit(current_disk)
	current_disk = null
