extends CanvasLayer

# define signals
signal return_from_singleplayer
signal load_singleplayer_scene(game_scene:String)


func _on_start_game_button_pressed() -> void:
	var game_scene = "uid://dkve5n5x16hga"
	load_singleplayer_scene.emit(game_scene)


func _on_return_button_pressed() -> void:
	return_from_singleplayer.emit()
