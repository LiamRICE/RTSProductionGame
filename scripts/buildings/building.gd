class_name Building extends Entity

## Mandatory Nodes
@export var mesh_container:Node3D
@export var navigation_obstacle:NavigationObstacle3D
@export var placement_collision_shape:CollisionShape3D

## Building properties
@export var preview_material:Material
var placement_collision_area:Area3D
var placement_collisions:Array[Node3D]

## Internal state
var is_preview:bool = false


## Building Methods ##

## Called when the player wants to place down a new building
func initialise_placement() -> void:
	_set_preview_state(true)
	_set_preview_material()

func place(location:Vector3) -> void:
	_set_preview_state(false)
	_set_preview_material()
	self.global_position = location

## Checks if the placement of the building doesn't encroach on any other buildings
func is_placement_valid() -> bool:
	return placement_collisions.size() == 0

## If the node is being previewed (needs to be built), disable the collider and enable the placement collision area
func _set_preview_state(is_preview:bool) -> void:
	self.is_preview = is_preview
	self._set_preview_material()
	if is_preview:
		self.body.process_mode = Node.PROCESS_MODE_DISABLED
		self._init_placement_collision()
	else:
		self.body.process_mode = Node.PROCESS_MODE_INHERIT
		self._free_placement_collision()

## Changes the materials of the object to preview materials
func _set_preview_material() -> void:
	if self.is_preview:
		for child in self.mesh_container.get_children():
			for surface in child.get_surface_override_material_count():
				child.set_surface_override_material(surface, self.preview_material)
	else:
		for child in self.mesh_container.get_children():
			for surface in child.get_surface_override_material_count():
				child.set_surface_override_material(surface, null)

## Fires when a body enters the placement area
func _body_entered(body:Node3D) -> void:
	if body.get_parent_node_3d() is Entity and body.get_parent_node_3d() != null:
		var entity:Entity = body.get_parent_node_3d()
		if entity is Building:
			self.placement_collisions.push_back(entity)

## Fires when a body exits the placement area
func _body_exited(body:Node3D) -> void:
	if body.get_parent_node_3d() is Entity and body.get_parent_node_3d() != null:
		var entity:Entity = body.get_parent_node_3d()
		self.placement_collisions.erase(entity)

func _init_placement_collision():
	# Create the placement collision area
	self.placement_collision_area = Area3D.new()
	self.placement_collision_area.body_entered.connect(_body_entered)
	self.placement_collision_area.body_entered.connect(_body_exited)
	self.placement_collision_area.add_child(self.placement_collision_shape.duplicate(8))
	self.add_child(self.placement_collision_area)

func _free_placement_collision():
	# Disconnect signals and free the area3D node
	self.placement_collision_area.body_entered.disconnect(_body_entered)
	self.placement_collision_area.body_entered.disconnect(_body_exited)
	self.placement_collision_area.queue_free()
