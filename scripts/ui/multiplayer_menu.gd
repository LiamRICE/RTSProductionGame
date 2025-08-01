extends CanvasLayer

# define signals
signal return_from_multiplayer


func _on_return_button_pressed() -> void:
	return_from_multiplayer.emit()
