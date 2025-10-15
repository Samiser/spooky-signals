extends Node3D
class_name SignalSource

@export var data: SignalData

var active: bool = false: 
	set(value):
		active = value
		$MeshInstance3D.visible = value

func _ready() -> void:
	data.dowload_complete.connect(func() -> void:
		$MeshInstance3D.mesh = $MeshInstance3D.mesh.duplicate()
		$MeshInstance3D.mesh.surface_set_material(0, $MeshInstance3D.mesh.surface_get_material(0).duplicate())
		$MeshInstance3D.mesh.material.emission = Color.GREEN
	)
