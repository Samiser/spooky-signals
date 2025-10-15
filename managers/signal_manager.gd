extends Node
class_name SignalManager

signal current_changed(previous: SignalSource, current: SignalSource)
signal current_downloaded(current: SignalSource)
signal current_decoded(current: SignalSource)

signal act_changed(act: int)

signal display(data: SignalData)

var _current: SignalSource = null

var current_act: int = -1:
	set(value):
		current_act = value
		act_changed.emit(value)

var current: SignalSource:
	get:
		return _current

func has_current() -> bool:
	return _current != null and is_instance_valid(_current)

func set_current(s: SignalSource) -> void:
	var prev := _current
	if prev == s:
		return
	_unbind_current()
	_current = s
	_bind_current()
	emit_signal("current_changed", prev, _current)

func set_current_downloaded() -> void:
	if _current:
		_current.data.downloaded = true
		current_downloaded.emit(_current)
		
func set_current_decoded() -> void:
	if _current:
		_current.decoded = true
		current_decoded.emit(_current)

func display_data(data: SignalData) -> void:
	display.emit(data)

func clear_current() -> void:
	if _current == null:
		return
	var prev := _current
	_unbind_current()
	_current = null
	emit_signal("current_changed", prev, null)

func _bind_current() -> void:
	if _current == null:
		return
	if not _current.tree_exited.is_connected(_on_current_gone):
		_current.tree_exited.connect(_on_current_gone)

func _unbind_current() -> void:
	if _current == null:
		return
	if _current.tree_exited.is_connected(_on_current_gone):
		_current.tree_exited.disconnect(_on_current_gone)

func _on_current_gone() -> void:
	var prev := _current
	_unbind_current()
	_current = null
	emit_signal("current_changed", prev, null)
