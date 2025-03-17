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
	building.place(location) ## Place the building
	
	if building is ProductionBuilding:
		building.unit_constructed.connect(_on_unit_constructed)

## Adds a unit to the world
func add_unit(team:int, unit:Unit, location:Vector3) -> void:
	var player:Node = player_manager.get_node("Player" + str(team))
	## Add the unit to the list of player units
	player.get_node("Units").add_child(unit)
	unit.spawn(location) ## Place the unit

## Signal fired when a unit is constructed from a building
func _on_unit_constructed(unit:Unit, position:Vector3, move_order:Vector3) -> void:
	print("Unit has been built")
