extends Area3D
signal send_signal
@export var func_godot_properties : Dictionary
var signal_ID : String
var signal_parameter : int

func _ready() -> void:
	signal_ID = func_godot_properties.get("signal_ID", "0");
	signal_parameter = func_godot_properties.get("signal_parameter", 0);
	
	body_entered.connect(_on_area_3d_body_entered)

func _on_area_3d_body_entered(body: Node3D) -> void:
	print(name + " entered, sigID: " + signal_ID + ", param: " + str(signal_parameter))
	send_signal.emit(signal_parameter)
