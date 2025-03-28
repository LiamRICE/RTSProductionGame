extends Control

## Signals
signal selection_changed(selection:Array[Entity], selection_type:int)

# Loading Script Classes
const PlayerScreen := preload("res://scenes/UI/player_screen.tscn")
const OrdersInterface := preload("res://scripts/ui/level_ui/bottom_bar_container.gd")
const LevelManager := preload("res://scripts/managers/level_manager.gd")

# Mouse images
var mouse_default = load("res://assets/ui/icons/mouse/pointer_scifi_b.png")
var mouse_enemy = load("res://assets/ui/icons/mouse/target_round_b.png")
var mouse_resource = load("res://assets/ui/icons/mouse/tool_pickaxe.png")
var mouse_build = load("res://assets/ui/icons/mouse/tool_hammer.png")
var mouse_repair = load("res://assets/ui/icons/mouse/tool_wrench.png")

# Child nodes
@export var player_screen:PlayerScreen
@export var orders_interface:OrdersInterface

# Nodes
@onready var level_manager:LevelManager = %LevelManager
@onready var ui_selection_patch :NinePatchRect = $SelectionRect
@onready var player_camera :Camera3D = $Camera/Yaw/Pitch/MainCamera
@onready var deploy_unit_button:Button = $DeployUnitButton # DEBUG
@onready var add_unit_button:Button = $Button # DEBUG
@onready var spin_box:SpinBox = $SpinBox # DEBUG
#const UNIT = preload("res://scenes/units/unit_2.tscn")

# Modules
const camera_operations:GDScript = preload("res://scripts/utilities/camera_operations.gd")
const CommonUtils:GDScript = preload("res://scripts/utilities/common_utils.gd")

# State Machine
enum ClickState {
	DEFAULT,
	SELECTING,
	SELECTED,
	CONSTRUCTING
}
enum SelectionType {
	NONE,
	UNITS,
	UNITS_ECONOMIC,
	BUILDINGS
}
enum MouseState {
	DEFAULT,
	RESOURCE,
	REPAIR,
	BUILD,
	ENEMY
}

var state :ClickState
var is_on_ui: bool = false

# Variables
var selected_entities :Array[Entity] = []
var selected_type:SelectionType = SelectionType.NONE
var constructing_building:Building
var num_deployments :int = 0
var mouse_state:MouseState = MouseState.DEFAULT

# Internal Variables
var _mouse_left_click :bool = false
var _dragged_rect_left :Rect2
var _mouse_right_click :bool = false
var _dragged_pos_right :Array[Vector3]
var _is_constructing:bool = false

# Constants
const MIN_SELECT_SQUARED :float = 81

# Team
var player_team: int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	# Initialise the interface for the start of the game
	initialise_interface()
	initialise_state_machine()


func _physics_process(delta: float) -> void:
	mouse_update()


func mouse_update():
	# check underlying object type
	var camera :Camera3D = get_viewport().get_camera_3d()
	# cast to check location
	var raycast_result = cast_ray(camera)
	var target:Entity
	if raycast_result.get("collider") != null:
		if raycast_result.get("collider").is_in_group("navigation_map"):
			mouse_state = MouseState.DEFAULT
		else:
			print(self.selected_type)
			target = raycast_result.get("collider").get_parent()
			# check current selection
			if self.selected_type in [SelectionType.UNITS_ECONOMIC]:
				# check cast result
				if target.is_in_group("resource"):
					self.mouse_state = MouseState.RESOURCE
				elif target.is_in_group("buildings"):
					if target.build_percent < 100:
						self.mouse_state = MouseState.BUILD
					elif target.health < target.max_health:
						self.mouse_state = MouseState.REPAIR
				elif (target.is_in_group("units") or target.is_in_group("buildings")) and target.allegiance != self.player_team:
					self.mouse_state = MouseState.ENEMY
				else:
					self.mouse_state = MouseState.DEFAULT
			elif self.selected_type in [SelectionType.UNITS, SelectionType.UNITS_ECONOMIC]:
				# check cast result
				print(target.is_in_group("units"))
				if (target.is_in_group("units") or target.is_in_group("buildings")) and target.allegiance != self.player_team:
					self.mouse_state = MouseState.ENEMY
				else:
					self.mouse_state = MouseState.DEFAULT
		# calculate mouse state
		# change mouse image by mouse state
		if mouse_state == MouseState.DEFAULT:
			Input.set_custom_mouse_cursor(mouse_default, Input.CURSOR_ARROW, Vector2(9, 9))
		elif mouse_state == MouseState.RESOURCE:
			Input.set_custom_mouse_cursor(mouse_resource, Input.CURSOR_CROSS, Vector2(15, 15))
		elif mouse_state == MouseState.BUILD:
			Input.set_custom_mouse_cursor(mouse_build, Input.CURSOR_CROSS, Vector2(15, 15))
		elif mouse_state == MouseState.REPAIR:
			Input.set_custom_mouse_cursor(mouse_repair, Input.CURSOR_CROSS, Vector2(16, 16))
		elif mouse_state == MouseState.ENEMY:
			Input.set_custom_mouse_cursor(mouse_enemy, Input.CURSOR_CROSS, Vector2(32, 32))


