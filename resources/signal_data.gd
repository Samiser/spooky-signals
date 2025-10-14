extends Resource
class_name SignalData

@export var title: String = "Unknown Transmission"

@export var sender: String

@export_multiline var content_text: String

@export_multiline var encoded_content: String

@export var start_address: String
@export var end_address: String

@export var content_image: Texture2D

# ideally randomly generate this but for now its just exported
@export var target_coarse_frequency := 5678
@export var target_cycles := 2.25
@export var target_amplitude := 0.7
@export var target_phase := 0.35

var download_progress: float = 0.0 # / 100.0
var current_download_speed: float = 0.0
var downloaded: bool = false

var decoded: bool = false
