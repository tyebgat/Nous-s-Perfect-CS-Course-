extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.start('test')
	#recalculate clickable regions
	await get_tree().process_frame
	await get_tree().process_frame
	var overlay = get_parent()
	if overlay.has_method("refresh_passthrough"):
		overlay.refresh_passthrough()
