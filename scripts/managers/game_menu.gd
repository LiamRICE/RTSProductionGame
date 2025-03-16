class_name GameMenu extends Control

# state machine
enum MenuState{
	MAIN_MENU,
	SINGLEPLAYER_MENU,
	SINGLEPLAYER_GAME,
	SINGLEPLAYER_CAMPAIGN,
	MULTIPLAYER_MENU,
	MULTIPLAYER_HOST,
	MULTIPLAYER_LOBBY_BROWSER,
	MULTIPLAYER_CAMPAIGN,
	SETTINGS
}
var menu_state : MenuState

# screens
@onready var main_menu : CanvasLayer = $MainMenu
@onready var singleplayer_menu : CanvasLayer = $SingleplayerMenu
@onready var multiplayer_menu : CanvasLayer = $MultiplayerMenu
@onready var settings_menu : CanvasLayer = $SettingsMenu


func change_screen(source:CanvasLayer, destination:CanvasLayer) -> bool:
	if source.visible:
		source.hide()
		destination.show()
		return true
	else:
		return false


func _on_main_menu_multiplayer_button_pressed() -> void:
	change_screen(main_menu, multiplayer_menu)
	menu_state = MenuState.MULTIPLAYER_MENU


func _on_main_menu_quit_button_pressed() -> void:
	get_tree().quit()


func _on_main_menu_settings_button_pressed() -> void:
	change_screen(main_menu, settings_menu)
	menu_state = MenuState.SETTINGS


func _on_main_menu_singleplayer_button_pressed() -> void:
	change_screen(main_menu, singleplayer_menu)
	menu_state = MenuState.SINGLEPLAYER_MENU
