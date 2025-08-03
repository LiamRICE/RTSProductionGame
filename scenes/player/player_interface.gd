extends Control

## Signals
signal selection_changed(selection:Selection, selection_type:UIStateUtils.SelectionType)

## Loading Script Classes
const PlayerScreen:Script = preload("uid://bih6yn0b7x8my")
const GroupActionsPanel:Script = preload("uid://cbkqp04y5bfn5")
const LevelManager:Script = preload("uid://c3m2j27g87q0x")
const UIManager:Script = preload("uid://brcxb50tcwui4")
const UIStateUtils:Script = preload("uid://cs16g08ckh1rw")
const camera_operations:Script = preload("uid://chhtn0cum8l6r")
const CommonUtils:Script = preload("uid://dnagpvnlsrxbi")
const Selection:Script = preload("uid://cj0c8liafc0fd")

## Mouse images
var mouse_default:Texture2D = preload("res://assets/ui/icons/mouse/pointer_scifi_b.png")
var mouse_enemy:Texture2D = preload("res://assets/ui/icons/mouse/target_round_b.png")
var mouse_resource:Texture2D = preload("res://assets/ui/icons/mouse/tool_pickaxe.png")
var mouse_build:Texture2D = preload("res://assets/ui/icons/mouse/tool_hammer.png")
var mouse_repair:Texture2D = preload("res://assets/ui/icons/mouse/tool_wrench.png")

## Child nodes
@export var camera_controller:Node3D

## Nodes
@onready var level_manager:LevelManager = %LevelManager
@onready var ui_manager:UIManager = %UIManager
@onready var ui_selection_patch:NinePatchRect = $SelectionRect
@onready var player_camera:Camera3D = camera_controller.get_node(NodePath("Yaw/Pitch/MainCamera"))

## DEBUG
@onready var debug_controls:Control = $DebugControls
@onready var deploy_unit_button:Button = $DebugControls/DeployUnitButton # DEBUG
@onready var add_unit_button:Button = $DebugControls/Button # DEBUG
@onready var unit_blob_button:Button = $DebugControls/UnitBlob # DEBUG
@onready var spin_box:SpinBox = $DebugControls/SpinBox # DEBUG

## Internal mouse state
var state:UIStateUtils.ClickState

## Variables
var selected_entities:Selection = Selection.new()
var selected_type:UIStateUtils.SelectionType = UIStateUtils.SelectionType.NONE
var constructing_building:Building
var num_deployments:int = 0
var mouse_state:UIStateUtils.MouseState = UIStateUtils.MouseState.DEFAULT

## Selection Variables
var _mouse_left_click:bool = false
var _dragged_rect_left:Rect2
var _mouse_right_click:bool = false
var _is_constructing:bool = false
var is_on_ui:bool = false

## Ability Variables
var ability_array:Array[EntityActiveLocationAbility]

## Constants
const MIN_SELECT_SQUARED:float = 81

## Team
var player_team:int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	# Initialise the interface for the start of the game
	initialise_interface()
	initialise_state_machine()


func _physics_process(delta:float):
	mouse_state_update()


func mouse_state_update():
	# check underlying object type
	var camera :Camera3D = get_viewport().get_camera_3d()
	var current_state:UIStateUtils.MouseState = mouse_state
	# cast to check location
	var raycast_result = cast_ray(camera)
	var target:Entity
	if raycast_result.get("collider") != null:
		if raycast_result.get("collider").is_in_group("navigation_map"):
			mouse_state = UIStateUtils.MouseState.DEFAULT
		else:
			target = raycast_result.get("collider").get_parent()
			# check current selection
			if self.selected_type in [UIStateUtils.SelectionType.UNITS_ECONOMIC]:
				# check cast result
				if target.is_in_group("resource"):
					self.mouse_state = UIStateUtils.MouseState.RESOURCE
				elif target.is_in_group("buildings") and target.allegiance == self.player_team:
					if target.build_percent < 100:
						self.mouse_state = UIStateUtils.MouseState.BUILD
					elif target.current_health < target.current_health:
						self.mouse_state = UIStateUtils.MouseState.REPAIR
				elif (target.is_in_group("units") or target.is_in_group("buildings")) and target.allegiance != self.player_team:
					self.mouse_state = UIStateUtils.MouseState.ENEMY
				else:
					self.mouse_state = UIStateUtils.MouseState.DEFAULT
			elif self.selected_type in [UIStateUtils.SelectionType.UNITS]:
				# check cast result
				if (target.is_in_group("units") or target.is_in_group("buildings")) and target.allegiance != self.player_team:
					self.mouse_state = UIStateUtils.MouseState.ENEMY
				else:
					self.mouse_state = UIStateUtils.MouseState.DEFAULT


