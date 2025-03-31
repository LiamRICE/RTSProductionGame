extends ProductionBuilding

# Script loading
const ResourceUtils := preload("res://scripts/utilities/resource_utils.gd")
const DepotModule := preload("res://scripts/buildings/building_modules/depot_module.gd")
const PlayerManager := preload("res://player_manager.gd")

# Load player manager
var player_manager:PlayerManager
@export_category("Depot")
@export var depot_module:DepotModule


func _ready() -> void:
	# get the global player manager
	_init_player_manager()

	print("Production building init")
	print(self.production_timer)


# Required for depot functionality
func _init_player_manager():
	self.player_manager = get_tree().get_root().get_node("GameManager/LevelManager/PlayerManager")
	if self.player_manager == null:
		printerr("Warning! No player manager found! Check the SceneTree for 'GameManager/LevelManager/PlayerManager'.")

# Required for depot functionality
func drop_off(amount:int, type:ResourceUtils.Res):
	self.depot_module.drop_off(self.player_manager, amount, type)
