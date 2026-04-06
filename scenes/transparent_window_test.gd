extends Node

var _window_manager: Node

func _ready() -> void:
	_setup_window()
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	_window_manager = $ClickThrough
	Dialogic.timeline_started.connect(_on_timeline_started)
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	Dialogic.start('test')

func _setup_window() -> void:
	var win := get_window()
	win.borderless = true
	win.always_on_top = true
	win.transparent = true
	win.size = DisplayServer.screen_get_size()
	win.position = Vector2i.ZERO
	get_viewport().transparent_bg = true
	RenderingServer.set_default_clear_color(Color(0, 0, 0, 0))

func _on_timeline_started() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	_window_manager.call("SetClickThroughByAlpha")

func _on_timeline_ended() -> void:
	pass