func mouse_update():
	# set mouse image
	if self.mouse_state == UIStateUtils.MouseState.DEFAULT:
		Input.set_custom_mouse_cursor(mouse_default, Input.CURSOR_ARROW, Vector2(9, 9))
	elif self.mouse_state == UIStateUtils.MouseState.RESOURCE:
		Input.set_custom_mouse_cursor(mouse_resource, Input.CURSOR_ARROW, Vector2(15, 15))
	elif self.mouse_state == UIStateUtils.MouseState.BUILD:
		Input.set_custom_mouse_cursor(mouse_build, Input.CURSOR_ARROW, Vector2(15, 15))
	elif self.mouse_state == UIStateUtils.MouseState.REPAIR:
		Input.set_custom_mouse_cursor(mouse_repair, Input.CURSOR_ARROW, Vector2(16, 16))
	elif self.mouse_state == UIStateUtils.MouseState.ENEMY:
		Input.set_custom_mouse_cursor(mouse_enemy, Input.CURSOR_CROSS, Vector2(32, 32))
	


func initialise_interface() -> void:
	# Defaults the selection rectangle in the UI to invisible
	ui_selection_patch.visible = false


func initialise_state_machine():
	# Initialises the state machine for the user interface
	state = UIStateUtils.ClickState.DEFAULT


