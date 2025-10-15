extends OmniLight3D
var flicker_timer : SceneTreeTimer
var new_energy := 1.0

func _ready() -> void:
	flicker_timer = get_tree().create_timer(randf_range(0.1, 1.0))
	new_energy = randf_range(0.0, 3.0)
	
func _process(delta: float) -> void:
	light_energy = lerpf(light_energy, new_energy, 8.0 * delta) 

	if flicker_timer == null or flicker_timer.timeout:
		new_energy = randf_range(0, 4)
		flicker_timer = get_tree().create_timer(randf_range(0.2, 1.2))
