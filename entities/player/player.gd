#extends CharacterBody3D
extends Reciever
class_name Player

@onready var character_body: CharacterBody3D = $"."

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var speed: int = 4
var jump_speed: int = 4
var crouch_time : float = 0.1
var crouch_height := 1.1
var default_height : float
var mouse_sensitivity: float = 0.002

var default_fov : float
var zoom_fov := 40.0
var is_zoomed : bool = false
var zoom_tween : Tween

var is_crouched : bool = false
var released_crouch : bool = false
var crouch_tween : Tween

var allow_control : bool = true

var camera_attached : bool = true

var shake_time := 0.0
var shake_magnitude := 128.0

var interact_distance: float = 4.0
var interacting: bool = false
var current_interactable: Node3D 

var next_subtitle_priority := 1
var next_subtitle_time := 1.0

@onready var camera: Camera3D = $Camera3D
@onready var crosshair: ColorRect = $UI/CenterContainer/Crosshair

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	connect_senders("player", signal_recieved)
	default_height = $CollisionShape3D.shape.height
	default_fov = $Camera3D.fov
		
func _physics_process(delta):
	character_body.velocity.y += -gravity * delta
	if !interacting:
		var input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		
		if !allow_control:
			input = Vector2.ZERO
		
		var movement_dir = character_body.transform.basis * Vector3(input.x, 0, input.y)
		
		var current_speed := speed
		if is_crouched && character_body.is_on_floor():
			current_speed = speed / 2.0
		
		character_body.velocity.x = movement_dir.x * current_speed
		character_body.velocity.z = movement_dir.z * current_speed
		
		if character_body.is_on_floor() and Input.is_action_just_pressed("jump"):
			character_body.velocity.y = jump_speed
	else:
		character_body.velocity.x = 0
		character_body.velocity.z = 0
	
	if shake_time > 0.0:
		character_body.velocity += Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0)) * clampf(shake_time, 0.0, 1.0) * shake_magnitude * delta
		shake_time -= delta
	
	character_body.move_and_slide()

func _process(delta: float) -> void:
	_set_crosshair_visibility()

func _set_crosshair_visibility() -> void:
	if interacting || !camera_attached:
		crosshair.hide()
		$UI/interactLabel.text = ""
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
	if zoom_tween != null && zoom_tween.is_running():
		zoom_tween.stop()
	
	var zoom_level : float = default_fov
	is_zoomed = !is_zoomed
	if is_zoomed:
		zoom_level = zoom_fov
		
	zoom_tween = get_tree().create_tween()
	zoom_tween.tween_property($Camera3D, "fov", zoom_level, 0.14)

func _unhandled_input(event: InputEvent) -> void:
	if !allow_control:
		return
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		character_body.rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clampf(camera.rotation.x, -deg_to_rad(80), deg_to_rad(80))
	
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
	
	if event.is_action_pressed("crouch"):
		if not interacting:
			_set_crouch(true)
			released_crouch = false
	if event.is_action_released("crouch"):
		released_crouch = true
	
	if is_crouched && released_crouch:
		if not interacting:
			_set_crouch(false)
	
	if event.is_action_released("click"):
		if interacting and current_interactable.has_method("on_release"):
			current_interactable.on_release()

func stop_interacting() -> void:
	interacting = false
	current_interactable = null

func _looking_at_interactable() -> Node3D:
	var from := camera.global_transform.origin
	var to := from + (-camera.global_transform.basis.z) * interact_distance

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

func _set_crouch(crouch : bool) -> void:
	if !crouch: # standing up
		var checks := -1
		var body_radius : float = $CollisionShape3D.shape.radius

		while(checks < 4): # checks surrounding area of player if there's space to stand up
			var check_point :Vector3= Vector3.FORWARD.rotated(Vector3.UP, checks * (PI / 2))
			check_point = check_point * body_radius
			
			if checks == -1: # check center
				check_point = Vector3.ZERO
				
			check_point.y += crouch_height
			
			$StandRayCheck.position = check_point
			$StandRayCheck.force_raycast_update()
			
			if $StandRayCheck.is_colliding():
				return
			else:
				checks += 1
			
		released_crouch = false

	if crouch_tween != null && crouch_tween.is_running():
		crouch_tween.stop()
	
	is_crouched = crouch
	var body_height := 1.8
	var cam_height := body_height - 0.1
	
	if is_crouched:
		body_height = crouch_height
		cam_height = body_height - 0.1
	
	crouch_tween = get_tree().create_tween()
	crouch_tween.tween_property($CollisionShape3D.shape, "height", body_height, crouch_time)
	crouch_tween.tween_property(camera, "position:y", cam_height, crouch_time)

