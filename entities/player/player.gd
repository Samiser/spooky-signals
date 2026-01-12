#extends CharacterBody3D
extends Reciever
class_name Player

@onready var character_body: CharacterBody3D = $"."

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var speed: int = 4
var jump_speed: int = 4
var mouse_sensitivity: float = 0.002
var is_zoomed : bool = false
var shake_time := 0.0
var shake_magnitude := 128.0

var interact_distance: float = 4.0

var interacting: bool = false
var current_interactable: Node3D 

@onready var camera: Camera3D = $Camera3D
@onready var crosshair: ColorRect = $UI/CenterContainer/Crosshair

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	connect_senders("player", signal_recieved)

func _physics_process(delta):
	character_body.velocity.y += -gravity * delta
	if !interacting:
		var input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		var movement_dir = character_body.transform.basis * Vector3(input.x, 0, input.y)
		character_body.velocity.x = movement_dir.x * speed
		character_body.velocity.z = movement_dir.z * speed
		
		if character_body.is_on_floor() and Input.is_action_just_pressed("jump"):
			character_body.velocity.y = jump_speed
	else:
		character_body.velocity.x = 0
		character_body.velocity.z = 0
	
	if shake_time > 0.0:
		character_body.velocity += Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0)) * shake_time * shake_magnitude * delta
		shake_time -= delta
	
	character_body.move_and_slide()

func _process(delta: float) -> void:
	_set_crosshair_visibility()

func _set_crosshair_visibility() -> void:
	if interacting:
		crosshair.hide()
		return
	
	crosshair.show()
	if _looking_at_interactable():
		crosshair.modulate.a = 1.0
		crosshair.custom_minimum_size = Vector2(10, 10)
		if !is_zoomed:
			$UI/interactLabel.text = _looking_at_interactable().name
	else:
		crosshair.modulate.a = 0.4
		crosshair.custom_minimum_size = Vector2(7, 7)
		$UI/interactLabel.text = ""

func toggle_zoom() -> void:
	is_zoomed = !is_zoomed
	if is_zoomed:
		camera.fov /= 2.4
		$UI/interactLabel.text = ""
	else:
		camera.fov *= 2.4

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		character_body.rotate_y(-event.relative.x * mouse_sensitivity)
		$Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)
		$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -deg_to_rad(80), deg_to_rad(80))
	
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event.is_action_pressed("click"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			_try_interact()
	
	if event.is_action_pressed("zoom"):
		if not interacting:
			toggle_zoom()
	
	if event.is_action_released("click"):
		if interacting and current_interactable.has_method("on_release"):
			current_interactable.on_release()

func stop_interacting() -> void:
	interacting = false
	current_interactable = null

func _looking_at_interactable() -> Node3D:
	var cam: Camera3D = $Camera3D
	var from := cam.global_transform.origin
	var to := from + (-cam.global_transform.basis.z) * interact_distance

	var space_state := character_body.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]

	var hit := space_state.intersect_ray(query)
	if hit.is_empty():
		return null

	var collider: Node3D = hit.collider

	if collider and collider.has_method("interact") and not (collider is Screen and not collider.current_screen is Terminal):
		return collider
	else:
		return null

func _try_interact():
	var interactable: Node3D = _looking_at_interactable()
	
	if interactable:
		interactable.interact(self)
		current_interactable = interactable

func signal_recieved(parameters: String) -> void:
	var param_list : PackedStringArray = parameters.split(', ', false)
	for parameter in param_list:
		match parameter:
			"player_gravity_on":
				gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
			"player_gravity_off":
				gravity = 0.0
			"player_gravity_half":
				gravity = ProjectSettings.get_setting("physics/3d/default_gravity") / 2.0
			"player_shake_mini":
				shake_time = 1.0
				shake_magnitude = 86
			"player_shake_mid":
				shake_time = 2.0
				shake_magnitude = 132
			"player_shake_big":
				shake_time = 2.2
				shake_magnitude = 256
