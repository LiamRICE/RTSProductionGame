extends Node

### Contains functions and methods for the management of the in-progress game ###

## Constants
const WorldManager:Script = preload("uid://djyeu4i21c28o")
const UIManager:Script = preload("uid://brcxb50tcwui4")
const EnvironmentManager:Script = preload("uid://dl1m8wjdgtkai")
const PlayerManager:Script = preload("uid://bi34cw4c6gv1n")
const PlayerInterface:Script = preload("uid://crs777xecsrt4")

## Nodes
@onready var environment_manager:EnvironmentManager = %EnvironmentManager
@onready var world_manager:WorldManager = %WorldManager
@onready var player_manager:PlayerManager = %PlayerManager
@onready var ui_manager:UIManager = %UIManager
@onready var player_interface:PlayerInterface = %UIManager/PlayerInterface


## Initial setup
func _ready():
	EventBus.on_entity_produced.connect(self.add_unit)
	
	# Create units
	var vehicle_scene:PackedScene = preload("uid://xejesn3s5jis")
	var gatherer_scene:PackedScene = preload("uid://ditvkcv1wolek")
	var city_centre_scene:PackedScene = preload("uid://bph3bulc5igvo")
	
	""" Wait for next frame """
	await RenderingServer.frame_post_draw
	
	var building = city_centre_scene.instantiate()
	building.allegiance = 1
	building._init_placement_collision()
	self.add_building(building, Vector3(0,1.5,0))
	
	for x in range(3):
		var unit:Unit
		if x < 1:
			unit = vehicle_scene.instantiate()
		else:
			unit = gatherer_scene.instantiate()
		unit.allegiance = 1
		self.add_unit(unit, Vector3(x, 1.5, 3), Vector3(x, 1.5, 3))
	
	# Create buildings


## Common functions

## Adds a building to the world
func add_building(building:Building, location:Vector3) -> void:
	var player:Node = self.player_manager.get_node("Player" + str(building.allegiance))
	## Add the building to the list of player buildings
	player.get_node("Buildings").add_child(building)
	location.y = 0.0 ## Make sure the building is placed at 0 level
	building.place(location) ## Place the building
	EventBus.on_new_obstacle_created.emit(building, building.navigation_obstacle)

## Adds a resource node to the world
func add_resource_node(node:Resources, location:Vector3) -> void:
	## Add the building to the list of player buildings
	$WorldManager/Resources.add_child(node)
	location.y = 0.0
	node.position = location
	EventBus.on_new_obstacle_created.emit(node, node.navigation_obstacle)

## Adds a unit to the world
func add_unit(unit:Unit, location:Vector3, rally_point:Vector3 = location) -> void:
	var player:Node = player_manager.get_node("Player" + str(unit.allegiance))
	location.y = 0.0
	rally_point.y = 0.0
	## Add the unit to the list of player units
	player.get_node("Units").add_child(unit)
	unit.spawn(location, rally_point) ## Place the unit