func _on_mouse_entered() -> void:
	self.is_on_ui = true
	print(is_on_ui)


func _on_mouse_exited() -> void:
	self.is_on_ui = false
	print(is_on_ui)


func initialise_interface() -> void:
	# Defaults the selection rectangle in the UI to invisible
	ui_selection_patch.visible = false
	self.orders_interface.mouse_entered.connect(self._on_mouse_entered)
	self.orders_interface.mouse_exited.connect(self._on_mouse_exited)


func initialise_state_machine():
	# Initialises the state machine for the user interface
	state = ClickState.DEFAULT


func _input(_event:InputEvent) -> void:
	## SELECTION STATES ##
	# Runs once at the start of each selection rect, if the state is DEFAULT
	if Input.is_action_just_pressed("mouse_left_click") and (state == ClickState.DEFAULT or state == ClickState.SELECTED) and is_on_ui == false:
		# Update state machine
		state = ClickState.SELECTING
		# Updates the dragged rect start position
		_dragged_rect_left.position = get_global_mouse_position()
		ui_selection_patch.position = _dragged_rect_left.position
		_mouse_left_click = true
		
	# Runs once at the end of each selection rect
	if Input.is_action_just_released("mouse_left_click") and state == ClickState.SELECTING:
		# Hides the UI selection patch
		_mouse_left_click = false
		ui_selection_patch.visible = false
		# Casts the selection and adds any units into the selection
		cast_selection()
		# Update state machine
		state = ClickState.SELECTED
	
	if Input.is_action_just_pressed("mouse_left_click") and state == ClickState.SELECTED and is_on_ui == false:
		# TODO - need to improve the state machine, this one is causing problems with unit selection
		# Update state machine
		state = ClickState.DEFAULT
		# Empty player's unit selection
		selected_entities.clear()
		print("Cleared Selection !")
		for unit in get_tree().get_nodes_in_group("units"):
			unit.deselect()
	
	if Input.is_action_just_pressed("mouse_right_click") and state == ClickState.SELECTED and is_on_ui == false:
		var camera :Camera3D = get_viewport().get_camera_3d()
		# cast to check location
		var raycast_result = cast_ray(camera)
		var target:Entity
		if raycast_result.get("collider") != null:
			print("Navigation Map? ",raycast_result.get("collider").is_in_group("navigation_map"))
			if not raycast_result.get("collider").is_in_group("navigation_map"):
				target = raycast_result.get("collider").get_parent()
			# check if is in group unit and is enemy -> assign as target
			# check if on resource and unit has gatherer node -> assign as resource node
			_mouse_right_click = true
			if not selected_entities.is_empty() and self.selected_type in [SelectionType.UNITS, SelectionType.UNITS_ECONOMIC]:
				var mouse_position :Vector2 = get_viewport().get_mouse_position()
				
				var camera_raycast_coords :Vector3 = camera_operations.global_position_from_raycast(camera, mouse_position)
				if not camera_raycast_coords.is_zero_approx():
					for unit in selected_entities:
						var is_shift:bool = Input.is_key_pressed(KEY_SHIFT)
						if target != null and unit.has_method("set_gathering_target") and target.is_in_group("resource"):
							unit.set_gathering_target(target, is_shift)
							print("Set gathering target...")
						else:
						# TODO - spread out units
							print("Sending coords...")
							unit.update_target_location(camera_raycast_coords, is_shift)
	
	### CONSTRUCTION STATES ###
	if Input.is_action_pressed("mouse_right_click") and state == ClickState.CONSTRUCTING:
		state = ClickState.DEFAULT
		self._is_constructing = false
		self.remove_child(self.constructing_building)
		self.constructing_building = null
	
	if Input.is_action_pressed("mouse_left_click") and state == ClickState.CONSTRUCTING:
		if self.constructing_building.is_placement_valid():
			state = ClickState.DEFAULT
			var plane:Plane = Plane.PLANE_XZ
			var mousepos:Vector2 = self.get_local_mouse_position()
			var click_position:Vector3 = plane.intersects_ray(self.player_camera.project_ray_origin(mousepos), self.player_camera.project_ray_normal(mousepos) * 1000.0)
			self.remove_child(self.constructing_building)
			self.level_manager.add_building(self.spin_box.value as int, self.constructing_building, click_position)
			## TODO - Debug, make allegiance based on player interface
		else:
			print("Invalid placement ! Object intersects placement blocker.")


