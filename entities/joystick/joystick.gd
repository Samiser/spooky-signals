extends AnimatableBody3D
class_name Joystick

signal value_changed(value: Vector2)

var _active := false
var _player: Player
var _center_tween: Tween

@export var value := Vector2.ZERO:
	set(v):
		value = v.clamp(Vector2(-1, -1), Vector2(1, 1))
		_update_rotation_from_value()
		emit_signal("value_changed", value)

@export var drag_sensitivity := Vector2(0.01, 0.01)
@export var step := 0.0
@export var deadzone := 0.02

@export var max_tilt_x_deg := 25.0
@export var max_tilt_z_deg := 25.0
@export var invert_x := false
@export var invert_y := false

@export var return_duration := 0.35

@export var screen: Screen
@export var control_target: Node

func _ready() -> void:
	_update_rotation_from_value()

func interact(player: Player) -> void:
	_kill_center_tween()
	_player = player
	_player.interacting = true
	if screen:
		_player.camera.rotation.x += deg_to_rad(20)
		pass
	_active = true

func stop_interact() -> void:
	_active = false
	if _player:
		_player.interacting = false
		#_player.camera.rotation.x -= deg_to_rad(20)
		_player = null
	_start_center_tween()

func _input(event: InputEvent) -> void:
	if !_active: return

	if event.is_action_released("click"):
		stop_interact()

	elif event is InputEventMouseMotion:
		_kill_center_tween()
		_handle_motion(event)
		get_viewport().set_input_as_handled()

	elif event is InputEventKey or event is InputEventShortcut:
		get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	if !_active: return
	
	if control_target.has_method("control"):
		control_target.control(value)

func _handle_motion(event: InputEventMouseMotion) -> void:
	var delta_v := Vector2(event.relative.x, -event.relative.y) * drag_sensitivity
	if delta_v.length_squared() == 0.0: return

	var new_val := value + delta_v
	if new_val.length() < deadzone: new_val = Vector2.ZERO
	new_val = new_val.clamp(Vector2(-1, -1), Vector2(1, 1))
	if step > 0.0:
		new_val = Vector2(round(new_val.x / step) * step, round(new_val.y / step) * step)
	value = new_val

func _update_rotation_from_value() -> void:
	var vx := (-value.x) if invert_x else value.x
	var vy := (-value.y) if invert_y else value.y
	var r := rotation_degrees
	r.x = vy * max_tilt_x_deg
	r.z = vx * max_tilt_z_deg
	rotation_degrees = r

# --- tweened spring-back ---
func _start_center_tween() -> void:
	if value == Vector2.ZERO: return
	_kill_center_tween()
	var t := create_tween()
	t.set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_ELASTIC)
	t.tween_property(self, "value", Vector2.ZERO, return_duration)
	_center_tween = t

func _kill_center_tween() -> void:
	if _center_tween:
		_center_tween.kill()
		_center_tween = null
