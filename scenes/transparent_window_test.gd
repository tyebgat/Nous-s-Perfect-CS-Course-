extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup_window()
	#wait a frame for dialogic ui building then calculate mouse regions
	await get_tree().process_frame
	await get_tree().process_frame
	_update_passthrough()
	
	#Dialogic Signals
	Dialogic.timeline_started.connect(refresh_passthrough)
	Dialogic.timeline_ended.connect(refresh_passthrough)


#=================================
# WINDOW SETTINGS
#==================================
func _setup_window() -> void:
	var win := get_window()
	win.borderless = true
	win.transparent = true
	win.always_on_top = true
	win.size = DisplayServer.screen_get_size()
	win.position = Vector2i.ZERO


func _update_passthrough() -> void:
	var rects: Array[Rect2] = []
	
	# Collect all Control nodes that are visible and should be interactive
	_collect_interactive_controls(get_tree().root, rects)
	
	# Convert rects to polygon array for passthrough
	# Polygons INSIDE this array are clickable — everything else passes through
	var polygons: Array[PackedVector2Array] = []
	for rect in rects:
		if rect.size.x > 0 and rect.size.y > 0:
			polygons.append(PackedVector2Array([
				rect.position,
				Vector2(rect.position.x + rect.size.x, rect.position.y),
				rect.position + rect.size,
				Vector2(rect.position.x, rect.position.y + rect.size.y)
			]))
	
	DisplayServer.window_set_mouse_passthrough(polygons)

func _collect_interactive_controls(node: Node, rects: Array[Rect2]) -> void:
	if node is Control:
		var control := node as Control
		# Only include visible controls that can receive input
		if control.visible and control.mouse_filter != Control.MOUSE_FILTER_IGNORE:
			var global_rect := control.get_global_rect()
			if global_rect.size.x > 0 and global_rect.size.y > 0:
				rects.append(global_rect)
	
	for child in node.get_children():
		_collect_interactive_controls(child, rects)

# Call this whenever your UI changes (new dialogue line, choices appear, etc.)
func refresh_passthrough() -> void:
	await get_tree().process_frame
	_update_passthrough()
