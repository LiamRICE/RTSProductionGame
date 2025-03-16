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
