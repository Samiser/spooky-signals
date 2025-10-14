extends Node3D
class_name SignalCamera

@onready var camera: Camera3D = $Camera3D

# Aim bounds
@export var max_yaw_deg: float = 40.0
@export var max_pitch_deg: float = 40.0

# Camera control parameters
@export var max_speed_deg_per_sec: float = 30.0
@export var accel_deg_per_sec2: float = 200.0
@export var damping: float = 6.0
@export var deadzone: float = 0.05
@export var response_gamma: float = 0.8
@export var invert_x: bool = true
@export var invert_y: bool = true

@export var brake_deg_per_sec2: float = 500.0
@export var input_timeout: float = 0.08
var _last_input_time := 0.0


# Selection settings (unchanged)
@export var select_angle_on_deg: float = 3.0
@export var select_angle_off_deg: float = 5.0
@export var max_select_range: float = INF
@export var los_mask: int = 0

var _base_basis: Basis
var _base_origin: Vector3
var _yaw := 0.0              # current yaw offset (deg)
var _pitch := 0.0            # current pitch offset (deg)
var _vel := Vector2.ZERO     # current yaw/pitch speed (deg/s): (x=yaw, y=pitch)
var _input_vec := Vector2.ZERO  # processed stick input in [-1..1]

var _current: SignalSource = null

func _ready() -> void:
	_base_basis = transform.basis.orthonormalized()
	_base_origin = transform.origin

# Joystick -> desired direction (not position)
func control(input: Vector2) -> void:
	_last_input_time = Time.get_ticks_msec() * 0.001
	var ix := (-input.x) if invert_x else input.x
	var iy := (-input.y) if invert_y else input.y
	var v := _apply_soft_deadzone(Vector2(ix, iy), deadzone)
	_input_vec = v.clamp(Vector2(-1,-1), Vector2(1,1))

func _apply_soft_deadzone(v: Vector2, dz: float) -> Vector2:
	var m := v.length()
	if m <= dz: return Vector2.ZERO
	var k := (m - dz) / (1.0 - dz)
	return v * (k / max(m, 1e-6))

func _process(delta: float) -> void:
	var target_speed := _input_vec * max_speed_deg_per_sec

	if (Time.get_ticks_msec() * 0.001 - _last_input_time) > input_timeout:
		_input_vec = Vector2.ZERO
		target_speed = Vector2.ZERO

	if accel_deg_per_sec2 > 0.0:
		var step := accel_deg_per_sec2 * delta
		_vel.x = move_toward(_vel.x, target_speed.x, step)
		_vel.y = move_toward(_vel.y, target_speed.y, step)
	else:
		_vel = target_speed

	if _input_vec == Vector2.ZERO and brake_deg_per_sec2 > 0.0:
		var b := brake_deg_per_sec2 * delta
		_vel.x = move_toward(_vel.x, 0.0, b)
		_vel.y = move_toward(_vel.y, 0.0, b)

	if _input_vec.length_squared() < 1e-5 and damping > 0.0:
		var decay := pow(0.5, damping * delta)
		_vel *= decay

	# Integrate yaw/pitch, clamp to cone
	_yaw   = clampf(_yaw   + _vel.x * delta, -max_yaw_deg,   max_yaw_deg)
	_pitch = clampf(_pitch + _vel.y * delta, -max_pitch_deg, max_pitch_deg)

	# Soft-stop at limits: zero velocity if pushing further into the clamp
	if (_yaw <= -max_yaw_deg and _vel.x < 0.0) or (_yaw >= max_yaw_deg and _vel.x > 0.0):
		_vel.x = 0.0
	if (_pitch <= -max_pitch_deg and _vel.y < 0.0) or (_pitch >= max_pitch_deg and _vel.y > 0.0):
		_vel.y = 0.0

	# Apply rotation via Basis (no Euler wrap)
	var rot := Basis(Vector3.UP, deg_to_rad(_yaw)) * Basis(Vector3.RIGHT, deg_to_rad(_pitch))
	transform = Transform3D(_base_basis * rot, _base_origin)

	_update_selection()

# ---------------- selection helpers (same as before) ----------------
func _update_selection() -> void:
	var pos := camera.global_transform.origin
	var fwd := (-camera.global_transform.basis.z).normalized()

	if _current and is_instance_valid(_current):
		if _within_selection(_current, pos, fwd, select_angle_off_deg): return
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
