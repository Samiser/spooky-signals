extends Node3D

@onready var camera: Camera3D = $Camera3D

@export var max_yaw_deg: float = 35.0
@export var max_pitch_deg: float = 20.0

@export var slew_rate_deg_per_sec: float = 240.0
@export var deadzone: float = 0.05
@export var invert_x: bool = false
@export var invert_y: bool = false

var _base_rot: Vector3
var _target_yaw: float = 0.0
var _target_pitch: float = 0.0
var _yaw: float = 0.0
var _pitch: float = 0.0

func _ready() -> void:
	_base_rot = rotation_degrees

# this just maps the joystick input to camera rotation, but we could make it go towards the input direction instead maybe
func control(input: Vector2) -> void:
	var ix := (-input.x) if invert_x else input.x
	var iy := (-input.y) if invert_y else input.y

	if absf(ix) < deadzone: ix = 0.0
	if absf(iy) < deadzone: iy = 0.0

	_target_yaw   = clampf(ix, -1.0, 1.0) * max_yaw_deg
	_target_pitch = clampf(iy, -1.0, 1.0) * max_pitch_deg

func _process(delta: float) -> void:
	var step := slew_rate_deg_per_sec * delta
	_yaw   = move_toward(_yaw, _target_yaw, step)
	_pitch = move_toward(_pitch, _target_pitch, step)

	rotation_degrees = Vector3(
		_base_rot.x + _pitch,
		_base_rot.y + _yaw,
		_base_rot.z
	)
