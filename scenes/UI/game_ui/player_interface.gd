extends Node

## Signals
signal selection_changed(selection:Array[Entity], selection_type:UIStateUtils.SelectionType)

# Loading Script Classes
const ResourceBar := preload("uid://bih6yn0b7x8my")
const GroupActionsPanel := preload("uid://cbkqp04y5bfn5")
const LevelManager := preload("res://scripts/managers/level_manager.gd")
const UIStateUtils := preload("res://scripts/utilities/ui_state_utils.gd")
const PlayerControls := preload("uid://dwtqie48lcc3h")

# Mouse images
var mouse_default = load("res://assets/ui/icons/mouse/pointer_scifi_b.png")
var mouse_enemy = load("res://assets/ui/icons/mouse/target_round_b.png")
var mouse_resource = load("res://assets/ui/icons/mouse/tool_pickaxe.png")
var mouse_build = load("res://assets/ui/icons/mouse/tool_hammer.png")
var mouse_repair = load("res://assets/ui/icons/mouse/tool_wrench.png")

# Child nodes
@export_category("Child Nodes")
@export var resource_bar:ResourceBar
@export var group_actions_panel:GroupActionsPanel
@export var player_controls:PlayerControls

# Nodes
@export_category("Associated Nodes")
@export var level_manager:LevelManager
@export var camera_controller:Node3D
@onready var player_camera :Camera3D = camera_controller.get_node(NodePath("Yaw/Pitch/MainCamera"))

## DEBUG
@onready var debug_controls:Control = $DebugControls
@onready var deploy_unit_button:Button = $DebugControls/DeployUnitButton # DEBUG
@onready var add_unit_button:Button = $DebugControls/Button # DEBUG
@onready var unit_blob_button:Button = $DebugControls/UnitBlob # DEBUG
@onready var spin_box:SpinBox = $DebugControls/SpinBox # DEBUG
#const UNIT = preload("res://scenes/units/unit_2.tscn")

# Modules
const camera_operations:GDScript = preload("res://scripts/utilities/camera_operations.gd")
const CommonUtils:GDScript = preload("res://scripts/utilities/common_utils.gd")


var state :UIStateUtils.ClickState
var is_on_ui: bool = false

# Variables
var selected_entities :Array[Entity] = []
var selected_type:UIStateUtils.SelectionType = UIStateUtils.SelectionType.NONE
var constructing_building:Building
var num_deployments :int = 0
var mouse_state:UIStateUtils.MouseState = UIStateUtils.MouseState.DEFAULT

# Internal Variables
var _mouse_left_click :bool = false
var _dragged_rect_left :Rect2
var _mouse_right_click :bool = false
#var _dragged_pos_right :Array[Vector3]
var _is_constructing:bool = false

# Constants
const MIN_SELECT_SQUARED :float = 81

# Team
var player_team: int = 1


func _ready() -> void:
	initialise_interface()
	initialise_connections()	


func initialise_interface() -> void:
	self.selection_changed.connect(self.group_actions_panel._on_player_interface_selection_changed)


func initialise_connections():
	self.player_controls.connect("mouse_entered", self._on_mouse_entered)
	self.player_controls.connect("mouse_exited", self._on_mouse_exited)
	self.resource_bar.connect("mouse_entered", self._on_mouse_entered)
	self.resource_bar.connect("mouse_exited", self._on_mouse_exited)
	self.group_actions_panel.connect("mouse_entered", self._on_mouse_entered)
	self.group_actions_panel.connect("mouse_exited", self._on_mouse_exited)


func _on_mouse_entered():
	is_on_ui = true
	print(is_on_ui)


func _on_mouse_exited():
	is_on_ui = false
	print(is_on_ui)


## Add building
func _on_deploy_unit_button_pressed():
	self._is_constructing = true
	self.state = UIStateUtils.ClickState.CONSTRUCTING
	self.constructing_building = preload("res://scenes/buildings/turret_gun.tscn").instantiate()
	self.constructing_building.initialise_placement(self.player_team)
	self.add_child(self.constructing_building)


func _on_barracks_added():
	self._is_constructing = true
	self.state = UIStateUtils.ClickState.CONSTRUCTING
	self.constructing_building = preload("res://scenes/buildings/barracks.tscn").instantiate()
	self.constructing_building.initialise_placement(self.player_team)
	self.add_child(self.constructing_building)


func cast_ray(camera:Camera3D) -> Dictionary:
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 100
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var space = camera.get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	ray_query.collide_with_areas = true
	var raycast_result = space.intersect_ray(ray_query)
	return raycast_result


func _on_unit_blob_pressed():
	var vehicle_scene:PackedScene = preload("res://scenes/units/vehicle.tscn")
	for x in range(-10, 0):
		for z in range(-10, 0):
			var vehicle:Vehicle = vehicle_scene.instantiate()
			vehicle.allegiance = self.player_team
			level_manager.add_unit(vehicle, Vector3(x, 0, z), Vector3(x + 4, 0, z))


func _on_enemy_unit_pressed():
	var vehicle_scene:PackedScene = preload("res://scenes/units/vehicle.tscn")
	var vehicle:Vehicle = vehicle_scene.instantiate()
	vehicle.allegiance = self.player_team - 1
	level_manager.add_unit(vehicle, Vector3(0, 0, 0), Vector3(4, 0, 0))
	vehicle.update_target_location(Vector3(-12, 0, -12), true)


func _on_build_depot_pressed() -> void:
	self._is_constructing = true
	self.state = UIStateUtils.ClickState.CONSTRUCTING
	self.constructing_building = preload("res://scenes/buildings/depot_building.tscn").instantiate()
	self.constructing_building.initialise_placement(self.player_team)
	self.add_child(self.constructing_building)
