class_name Building extends Entity

## Mandatory Nodes
@export var mesh_container:Node3D
@export var navigation_obstacle:NavigationObstacle3D
@export var placement_collision_shape:CollisionShape3D

## Building properties
@export_group("Properties")
@export var preview_material:StandardMaterial3D
@export var preview_valid_colour:Color
@export var preview_invalid_colour:Color
var placement_collision_area:Area3D

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
	var bodies:int = self.placement_collision_area.get_overlapping_bodies().size()
	var is_valid:bool = bodies == 0
	if is_valid:
		self.preview_material.set_albedo(self.preview_valid_colour)
	else:
		self.preview_material.set_albedo(self.preview_invalid_colour)
	return is_valid

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

func _init_placement_collision():
	# Create the placement collision area
	self.placement_collision_area = Area3D.new()
	self.placement_collision_area.add_child(self.placement_collision_shape.duplicate(8))
	self.add_child(self.placement_collision_area)

func _free_placement_collision():
	# Disconnect signals and free the area3D node
	self.placement_collision_area.queue_free()
