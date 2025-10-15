extends StaticBody3D
class_name FloppyDisk

@export var data : SignalData

var inserted : bool = false

var start_pos : Vector3
var start_rot : Vector3

@onready var collider: CollisionShape3D = $CollisionShape3D

signal interacted()

func _ready() -> void:
	start_pos = global_position
	start_rot = global_rotation

func interact(player: Player) -> void:
	interacted.emit()
	
	var disk_index := 0
	for disk in get_tree().get_nodes_in_group("floppy"):
		if disk.inserted:
			if disk == self:
				disk.remove_disk(disk.global_position, Vector3(-4.197 + (disk_index * -0.3), 0.474, 0.897))
			return
		disk_index += 1
	
	collider.disabled = true
	inserted = true
	
	var tween := get_tree().create_tween()
	tween.tween_property(self, "global_position", Vector3(-4.0, 0.754, -0.145), 0.6)
	tween.set_parallel().tween_property(self, "global_rotation_degrees", Vector3(12.2, -90.0, 0.0), 0.6)
	await tween.finished
	
	tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", Vector3(-4.359, 0.754, -0.145), 0.3)
	await tween.finished
	
	collider.disabled = false
	
func remove_disk(start_point: Vector3, end_point: Vector3) -> void:
	collider.disabled = true
	inserted = false
	
	var random_placement_offset := randf_range(-40, 40)
	
	var tween := get_tree().create_tween()
	tween.tween_property(self, "global_position", start_point + Vector3(0.4, 0.0, 0.0), 0.6)
	await tween.finished
	
	tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", end_point, 0.6)
	tween.set_parallel().tween_property(self, "global_rotation_degrees", Vector3(0.0, random_placement_offset, 90.0), 0.6)
	await tween.finished
	
	collider.disabled = false
