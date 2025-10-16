extends Node3D
class_name SignalSource

@export var data: SignalData

@export var movement_positions: Array[Vector2]
var current_movement_position = 0

@onready var move_timer: Timer = $MoveTimer

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
	if movement_positions.size() > 1:
		move_timer.timeout.connect(_move_to_next_position)

func _randomise_tuning_parameters() -> void:
	if data:
		data.target_coarse_frequency = randi_range(5000, 7000)
		data.target_cycles = randf_range(0.5, 5.0)
		data.target_amplitude = randf_range(0.2, 1.0)
		data.target_phase = randf_range(0.0, 1.99)

func _move_to_next_position() -> void:
	current_movement_position = (current_movement_position + 1) % movement_positions.size()
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position:y", movement_positions[current_movement_position].x, 1)
	tween.parallel().tween_property(self, "global_position:z", movement_positions[current_movement_position].y, 1)
