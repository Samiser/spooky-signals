extends CharacterBody3D
class_name Player

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var speed: int = 5
var jump_speed: int = 5
var mouse_sensitivity: float = 0.002
var is_zoomed : bool = false

var interact_distance: float = 4.0

var interacting: bool = false
var current_interactable: Node3D 

@onready var camera: Camera3D = $Camera3D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	velocity.y += -gravity * delta
	if !interacting:
		var input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		var movement_dir = transform.basis * Vector3(input.x, 0, input.y)
		velocity.x = movement_dir.x * speed
		velocity.z = movement_dir.z * speed
		
		if is_on_floor() and Input.is_action_just_pressed("jump"):
			velocity.y = jump_speed
	else:
		velocity.x = 0
		velocity.z = 0
		
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)
		$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -deg_to_rad(70), deg_to_rad(70))
	
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event.is_action_pressed("click"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			_try_interact()
	
	if event.is_action_pressed("zoom"):
		is_zoomed = !is_zoomed
		if is_zoomed:
			camera.fov /= 2.4
		else:
			camera.fov *= 2.4
	
	if event.is_action_released("click"):
		if interacting and current_interactable.has_method("on_release"):
			current_interactable.on_release()

func stop_interacting() -> void:
	interacting = false
	current_interactable = null

func _try_interact():
	var cam: Camera3D = $Camera3D
	var from := cam.global_transform.origin
	var to := from + (-cam.global_transform.basis.z) * interact_distance

	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]

	var hit := space_state.intersect_ray(query)
	if hit.is_empty():
		return

	var collider: Node3D = hit.collider

	if collider and collider.has_method("interact"):
		collider.interact(self)
		current_interactable = collider
	else:
		print("not interactable!")