func _input(event:InputEvent) -> void:
	""" SELECTION STATES """
	if event is InputEventMouseButton: ## On mouse click and release
		## Handle Left click
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			match self.state:
				UIStateUtils.ClickState.DEFAULT, UIStateUtils.ClickState.SELECTED when not self.ui_manager.is_on_ui: ## When the mouse is in the default state or has units selected
					if event.is_pressed(): ## If LMB is pressed
						state = UIStateUtils.ClickState.SELECTING ## Update state machine
						## Updates the dragged rect start position
						_dragged_rect_left.position = get_global_mouse_position()
						ui_selection_patch.position = _dragged_rect_left.position
						_mouse_left_click = true
						print("Clicked")
					elif not event.is_pressed(): ## If LMB is released
						print("Released while in default or selected state")
				
				UIStateUtils.ClickState.SELECTING: ## When the mouse is in the process of box selecting units
					if not event.is_pressed():
						_mouse_left_click = false
						ui_selection_patch.visible = false ## Hides the UI selection patch
						var success = cast_selection() ## Casts the selection and adds any units into the selection
						if success: # Update state machine based on selection casting
							state = UIStateUtils.ClickState.SELECTED
						else:
							state = UIStateUtils.ClickState.DEFAULT
				
				UIStateUtils.ClickState.CONSTRUCTING when not self.ui_manager.is_on_ui: ## When the mouse has a building that is being constructing and is waiting for placement
					if self.constructing_building.is_placement_valid():
						state = UIStateUtils.ClickState.DEFAULT
						var camera :Camera3D = get_viewport().get_camera_3d()
						var click_position :Vector3 = camera_operations.global_position_from_raycast(camera, event.position)
						self.remove_child(self.constructing_building)
						self.level_manager.add_building(self.constructing_building, click_position)
						## TODO - Debug, make allegiance based on player interface
					else:
						print("Invalid placement ! Object intersects placement blocker.")
				
				UIStateUtils.ClickState.ABILITY when not self.ui_manager.is_on_ui: ## When the mouse has an ability waiting to have a location or unit selected on the map
					## TODO start ability at the location clicked
					if event.is_pressed():
						self.set_ability_location(event.position)
						print("Left Ability")
					
		## Handle Right click
		if event.button_index == MouseButton.MOUSE_BUTTON_RIGHT:
			match self.state:
				UIStateUtils.ClickState.DEFAULT:
					print("Right Default")
				UIStateUtils.ClickState.SELECTING:
					print("Right Selecting")
				UIStateUtils.ClickState.SELECTED when not self.ui_manager.is_on_ui:
					if event.is_pressed():
						self._give_move_order(event.shift_pressed)
				UIStateUtils.ClickState.CONSTRUCTING:
					if event.is_pressed():
						state = UIStateUtils.ClickState.DEFAULT
						self._is_constructing = false
						self.remove_child(self.constructing_building)
						self.constructing_building = null
				UIStateUtils.ClickState.ABILITY:
					## TODO cancel ability mode
					if event.is_pressed():
						self.state = UIStateUtils.ClickState.SELECTED
					print("Right Ability")
	
	# Runs once at the start of each selection rect, if the state is DEFAULT
	#if Input.is_action_just_pressed("mouse_left_click") and (state == UIStateUtils.ClickState.DEFAULT or state == UIStateUtils.ClickState.SELECTED) and not self.ui_manager.is_on_ui:
		## Update state machine
		#state = UIStateUtils.ClickState.SELECTING
		## Updates the dragged rect start position
		#_dragged_rect_left.position = get_global_mouse_position()
		#ui_selection_patch.position = _dragged_rect_left.position
		#_mouse_left_click = true
		
	# Runs once at the end of each selection rect
	#if Input.is_action_just_released("mouse_left_click") and state == UIStateUtils.ClickState.SELECTING:
		## Hides the UI selection patch
		#_mouse_left_click = false
		#ui_selection_patch.visible = false
		## Casts the selection and adds any units into the selection
		#var success = cast_selection()
		## Update state machine
		#if success:
			#state = UIStateUtils.ClickState.SELECTED
		#else:
			#state = UIStateUtils.ClickState.DEFAULT
	
	#if Input.is_action_just_pressed("mouse_right_click") and state == UIStateUtils.ClickState.SELECTED and not self.ui_manager.is_on_ui:
		#var camera :Camera3D = get_viewport().get_camera_3d()
		## cast to check location
		#var raycast_result = cast_ray(camera)
		#var target:Entity
		#if raycast_result.get("collider") != null:
			#if not raycast_result.get("collider").is_in_group("navigation_map"):
				#target = raycast_result.get("collider").get_parent()
			## check if is in group unit and is enemy -> assign as target
			## check if on resource and unit has gatherer node -> assign as resource node
			#_mouse_right_click = true
			#if not selected_entities.contents.is_empty() and self.selected_type in [UIStateUtils.SelectionType.UNITS, UIStateUtils.SelectionType.UNITS_ECONOMIC]:
				#var mouse_position :Vector2 = get_viewport().get_mouse_position()
				#
				#var camera_raycast_coords :Vector3 = camera_operations.global_position_from_raycast(camera, mouse_position)
				#if not camera_raycast_coords.is_zero_approx():
					## TODO - spread out units
					#var spread_array:Array[Vector3] = CommonUtils.get_unit_position_spread(selected_entities.contents[0].global_position, camera_raycast_coords, camera_raycast_coords, len(selected_entities.contents))
					#for i in range(len(selected_entities.contents)):
						#var unit = selected_entities.contents[i]
						#var target_pos = spread_array[i]
						#var is_shift:bool = Input.is_key_pressed(KEY_SHIFT)
						#if target != null and unit.has_method("set_gathering_target") and target.is_in_group("resource"):
							#unit.set_gathering_target(target, is_shift)
						#else:
							#unit.update_target_location(target_pos, is_shift)
	
	#""" CONSTRUCTION STATES """
	#if Input.is_action_pressed("mouse_right_click") and state == UIStateUtils.ClickState.CONSTRUCTING:
		#state = UIStateUtils.ClickState.DEFAULT
		#self._is_constructing = false
		#self.remove_child(self.constructing_building)
		#self.constructing_building = null
	#
	#if Input.is_action_pressed("mouse_left_click") and state == UIStateUtils.ClickState.CONSTRUCTING and not self.ui_manager.is_on_ui:
		#if self.constructing_building.is_placement_valid():
			#state = UIStateUtils.ClickState.DEFAULT
			#var camera :Camera3D = get_viewport().get_camera_3d()
			#var mouse_position :Vector2 = get_viewport().get_mouse_position()
			#var click_position :Vector3 = camera_operations.global_position_from_raycast(camera, mouse_position)
			#self.remove_child(self.constructing_building)
			#self.level_manager.add_building(self.constructing_building, click_position)
			### TODO - Debug, make allegiance based on player interface
		#else:
			#print("Invalid placement ! Object intersects placement blocker.")


