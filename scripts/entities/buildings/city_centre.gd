extends ProductionBuilding

# Script loading
const DepotModule := preload("uid://b6to6vvsk7c8u")

# Load player manager
@export_category("Depot")
@export var depot_module:DepotModule


func _ready() -> void:
	super._ready()

# Required for depot functionality
func drop_off(amount:Dictionary[RESOURCE, int]):
	self.depot_module.drop_off(amount)
