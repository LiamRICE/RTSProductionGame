extends Node

### Contains functions and methods for the management of the in-progress game ###

## Constants
const WorldManager:Script = preload("uid://djyeu4i21c28o")
const PlayerInterface:Script = preload("uid://crs777xecsrt4")

## Nodes
@onready var world_manager:WorldManager = %WorldManager
@onready var player_manager = %PlayerManager
@onready var player_interface:PlayerInterface = $UIManager/PlayerInterface


## Initial setup
func _ready():
	# Create units
	var vehicle_scene:PackedScene = preload("res://scenes/units/vehicle.tscn")
	var gatherer_scene:PackedScene = preload("res://scenes/units/resource_collector_unit.tscn")
	var city_centre_scene:PackedScene = preload("res://scenes/buildings/city_centre.tscn")
	var building = city_centre_scene.instantiate()
	building.allegiance = 1
	building._init_placement_collision()
	self.add_building(building, Vector3(0,0,0))
	for x in range(3):
		var unit:Unit
		if x < 1:
			unit = vehicle_scene.instantiate()
		else:
			unit = gatherer_scene.instantiate()
		unit.allegiance = 1
		self.add_unit(unit, Vector3(x, 0.2, 3), Vector3(x, 0.2, 3))
	
	# Create buildings


## Common functions

## Adds a building to the world
func add_building(building:Building, location:Vector3) -> void:
	var player:Node = player_manager.get_node("Player" + str(building.allegiance))
	## Add the building to the list of player buildings
	player.get_node("Buildings").add_child(building)
	building.place(location) ## Place the building
	
	if building is ProductionBuilding:
		building.unit_constructed.connect(add_unit)
	
	if building.allegiance == self.player_interface.player_team:
		var fow_sprite:Sprite2D = building.initialise_fog_of_war_propagation()
		world_manager.fog_of_war_register_propagator(fow_sprite, location)


## Adds a unit to the world
func add_unit(unit:Unit, location:Vector3, rally_point:Vector3=location) -> void:
	var player:Node = player_manager.get_node("Player" + str(unit.allegiance))
	## Add the unit to the list of player units
	player.get_node("Units").add_child(unit)
	unit.spawn(location, rally_point) ## Place the unit
	
	if unit.allegiance == self.player_interface.player_team:
		var fow_sprite:Sprite2D = unit.initialise_fog_of_war_propagation()
		world_manager.fog_of_war_register_propagator(fow_sprite, location)
