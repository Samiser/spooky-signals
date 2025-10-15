extends ColorRect

func _ready() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 5)
	await tween.finished
	self.queue_free()
