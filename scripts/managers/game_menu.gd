extends Control

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
	SETTINGS,
	LOADING,
}
var menu_state : MenuState

# screens
@onready var main_menu : CanvasLayer = $MainMenu
@onready var singleplayer_menu : CanvasLayer = $SingleplayerMenu
@onready var multiplayer_menu : CanvasLayer = $MultiplayerMenu
@onready var settings_menu : CanvasLayer = $SettingsMenu
@onready var loading_screen : CanvasLayer = $LoadingScreen


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


func _on_singleplayer_menu_return_from_singleplayer() -> void:
	change_screen(singleplayer_menu, main_menu)
	menu_state = MenuState.MAIN_MENU


func _on_singleplayer_menu_load_singleplayer_scene(game_scene: String) -> void:
	change_screen(singleplayer_menu, loading_screen)
	menu_state = MenuState.LOADING
	loading_screen.set_load_scene(game_scene)


func _on_loading_screen_scene_loaded() -> void:
	menu_state = MenuState.SINGLEPLAYER_GAME


func _on_multiplayer_menu_return_from_multiplayer() -> void:
	change_screen(multiplayer_menu, main_menu)
	menu_state = MenuState.MULTIPLAYER_MENU


func _on_settings_menu_return_from_settings() -> void:
	change_screen(settings_menu, main_menu)
	menu_state = MenuState.MULTIPLAYER_MENU
