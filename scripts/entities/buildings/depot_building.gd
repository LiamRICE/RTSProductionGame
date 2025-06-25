class_name DepotBuilding extends Building

## Loading script classes
const DepotModule := preload("uid://b6to6vvsk7c8u")
const PlayerManager:Script = preload("uid://bi34cw4c6gv1n")

## Load player manager
var player_manager:PlayerManager
@export_category("Depot")
@export var depot_module:DepotModule

## Required for depot functionality
func drop_off(amount:int, type:RESOURCE):
	print("Dropping off")
	self.depot_module.drop_off(amount, type)
