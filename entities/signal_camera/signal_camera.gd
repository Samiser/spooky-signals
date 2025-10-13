extends Node3D
class_name SignalCamera

@onready var camera: Camera3D = $Camera3D

# --- Aim limits ---
@export var max_yaw_deg: float = 60.0
@export var max_pitch_deg: float = 60.0

@export var slew_rate_deg_per_sec: float = 240.0
@export var deadzone: float = 0.05
@export var invert_x: bool = true
@export var invert_y: bool = true

# --- Selection settings ---
@export var select_angle_on_deg: float = 10.0    # must be inside this to select
@export var select_angle_off_deg: float = 15.0   # can drift out to this before deselect
@export var max_select_range: float = INF        # optional distance limit; INF = no limit
@export var los_mask: int = 0                    # optional occlusion mask; 0 = skip LoS check

var _base_rot: Vector3
var _target_yaw: float = 0.0
var _target_pitch: float = 0.0
var _yaw: float = 0.0
var _pitch: float = 0.0

var _current: SignalSource = null

func _ready() -> void:
	_base_rot = rotation_degrees

func control(input: Vector2) -> void:
	var ix := input.x if invert_x else -input.x
	var iy := -input.y if invert_y else input.y

	if absf(ix) < deadzone: ix = 0.0
	if absf(iy) < deadzone: iy = 0.0

	_target_yaw   = clampf(ix, -1.0, 1.0) * max_yaw_deg
	_target_pitch = clampf(iy, -1.0, 1.0) * max_pitch_deg

func _process(delta: float) -> void:
	var step := slew_rate_deg_per_sec * delta
	_yaw   = move_toward(_yaw, _target_yaw, step)
	_pitch = move_toward(_pitch, _target_pitch, step)
	rotation_degrees = Vector3(_base_rot.x + _pitch, _base_rot.y + _yaw, _base_rot.z)

	_update_selection()

# ---------------- selection helpers ----------------

# TODO: Calculate angle to nearest signal at all times (for beeping)

func _update_selection() -> void:
	var pos := camera.global_transform.origin
	var fwd := (-camera.global_transform.basis.z).normalized()

	# Keep current if still within off-angle and line-of-sight (hysteresis)
	if _current and is_instance_valid(_current):
		if _within_selection(_current, pos, fwd, select_angle_off_deg):
			return
		else:
			_current = null
			Signals.clear_current()

	# Find best candidate within on-angle
	var best: SignalSource = null
	var best_score := -1e9

	for s: SignalSource in get_tree().get_nodes_in_group("signal_source"):
		var to := s.global_transform.origin - pos
		var d := to.length()
		if d > max_select_range:
			continue

		var dir := to / d
		var ang := _angle_between_deg(fwd, dir)
		if ang > select_angle_on_deg:
			continue

		if los_mask != 0 and !_has_line_of_sight(pos, s.global_transform.origin):
			continue

		# Prefer smaller angles, slightly prefer closer
		var score := -ang - d * 0.001
		if score > best_score:
			best_score = score
			best = s

	Signals.set_current(best)
	if best and not $TextureRect.visible:
		$TextureRect.show()
	elif not best and $TextureRect.visible:
		$TextureRect.hide() 

func _within_selection(s: SignalSource, pos: Vector3, fwd: Vector3, limit_deg: float) -> bool:
	if !is_instance_valid(s):
		return false
	if max_select_range < INF and pos.distance_to(s.global_transform.origin) > max_select_range:
		return false
	if los_mask != 0 and !_has_line_of_sight(pos, s.global_transform.origin):
		return false
	var to := (s.global_transform.origin - pos).normalized()
	return _angle_between_deg(fwd, to) <= limit_deg

func _angle_between_deg(a: Vector3, b: Vector3) -> float:
	return rad_to_deg((acos(clampf(a.dot(b), -1.0, 1.0))))

func _has_line_of_sight(from: Vector3, to: Vector3) -> bool:
	var space := get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(from, to)
	q.collision_mask = los_mask
	var hit := space.intersect_ray(q)
	return hit.is_empty()
