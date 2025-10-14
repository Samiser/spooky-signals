extends Resource
class_name SignalData

@export var title: String = "Unknown Transmission"

@export_category("Content")
@export var sender: String
@export_multiline var content_text: String
@export var content_image: Texture2D

@export_category("Decoding Fields")
# ideally generate from content but for now use cyberchef
@export_multiline var encoded_content: String

# again ideally this should be generated but manual for now
@export var start_address: String
@export var end_address: String

# TODO: randomise these values
var target_coarse_frequency := 5678
var target_cycles := 2.25
var target_amplitude := 0.7
var target_phase := 0.35
# ---

var download_progress: float = 0.0 # / 100.0
var current_download_speed: float = 0.0
var downloaded: bool = false

var decoded: bool = false
