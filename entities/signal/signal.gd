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
	_randomise_tuning_parameters()

func _randomise_tuning_parameters() -> void:
	if data:
		data.target_coarse_frequency = randi_range(5000, 7000)
		data.target_cycles = randf_range(0.5, 5.0)
		data.target_amplitude = randf_range(0.2, 1.0)
		data.target_phase = randf_range(0.0, 1.99)
