class_name Unit extends Entity

## Constants
const unit_utils:Script = preload("res://scripts/utilities/unit_utils.gd")

## Signals
signal path_updated(Entity, PackedVector3Array)

## Path Information
@export_group("Navigation")
var current_path : PackedVector3Array
var next_point : Vector3
var path_index : int = 0
@export var path_point_margin : float = 0.1
var is_shift:bool = false
var is_waiting_for_path:bool = false
var has_pending_request:bool = false
var is_queued_shift:bool = false
var pending_target:Vector3

## Selection
@onready var selection_sprite : Sprite3D = $SelectionSprite3D
var TEAM : int


func _ready():
	## Execute parent _ready function
	super._ready()
	
	TEAM = allegiance

func spawn(location:Vector3, rally_point:Vector3) -> void:
	self.global_position = location
	self.basis = Basis.IDENTITY
	call_deferred("set_navigation_path", rally_point)


func _physics_process(delta: float) -> void:
	# run movment code
	move(delta)


func select() -> bool:
	if is_selectable:
		selection_sprite.show()
	return is_selectable


func deselect():
	selection_sprite.hide()


# order the unit to move to a location
func set_navigation_path(location:Vector3, is_shift:bool = false) -> void:
	"""
	Function description stuff...
	"""
	# check that object is in tree
	if is_inside_tree():
		## Check if a path is currently being fetched
		if self.is_waiting_for_path:
			## Store new request to process after current one finishes
			self.pending_target = location
			self.has_pending_request = true
			self.is_queued_shift = is_shift
		else:
			self.is_shift = is_shift
			self._request_path_async(location)

func _request_path_async(location:Vector3) -> void:
	self.is_waiting_for_path = true
	self.has_pending_request = false
	## Fetch start coordinates
	var start:Vector3
	if self.is_shift and self.current_path.size() > 0:
		start = self.current_path[self.current_path.size() - 1]
	else:
		start = global_position
	EntityNavigationServer.request_path(self, start, location)

func _path_received(path: PackedVector3Array) -> void:
	self.is_waiting_for_path = false
	if self.is_shift:
		self.current_path.append_array(path)
	else:
		self.current_path = path
	
	## Debug - TODO Maybe turn this into an effect
	debug_render_unit_path(self.current_path)

	# If there's a buffered request, send it now
	if self.has_pending_request:
		self.is_shift = self.is_queued_shift
		self._request_path_async(self.pending_target)

func update_target_location(target_location:Vector3, is_shift:bool = false):
	# raycast target location
	# if raycast is a unit, set that unit as the target and stop when you're in range
	# if raycast is not a unit, set that location as a target and stop at the target
	set_navigation_path(target_location, is_shift)


func move(delta:float):
	# check if path is empty, stop moving
	#print("Assigned path = ", self.current_path)
	if self.current_path.is_empty():
		return
	# set movement speed for this frame
	var movement_delta : float = self.entity_statistics[STATS.SPEED] * delta
	# increment next path point if current point has been reached
	if self.global_transform.origin.distance_to(self.next_point) <= path_point_margin:
		self.path_index += 1
		if self.path_index >= self.current_path.size():
			self.current_path = PackedVector3Array()
			self.path_index = 0
			self.next_point = global_transform.origin
			return
	if self.path_index < len(current_path):
		self.next_point = self.current_path[self.path_index]
	# point unit towards the next path point
	var target_vector = self.global_position.direction_to(self.next_point)
	var target_basis = Basis.looking_at(target_vector)
	self.basis = target_basis
	# set unit velocity to the next path point
	var new_velocity: Vector3 = self.global_transform.origin.direction_to(next_point) * movement_delta
	self.global_transform.origin = self.global_transform.origin.move_toward(global_transform.origin + new_velocity, movement_delta)


""" DEBUG METHODS """

## Debug method : draws a mesh polyline to represent the unit's chosen navigation path
func debug_render_unit_path(path:PackedVector3Array) -> void:
	self.path_updated.emit(self, path)
