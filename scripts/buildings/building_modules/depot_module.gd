extends Node

const ResourceUtils := preload("res://scripts/utilities/resource_utils.gd")
const PlayerManager := preload("res://player_manager.gd")

var player_manager:PlayerManager


func _ready() -> void:
	# get the global player manager
	_init_player_manager()


# Required for depot functionality
func _init_player_manager():
	self.player_manager = get_tree().get_root().get_node("GameManager/LevelManager/PlayerManager")
	if self.player_manager == null:
		printerr("Warning! No player manager found! Check the SceneTree for 'GameManager/LevelManager/PlayerManager'.")


func drop_off(amount:int, type:ResourceUtils.Res):
	print("Units dropped off ", amount, " of type ", type)
	self.player_manager.add_resource(amount, type)
