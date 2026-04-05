# transparent_window_test.gd
extends Node

func _ready() -> void:
	_setup_window()
	# After _setup_window is called, nuke any default theme background
	get_window().set("theme_override_styles/panel", null)
	#dialogic signals
	Dialogic.timeline_started.connect(_on_timeline_started)
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	#wait frames so dialogic can build the UI
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	_update_passthrough()
	
	_debug_print_controls(get_tree().root)

#Set up window configurations
func _setup_window() -> void:
	var win := get_window()
	win.borderless = true
	win.always_on_top = true
	win.size = DisplayServer.screen_get_size()
	win.position = Vector2i.ZERO

func _on_timeline_started() -> void:
	#wait frames so dialogic can build the UI
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	_update_passthrough()
	
	_debug_print_controls(get_tree().root)
	
func _debug_print_controls(node: Node) -> void:
	if node is Control:
		var c := node as Control
		print(c.name, " | visible: ", c.visible, " | rect: ", c.get_global_rect(), " | modulate: ", c.modulate)
	for child in node.get_children():
		_debug_print_controls(child)

func _on_timeline_ended() -> void:
	# Clear all interactive regions when dialogue closes
	DisplayServer.window_set_mouse_passthrough([])

func _update_passthrough() -> void:
	# First, find and disable the full-screen input catcher
	_disable_fullscreen_input_catcher(get_tree().root)
	
	var rects: Array[Rect2] = []
	_collect_real_ui_controls(get_tree().root, rects)
	
	var polygons: Array[PackedVector2Array] = []
	for rect in rects:
		if rect.size.x > 0 and rect.size.y > 0:
			polygons.append(PackedVector2Array([
				rect.position,
				Vector2(rect.position.x + rect.size.x, rect.position.y),
				rect.position + rect.size,
				Vector2(rect.position.x, rect.position.y + rect.size.y)
			]))
	
	print("Passthrough regions found: ", polygons.size())
	DisplayServer.window_set_mouse_passthrough(polygons)

const FULLSCREEN_SWALLOWERS = ["DialogicNode_Input", "FullAdvanceInputLayer"]

func _disable_fullscreen_input_catcher(node: Node) -> void:
	if node is Control:
		if node.name in FULLSCREEN_SWALLOWERS:
			(node as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
			print("Disabled mouse on: ", node.name)
	for child in node.get_children():
		_disable_fullscreen_input_catcher(child)

# Nodes that should always be interactive when visible
const INTERACTIVE_NODES = [
	"DialogTextPanel",
	"DialogicNode_DialogText",
	"NameLabelPanel",
	"DialogicNode_NameLabel",
	"Texture",	# NextIndicator arrow
	"Choices",
	# Choice buttons use @Button@ prefix, handled separately
]

func _collect_real_ui_controls(node: Node, rects: Array[Rect2]) -> void:
	if node is Control:
		var control := node as Control
		var is_button := node is Button
		var name_str := control.name as String
		
		var is_allowed := name_str in INTERACTIVE_NODES or is_button
		
		if is_allowed and control.visible and _is_visible_in_tree(control):
			var rect := control.get_global_rect()
			if rect.size.x > 0 and rect.size.y > 0:
				# Skip off-screen nodes (like the glossary tooltip)
				if rect.position.x > -50 and rect.position.y > -50:
					print("COLLECTING: ", control.name, " size: ", rect.size)
					rects.append(rect)
	
	for child in node.get_children():
		_collect_real_ui_controls(child, rects)

func _is_visible_in_tree(control: Control) -> bool:
	var node: Node = control
	while node != null:
		if node is Control and not (node as Control).visible:
			return false
		if node == get_tree().root:
			break
		node = node.get_parent()
	return true

#func _collect_interactive_controls(node: Node, rects: Array[Rect2]) -> void:
	#if node is Control:
		#var control := node as Control
		#if control.visible and control.mouse_filter != Control.MOUSE_FILTER_IGNORE:
			#var global_rect := control.get_global_rect()
			#if global_rect.size.x > 0 and global_rect.size.y > 0:
				#rects.append(global_rect)
	#for child in node.get_children():
		#_collect_interactive_controls(child, rects)

func refresh_passthrough() -> void:
	await get_tree().process_frame
	_update_passthrough()