func cast_selection() -> void:
	# Clears the selection
	# TODO Add modifier keys that either clear the selection or add to selection, etc...
	#self.selected_entities.clear()
	# List all the buildings and units independantly in the selection rect
	var buildings:Array[Entity]
	var units:Array[Entity]
	for unit in get_tree().get_nodes_in_group("units"):
		# checks if the unit is controlled by the player
		if unit.allegiance == player_team:
			# Checks if each unit is contained within the dragged selection rect
			if _dragged_rect_left.abs().has_point(player_camera.project_to_screen(unit.global_transform.origin)):
				units.push_back(unit)
				unit.select()
			else:
				unit.deselect()
	for building in get_tree().get_nodes_in_group("buildings"):
		# checks if the building is controlled by the player
		if building.allegiance == player_team:
			# checks if the building is contained within the dragged selection rect
			if _dragged_rect_left.abs().has_point(player_camera.project_to_screen(building.global_transform.origin)):
				buildings.push_back(building)
				building.select()
			else:
				building.deselect()
	# Add the selection with the most pbjects to the selection list
	self.selected_type = SelectionType.NONE
	var new_selection:Array[Entity]
	if units.size() >= buildings.size() and units.size() > 0:
		new_selection = units
		# check if all economic
		var all_eco:bool = true
		for u in units:
			if not u.is_in_group("resource_gatherer"):
				all_eco = false
		if all_eco:
			self.selected_type = SelectionType.UNITS_ECONOMIC
		else:
			self.selected_type = SelectionType.UNITS
	elif buildings.size() > 0:
		new_selection = buildings
		self.selected_type = SelectionType.BUILDINGS
	if not CommonUtils.is_array_equal(new_selection, self.selected_entities):
		self.selected_entities = new_selection
		self.selection_changed.emit(self.selected_entities, self.selected_type)


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta:float) -> void:
	if _mouse_left_click:
		# Update the size of the dragged rect
		_dragged_rect_left.size = get_global_mouse_position() - _dragged_rect_left.position
	
		# Update the UI rect's position and scale
		update_ui_selection_rect()
		cast_selection()
		
		# Only show the ui_rect if it's above a certain size to avoid it always appearing
		if _dragged_rect_left.size.length_squared() > MIN_SELECT_SQUARED:
			ui_selection_patch.visible = true
	
	if state == ClickState.CONSTRUCTING:
		var plane:Plane = Plane.PLANE_XZ
		var mousepos:Vector2 = self.get_local_mouse_position()
		self.constructing_building.global_position = plane.intersects_ray(self.player_camera.project_ray_origin(mousepos), self.player_camera.project_ray_normal(mousepos) * 1000.0) + Vector3(0, 0.25, 0)
		self.constructing_building.is_placement_valid()

## Modifies the size of the selection rectangle based on current position
func update_ui_selection_rect() -> void:
	# Gives the UI rect the same size as the dragged rect (absoluted since a NinePatchRect can't have a negative size)
	ui_selection_patch.size = abs(_dragged_rect_left.size)
	# Negative scaling since NinePatchRect only allows for positive sizes
	# Scale the nine patch rect X axis by -1 to enable dragging left
	if _dragged_rect_left.size.x < 0:
		ui_selection_patch.scale.x = -1
	else:
		ui_selection_patch.scale.x = 1
	# Scale the nine patch rect Y axis by -1 to enable dragging up
	if _dragged_rect_left.size.y < 0:
		ui_selection_patch.scale.y = -1
	else:
		ui_selection_patch.scale.y = 1

## Add building
func _on_deploy_unit_button_pressed():
	self._is_constructing = true
	self.state = ClickState.CONSTRUCTING
	self.constructing_building = preload("res://scenes/buildings/turret_gun.tscn").instantiate()
	self.constructing_building.initialise_placement()
	self.add_child(self.constructing_building)


func _on_barracks_added():
	self._is_constructing = true
	self.state = ClickState.CONSTRUCTING
	self.constructing_building = preload("res://scenes/buildings/barracks.tscn").instantiate()
	self.constructing_building.initialise_placement()
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
