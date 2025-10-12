extends StaticBody3D

@export var data : String
var inserted :bool = false
var start_pos : Vector3
var start_rot : Vector3
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	start_pos = global_position
	start_rot = global_rotation

func interact(player: Player) -> void:
	for disk in get_tree().get_nodes_in_group("floppy"):
		if disk.inserted:
			if disk == self:
				disk._remove_disk()
			return
	
	collision_shape_3d.disabled = true
	inserted = true
	
	var tween := get_tree().create_tween()
	tween.tween_property(self, "global_position", Vector3(-4.0, 0.754, -0.145), 0.6)
	tween.set_parallel().tween_property(self, "global_rotation_degrees", Vector3(12.2, -90.0, 0.0), 0.6)
	await tween.finished
	
	tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", Vector3(-4.359, 0.754, -0.145), 0.3)
	await tween.finished
	
	collision_shape_3d.disabled = false
	
func _remove_disk() -> void:
	collision_shape_3d.disabled = true
	inserted = false

	var tween := get_tree().create_tween()
	tween.tween_property(self, "global_position", Vector3(-4.0, 0.754, -0.145), 0.6)
	await tween.finished
	
	tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", start_pos, 0.6)
	tween.set_parallel().tween_property(self, "global_rotation", start_rot, 0.6)
	await tween.finished
	
	collision_shape_3d.disabled = false
