extends ProductionBuilding

# Script loading
const DepotModule := preload("uid://b6to6vvsk7c8u")

# Load player manager
@export_category("Depot")
@export var depot_module:DepotModule


func _ready() -> void:
	# get the global player manager
	_init_player_manager()

# Required for depot functionality
func drop_off(amount:int, type:ResourceUtils.Res):
	self.depot_module.drop_off(amount, type)
