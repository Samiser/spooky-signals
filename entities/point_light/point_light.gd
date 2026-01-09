@tool
extends OmniLight3D
@export var func_godot_properties : Dictionary
var flicker_amount := 0.0
var start_light_energy := 0.0

func _ready() -> void:
	light_color = func_godot_properties.get("colour", Color.WHITE)
	start_light_energy = func_godot_properties.get("energy", 1.0)
	light_energy = start_light_energy
	light_size = func_godot_properties.get("size", 10.0)
	shadow_enabled = func_godot_properties.get("shadows", false)
	shadow_blur = 0.0
	flicker_amount = func_godot_properties.get("flicker_amount", 0.0)
	light_volumetric_fog_energy = func_godot_properties.get("fog_energy", 0.0)
	request_ready()

func _process(delta: float) -> void:
	if(flicker_amount <= 0.0):
		return
	
	light_energy = start_light_energy + sin(Time.get_ticks_usec()) * flicker_amount
