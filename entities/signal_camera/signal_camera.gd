extends Node3D
class_name SignalCamera

@onready var camera: Camera3D = $Camera3D
@onready var arrow: TextureRect = $TextureRect

@export var max_yaw_deg := 40.0
@export var max_pitch_deg := 40.0

@export var max_speed_deg_per_sec := 30.0
@export var accel_deg_per_sec2 := 200.0
@export var damping := 6.0
@export var deadzone := 0.05
@export var response_gamma := 0.8
@export var invert_x := true
@export var invert_y := true

@export var brake_deg_per_sec2 := 500.0
@export var input_timeout := 0.08

@export var select_angle_on_deg := 3.0
@export var select_angle_off_deg := 5.0
@export var max_select_range := INF
@export var los_mask := 0

@export var signal_parents: Array[Node]

var _base_basis: Basis
var _base_origin := Vector3.ZERO
var _yaw := 0.0
var _pitch := 0.0
var _vel := Vector2.ZERO
var _input := Vector2.ZERO
var _last_input_time := 0.0
var _current: SignalSource = null

func _ready() -> void:
	_on_act_changed(-1)
	Signals.act_changed.connect(_on_act_changed)
	_base_basis = transform.basis.orthonormalized()
	_base_origin = transform.origin
	arrow.visible = false
	arrow.pivot_offset = arrow.size * 0.5

func _on_act_changed(new_act: int):
	for parent in signal_parents:
		for source in parent.get_children():
			source.active = false
	
	if new_act >= 0 and new_act <= 2:
		for source in signal_parents[new_act].get_children():
			source.active = true

func control(stick: Vector2) -> void:
	_last_input_time = Time.get_ticks_usec() * 1e-6
	var ix := (-stick.x) if invert_x else stick.x
	var iy := (-stick.y) if invert_y else stick.y
	var v := _soft_deadzone(Vector2(ix, iy), deadzone)
	if response_gamma != 1.0:
		v = Vector2(sign(v.x) * pow(absf(v.x), response_gamma), sign(v.y) * pow(absf(v.y), response_gamma))
	_input = v.clamp(Vector2(-1, -1), Vector2(1, 1))

func _process(delta: float) -> void:
	_update_motion(delta)
	_update_selection()
	_update_bearings_and_arrow()

func _update_motion(delta: float) -> void:
	var target := _input * max_speed_deg_per_sec
	if (Time.get_ticks_usec() * 1e-6 - _last_input_time) > input_timeout:
		_input = Vector2.ZERO
		target = Vector2.ZERO

	if accel_deg_per_sec2 > 0.0:
		var a := accel_deg_per_sec2 * delta
		_vel.x = move_toward(_vel.x, target.x, a)
		_vel.y = move_toward(_vel.y, target.y, a)
	else:
		_vel = target

	if _input == Vector2.ZERO and brake_deg_per_sec2 > 0.0:
		var b := brake_deg_per_sec2 * delta
		_vel.x = move_toward(_vel.x, 0.0, b)
		_vel.y = move_toward(_vel.y, 0.0, b)

	if _input.length_squared() < 1e-5 and damping > 0.0:
		_vel *= pow(0.5, damping * delta)

	_yaw = clampf(_yaw + _vel.x * delta, -max_yaw_deg, max_yaw_deg)
	_pitch = clampf(_pitch + _vel.y * delta, -max_pitch_deg, max_pitch_deg)
	if (_yaw <= -max_yaw_deg and _vel.x < 0.0) or (_yaw >= max_yaw_deg and _vel.x > 0.0): _vel.x = 0.0
	if (_pitch <= -max_pitch_deg and _vel.y < 0.0) or (_pitch >= max_pitch_deg and _vel.y > 0.0): _vel.y = 0.0

	var rot := Basis(Vector3.UP, deg_to_rad(_yaw)) * Basis(Vector3.RIGHT, deg_to_rad(_pitch))
	transform = Transform3D(_base_basis * rot, _base_origin)

func _update_selection() -> void:
	if Signals.current_act == -1:
		_current = null
		Signals.clear_current()
	
	var pos := camera.global_transform.origin
	var fwd := (-camera.global_transform.basis.z).normalized()

	if _current and is_instance_valid(_current) and _within_selection(_current, pos, fwd, select_angle_off_deg):
		return

	_current = null
	Signals.clear_current()

	var best: SignalSource = null
	var best_score := -INF
	for s: SignalSource in signal_parents[Signals.current_act].get_children():
		var to := s.global_transform.origin - pos
		var d := to.length()
		if d > max_select_range: continue
		var ang := _angle_between_deg(fwd, to / d)
		if ang > select_angle_on_deg: continue
		if los_mask != 0 and !_has_line_of_sight(pos, s.global_transform.origin): continue
		var score := -ang - d * 0.001
		if score > best_score:
			best_score = score
			best = s

	Signals.set_current(best)

func _update_bearings_and_arrow() -> void:
	if Signals.current_act == -1:
		arrow.visible = false
		return
	
	var pos := camera.global_transform.origin
	var basis := camera.global_transform.basis
	var out := []
	for s: SignalSource in signal_parents[Signals.current_act].get_children():
		if s.data and s.data.downloaded: continue
		var to := s.global_transform.origin - pos
		var d := to.length()
		var dir = to / max(d, 1e-6)
		var local = basis.inverse() * dir
		var v2 := Vector2(local.x, local.y)
		var yaw := rad_to_deg(atan2(v2.x, local.z))
		var pitch := rad_to_deg(atan2(v2.y, local.z))
		var ang := sqrt(yaw * yaw + pitch * pitch)
		out.append({"source": s, "yaw_deg": yaw, "pitch_deg": pitch, "angle_deg": ang, "distance": d})

	if out.is_empty():
		arrow.visible = false
		return

	arrow.visible = true
	var first = out[0]
	var sdir = (first.source.global_transform.origin - pos).normalized()
	var local = basis.inverse() * sdir
	var v2 := Vector2(local.x, local.y)
	if v2.length() > 0.0001:
		var angle := atan2(-v2.y, v2.x) + PI * 0.5
		arrow.rotation = angle

func _within_selection(s: SignalSource, pos: Vector3, fwd: Vector3, limit_deg: float) -> bool:
	if !is_instance_valid(s): return false
	if max_select_range < INF and pos.distance_to(s.global_transform.origin) > max_select_range: return false
	if los_mask != 0 and !_has_line_of_sight(pos, s.global_transform.origin): return false
	var to := (s.global_transform.origin - pos).normalized()
	return _angle_between_deg(fwd, to) <= limit_deg

func _soft_deadzone(v: Vector2, dz: float) -> Vector2:
	var m := v.length()
	if m <= dz: return Vector2.ZERO
	return v * ((m - dz) / (1.0 - dz) / max(m, 1e-6))

func _angle_between_deg(a: Vector3, b: Vector3) -> float:
	return rad_to_deg(acos(clampf(a.dot(b), -1.0, 1.0)))

func _has_line_of_sight(from: Vector3, to: Vector3) -> bool:
	var space := get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(from, to)
	q.collision_mask = los_mask
	return space.intersect_ray(q).is_empty()