func signal_recieved(parameters: String) -> void:
	var param_list : PackedStringArray = parameters.split(', ', false)
	for parameter in param_list:
		match parameter:
			"player_gravity_on":
				gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
			"player_gravity_off":
				gravity = 0.0
			"player_control_off":
				allow_control = false
			"player_control_on":
				allow_control = true
			"player_control_toggle":
				allow_control = !allow_control
			"player_fade_in":
				var tween := get_tree().create_tween()
				tween.tween_property($UI/fadePanel, "modulate:a", 0.0, 2.0).from(1.0)
			"player_fade_out":
				var tween := get_tree().create_tween()
				tween.tween_property($UI/fadePanel, "modulate:a", 1.0, 2.0).from(0.0)
			"player_camera_reset":
				camera.top_level = false
				
				var body_height := 1.8
				var cam_height := body_height - 0.1
				if is_crouched:
					cam_height = body_height - 0.1
					
				camera.position = Vector3.ZERO
				camera.position.y = cam_height
				
				camera.fov = default_fov
				
				camera.rotation = Vector3.ZERO
				camera_attached = true
				_set_crosshair_visibility()
			_:
				var param_additional : PackedStringArray = parameter.split(': ', false)

				if parameter.contains("player_update_location_ui"):
					if $UI/locationLabel.text == param_additional[1]:
						return
					
					$UI/locationLabel.text = param_additional[1]
					var tween := get_tree().create_tween()
					tween.tween_property($UI/locationLabel, "visible_ratio", 1, 0.4).from(0.0) 
				
				if parameter.contains("player_gravity_set"):
					gravity = param_additional[1].to_float()
				
				if parameter.contains("player_shake_time"):
					shake_time = param_additional[1].to_float()
				
				if parameter.contains("player_shake_magnitude"):
					shake_magnitude = param_additional[1].to_float()
				
				if parameter.contains("player_teleport"):
					var teleport_string : PackedStringArray = parameter.split(' ', false)
					character_body.global_position.x = teleport_string[1].to_float()
					character_body.global_position.y = teleport_string[2].to_float()
					character_body.global_position.z = teleport_string[3].to_float()
				
				if parameter.contains("player_angle"):
					character_body.global_rotation_degrees.y = param_additional[1].to_float()
				
				if parameter.contains("player_camera_pos"):
					var cam_string : PackedStringArray = parameter.split(' ', false)
					camera.global_position.x = cam_string[1].to_float()
					camera.global_position.y = cam_string[2].to_float()
					camera.global_position.z = cam_string[3].to_float()
					
					camera.top_level = true
					camera_attached = false
					camera.fov = default_fov
					_set_crosshair_visibility()
				
				if parameter.contains("player_camera_rot"):
					var cam_string : PackedStringArray = parameter.split(' ', false)
					camera.global_rotation_degrees.x = cam_string[1].to_float()
					camera.global_rotation_degrees.y = cam_string[2].to_float()
					camera.global_rotation_degrees.z = cam_string[3].to_float()
				
				if parameter.contains("player_set_subtitle"):
					param_additional[1] = param_additional[1].replace('/', ',')
					print(param_additional[1] + " (" + str(next_subtitle_priority) + ", " + str(next_subtitle_time) + "s)")
					
					var subtitle_label :RichTextLabel= $UI/SubtitleContainer/Subtitle.duplicate()
					$UI/SubtitleContainer.add_child(subtitle_label)
					subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
					subtitle_label.text = param_additional[1]
					subtitle_label.visible = true
					
					var delete_timer := get_tree().create_timer(next_subtitle_time)
					await delete_timer.timeout

					var display_tween := get_tree().create_tween()
					display_tween.tween_property(subtitle_label, "modulate:a", 0.0, 3.0)
					await display_tween.finished
					subtitle_label.queue_free()
					
				if parameter.contains("player_subtitle_priority"):
					next_subtitle_priority = param_additional[1].to_int()
				
				if parameter.contains("player_subtitle_time"):
					next_subtitle_time = param_additional[1].to_float()
