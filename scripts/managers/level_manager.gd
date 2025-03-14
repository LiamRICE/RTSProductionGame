class_name GameManager extends Node

### Contains functions and methods for the management of the in-progress game ###

## Nodes
@onready var player_buildings = $PlayerBuildings
@onready var player_units = $PlayerUnits
@onready var other_buildings = $OtherBuildings
@onready var other_units = $OtherUnits

@onready var player_interface = $PlayerInterface


## Common functions

## Adds a building to the world
func add_building(team:int, building:Building, location:Vector3) -> void:
	if player_interface.player_team == team:
		self.player_buildings.add_child(building)
	else:
		self.other_buildings.add_child(building)
	building.place(location)