""" SELECTION CODE """

## Assigns a move order to all units currently in the selection
func _give_move_order(shift_pressed:bool) -> void:
	var camera :Camera3D = get_viewport().get_camera_3d()
	# cast to check location
	var raycast_result = cast_ray(camera)
	var target:Entity
	if raycast_result.get("collider") != null:
		if not raycast_result.get("collider").is_in_group("navigation_map"):
			target = raycast_result.get("collider").get_parent()
		## check if is in group unit and is enemy -> assign as target
		## check if on resource and unit has gatherer node -> assign as resource node
		_mouse_right_click = true
		if not selected_entities.contents.is_empty() and self.selected_type in [UIStateUtils.SelectionType.UNITS, UIStateUtils.SelectionType.UNITS_ECONOMIC]:
			var mouse_position :Vector2 = get_viewport().get_mouse_position()
			var camera_raycast_coords :Vector3 = camera_operations.global_position_from_raycast(camera, mouse_position)
			if not camera_raycast_coords == Vector3.ZERO:
				# TODO - spread out units
				var spread_array:Array[Vector3] = CommonUtils.get_unit_position_spread(selected_entities.contents[0].global_position, camera_raycast_coords, camera_raycast_coords, len(selected_entities.contents))
				for i in range(len(selected_entities.contents)):
					var unit = selected_entities.contents[i]
					var target_pos = spread_array[i]
					if target != null and unit is ResourceCollectorUnit and target.is_in_group("resource"):
						var gather_op:GatherOperation = GatherOperation.new(unit, shift_pressed, null, target)
						unit.add_order(gather_op, shift_pressed)
						print("Gathereing order given")
					else:
						var move_order:MoveOrder = MoveOrder.new(unit, shift_pressed, null, target_pos)
						unit.add_order(move_order, shift_pressed)
						print("Move order given")

func cast_selection() -> bool:
	# Clears the selection
	# TODO Add modifier keys that either clear the selection or add to selection, etc...
	#self.selected_entities.clear()
	# List all the buildings and units independantly in the selection rect
	var buildings:Array[Entity]
	var units:Array[Entity]
	for unit in get_tree().get_nodes_in_group("units"): ## Find units selected
		# checks if the unit is controlled by the player
		if unit.allegiance == player_team:
			# Checks if each unit is contained within the dragged selection rect
			if _dragged_rect_left.abs().has_point(player_camera.project_to_screen(unit.global_transform.origin)):
				units.push_back(unit)
				unit.select()
			else:
				unit.deselect()
	for building in get_tree().get_nodes_in_group("buildings"): ## Find buildings selected
		# checks if the building is controlled by the player
		if building.allegiance == player_team:
			# checks if the building is contained within the dragged selection rect
			if _dragged_rect_left.abs().has_point(player_camera.project_to_screen(building.global_transform.origin)):
				buildings.push_back(building)
				building.select()
			else:
				building.deselect()
	# Add the selection with the most objects to the selection list
	self.selected_type = UIStateUtils.SelectionType.NONE
	var new_selection:Array[Entity]
	if units.size() >= buildings.size() and units.size() > 0:
		new_selection = units
		# check if all economic
		var all_eco:bool = true
		for u in units:
			if not u.is_in_group("resource_gatherer"):
				all_eco = false
		if all_eco:
			self.selected_type = UIStateUtils.SelectionType.UNITS_ECONOMIC
		else:
			self.selected_type = UIStateUtils.SelectionType.UNITS
	elif buildings.size() > 0:
		new_selection = buildings
		self.selected_type = UIStateUtils.SelectionType.BUILDINGS
	if not CommonUtils.is_array_equal(new_selection, self.selected_entities.contents):
		self.selected_entities.contents = new_selection
		self.selection_changed.emit(self.selected_entities, self.selected_type)
	## Return if the selection found anything
	if self.selected_type == UIStateUtils.SelectionType.NONE:
		return false
	else:
		return true

