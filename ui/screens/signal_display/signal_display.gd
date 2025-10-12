extends Control

@onready var no_signal_display: MarginContainer = %NoSignalDisplay
@onready var signal_data_display: MarginContainer = %SignalDataDisplay

@onready var title_label: RichTextLabel = %TitleLabel
@onready var text_contents_label: RichTextLabel = %TextContentsLabel
@onready var image_contents_rect: TextureRect = %ImageContentsRect

func _ready() -> void:
	Signals.current_changed.connect(_on_current_signal_changed)

func _on_current_signal_changed(_old: SignalSource, new: SignalSource) -> void:
	if new != null:
		_show_signal_data(new.data)
	else:
		_hide_signal_data()

func _hide_signal_data() -> void:
	no_signal_display.show()
	signal_data_display.hide()

func _show_signal_data(data: SignalData) -> void:
	if data.content_text:
		text_contents_label.text = data.content_text
		text_contents_label.get_parent().get_parent().visible = true
	else:
		text_contents_label.get_parent().get_parent().visible = false
	
	if data.content_image:
		image_contents_rect.texture = data.content_image
		image_contents_rect.get_parent().get_parent().visible = true
	else:
		image_contents_rect.get_parent().get_parent().visible = false
	
	if data.title:
		title_label.text = data.title

	no_signal_display.hide()
	signal_data_display.show()
