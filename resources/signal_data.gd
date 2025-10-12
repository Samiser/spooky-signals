extends Resource
class_name SignalData

@export var id: StringName = &"sig_001"
@export var title: String = "Unknown Transmission"

@export var decode_seconds: float = 10.0

@export_multiline var content_text: String

@export_multiline var encoded_content: String
@export var start_address: String
@export var end_address: String

@export var content_image: Texture2D

@export var target_coarse_frequency := 5678
@export var target_cycles := 2.25
var target_amplitude := 0.7
var target_phase := 0.35

var downloaded: bool = false
var decoded: bool = false