## Modifies the size of the selection rectangle based on current position
func update_ui_selection_rect() -> void:
	# Gives the UI rect the same size as the dragged rect (absoluted since a NinePatchRect can't have a negative size)
	self.ui_selection_patch.size = abs(self._dragged_rect_left.size)
	# Negative scaling since NinePatchRect only allows for positive sizes
	# Scale the nine patch rect X axis by -1 to enable dragging left
	if self._dragged_rect_left.size.x < 0:
		self.ui_selection_patch.scale.x = -1
	else:
		self.ui_selection_patch.scale.x = 1
	# Scale the nine patch rect Y axis by -1 to enable dragging up
	if self._dragged_rect_left.size.y < 0:
		self.ui_selection_patch.scale.y = -1
	else:
		self.ui_selection_patch.scale.y = 1

""" ABILITIES CODE """

## Set the mouse state to ability and stores the array of abilities to use
func add_ability_to_queue(ability:EntityActiveLocationAbility) -> void:
	if self.ability_array.size() == 0:
		self.ability_array.push_back(ability)
		self.state = UIStateUtils.ClickState.ABILITY
		print(self.ability_array.size())
	elif ability.equals(self.ability_array[0]):
		self.ability_array.push_back(ability)
		print(self.ability_array.size())
	else:
		self.ability_array.resize(1)
		self.ability_array[0] = ability

func set_ability_location(screen_position:Vector2) -> void:
	var click_position :Vector3 = camera_operations.global_position_from_raycast(self.player_camera, screen_position)
	
	var ability:EntityActiveLocationAbility = self.ability_array.pop_front()
	if self.ability_array.size() == 0:
		self.state = UIStateUtils.ClickState.SELECTED
	print(self.ability_array.size())
	ability.start_ability_at_location(click_position)

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta:float) -> void:
	# update mouse visual
	self.mouse_update()
	# manage left click selection rectangle
	if self._mouse_left_click:
		# Update the size of the dragged rect
		self._dragged_rect_left.size = get_global_mouse_position() - self._dragged_rect_left.position
	
		# Update the UI rect's position and scale
		self.update_ui_selection_rect()
		self.cast_selection()
		
		# Only show the ui_rect if it's above a certain size to avoid it always appearing
		if self._dragged_rect_left.size.length_squared() > self.MIN_SELECT_SQUARED:
			self.ui_selection_patch.visible = true
	# manage construction states
	if self.state == self.UIStateUtils.ClickState.CONSTRUCTING:
		var mouse_position :Vector2 = get_viewport().get_mouse_position()
		self.constructing_building.global_position = self.camera_operations.global_position_from_raycast(self.player_camera, mouse_position) + Vector3(0, 0.05, 0)
		self.constructing_building.is_placement_valid()


""" DEBUG/UTILITY """

## Add building
func _on_deploy_unit_button_pressed():
	self._is_constructing = true
	self.state = UIStateUtils.ClickState.CONSTRUCTING
	self.constructing_building = preload("uid://b1tdkpg420s70").instantiate()
	self.constructing_building.initialise_placement(self.player_team)
	self.add_child(self.constructing_building)


func _on_barracks_added():
	self._is_constructing = true
	self.state = UIStateUtils.ClickState.CONSTRUCTING
	self.constructing_building = preload("uid://bra66m3iaqt8s").instantiate()
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
	var vehicle_scene:PackedScene = preload("uid://xejesn3s5jis")
	for x in range(-10, 0):
		for z in range(-10, 0):
			var vehicle:Vehicle = vehicle_scene.instantiate()
			vehicle.allegiance = self.player_team
			level_manager.add_unit(vehicle, Vector3(x, 0, z), Vector3(x + 4, 0, z))


func _on_enemy_unit_pressed():
	var vehicle_scene:PackedScene = preload("uid://xejesn3s5jis")
	var vehicle:Vehicle = vehicle_scene.instantiate()
	vehicle.allegiance = self.player_team - 1
	level_manager.add_unit(vehicle, Vector3(0, 0, 0), Vector3(-12, 0, -12))


func _on_build_depot_pressed() -> void:
	self._is_constructing = true
	self.state = UIStateUtils.ClickState.CONSTRUCTING
	self.constructing_building = preload("uid://bll0qqe2act2i").instantiate()
	self.constructing_building.initialise_placement(self.player_team)
	self.add_child(self.constructing_building)
