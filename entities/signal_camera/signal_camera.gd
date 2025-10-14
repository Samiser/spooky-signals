extends Node3D
class_name SignalCamera

@onready var camera: Camera3D = $Camera3D

@export var max_yaw_deg: float = 60.0
@export var max_pitch_deg: float = 60.0

@export var slew_rate_deg_per_sec: float = 240.0
@export var deadzone: float = 0.05
@export var invert_x: bool = true
@export var invert_y: bool = true

@export var select_angle_on_deg: float = 3.0
@export var select_angle_off_deg: float = 5.0
@export var max_select_range: float = INF
@export var los_mask: int = 0

var _base_basis: Basis
var _base_origin: Vector3
var _target_yaw := 0.0
var _target_pitch := 0.0
var _yaw := 0.0
var _pitch := 0.0
var _current: SignalSource = null

func _ready() -> void:
	_base_basis = transform.basis.orthonormalized()
	_base_origin = transform.origin

func control(input: Vector2) -> void:
	var ix := (-input.x) if invert_x else input.x
	var iy := (-input.y) if invert_y else input.y

	var v := _apply_soft_deadzone(Vector2(ix, iy), deadzone)
	_target_yaw   = clampf(v.x, -1.0, 1.0) * max_yaw_deg
	_target_pitch = clampf(v.y, -1.0, 1.0) * max_pitch_deg

func _apply_soft_deadzone(v: Vector2, dz: float) -> Vector2:
	var m := v.length()
	if m <= dz:
		return Vector2.ZERO
	var k := (m - dz) / (1.0 - dz)
	return v * (k / max(m, 1e-6))

func _process(delta: float) -> void:
	var step := slew_rate_deg_per_sec * delta
	_yaw   = move_toward(_yaw, _target_yaw, step)
	_pitch = move_toward(_pitch, _target_pitch, step)

	var yaw_rad := deg_to_rad(_yaw)
	var pitch_rad := deg_to_rad(_pitch)
	var rot := Basis(Vector3.UP, yaw_rad) * Basis(Vector3.RIGHT, pitch_rad)
	var xform := Transform3D(_base_basis * rot, _base_origin)
	transform = xform

	_update_selection()

func _update_selection() -> void:
	var pos := camera.global_transform.origin
	var fwd := (-camera.global_transform.basis.z).normalized()

	if _current and is_instance_valid(_current):
		if _within_selection(_current, pos, fwd, select_angle_off_deg):
			return
		_current = null
		Signals.clear_current()

	var best: SignalSource = null
	var best_score := -1e9
	for s: SignalSource in get_tree().get_nodes_in_group("signal_source"):
		var to := s.global_transform.origin - pos
		var d := to.length()
		if d > max_select_range: continue
		var dir := to / d
		var ang := _angle_between_deg(fwd, dir)
		if ang > select_angle_on_deg: continue
		if los_mask != 0 and !_has_line_of_sight(pos, s.global_transform.origin): continue
		var score := -ang - d * 0.001
		if score > best_score:
			best_score = score
			best = s

	Signals.set_current(best)
	$TextureRect.visible = best != null

func _within_selection(s: SignalSource, pos: Vector3, fwd: Vector3, limit_deg: float) -> bool:
	if !is_instance_valid(s): return false
	if max_select_range < INF and pos.distance_to(s.global_transform.origin) > max_select_range: return false
	if los_mask != 0 and !_has_line_of_sight(pos, s.global_transform.origin): return false
	var to := (s.global_transform.origin - pos).normalized()
	return _angle_between_deg(fwd, to) <= limit_deg

func _angle_between_deg(a: Vector3, b: Vector3) -> float:
	return rad_to_deg(acos(clampf(a.dot(b), -1.0, 1.0)))

func _has_line_of_sight(from: Vector3, to: Vector3) -> bool:
	var space := get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(from, to)
	q.collision_mask = los_mask
	return space.intersect_ray(q).is_empty()
