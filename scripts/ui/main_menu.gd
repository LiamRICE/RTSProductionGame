class_name MainMenu extends CanvasLayer

# signals
signal singleplayer_button_pressed
signal multiplayer_button_pressed
signal settings_button_pressed
signal quit_button_pressed

# buttons
@onready var singleplayer_button = $VBoxContainer/SingleplayerButton
@onready var multiplayer_button = $VBoxContainer/MultiplayerButton
@onready var settings_button = $VBoxContainer/SettingsButton
@onready var quit_button = $VBoxContainer/QuitButton

# parent
@onready var game_menu = $".".get_parent()


func _on_singleplayer_button_pressed() -> void:
	singleplayer_button_pressed.emit()


func _on_multiplayer_button_pressed() -> void:
	multiplayer_button_pressed.emit()


func _on_settings_button_pressed() -> void:
	settings_button_pressed.emit()


func _on_quit_button_pressed() -> void:
	quit_button_pressed.emit()
