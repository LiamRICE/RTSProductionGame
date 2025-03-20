class_name LevelManager extends Node

### Contains functions and methods for the management of the in-progress game ###

## Nodes
@onready var player_manager = %PlayerManager


## Common functions

## Adds a building to the world
func add_building(team:int, building:Building, location:Vector3) -> void:
	var player:Node = player_manager.get_node("Player" + str(team))
	## Add the building to the list of player buildings
	player.get_node("Buildings").add_child(building)
	building.place(location, team) ## Place the building
	
	if building is ProductionBuilding:
		building.unit_constructed.connect(add_unit)

## Adds a unit to the world
func add_unit(unit:Unit, location:Vector3, rally_point:Vector3) -> void:
	var player:Node = player_manager.get_node("Player" + str(unit.allegiance))
	## Add the unit to the list of player units
	player.get_node("Units").add_child(unit)
	unit.spawn(location, rally_point) ## Place the unit
