class_name Unit extends Entity

## Constants
const unit_utils:Script = preload("uid://dsx2p0n73ktne")
const Vector3SecondOrderDynamics:Script = preload("uid://dk0dxwf2vi886")
const QuaternionSecondOrderDynamics:Script = preload("uid://2qt0fxo8oqaa")

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

## Animation Parameters
@export_group("Animation Parameters")
var target_position:Vector3 ## The commanded linear position along the path
@export_subgroup("Position Interpolation")
@export var position_frequency:float = 1.0 ## Must be positive, a higher frequency implies a faster reaction to the stimulus
@export var position_damping_coeficient:float = 1.0 ## Must be positive, between 0 and 1 is underdamped, 1 is critically damped and more that 1 is overdamped
@export var position_response_coeficient:float = 0.0 ## Less than 0 is anticipation, 0 is smooth acceleration and above 0 starts with some impulse
@export_subgroup("Rotation Interpolation")
@export var rotation_frequency:float = 2.0 ## Must be positive, a higher frequency implies a faster reaction to the stimulus
@export var rotation_damping_coeficient:float = 1.0 ## Must be positive, between 0 and 1 is underdamped, 1 is critically damped and more that 1 is overdamped
@export var rotation_response_coeficient:float = 0.0 ## Less than 0 is anticipation, 0 is smooth acceleration and above 0 starts with some impulse
var position_dynamics:Vector3SecondOrderDynamics
var rotation_dynamics:QuaternionSecondOrderDynamics

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
	
	## Animation initialisation
	self.target_position = self.global_position
	self.position_dynamics = Vector3SecondOrderDynamics.new(self.position_frequency, self.position_damping_coeficient, self.position_response_coeficient, self.global_position)
	self.rotation_dynamics = QuaternionSecondOrderDynamics.new(self.rotation_frequency, self.rotation_damping_coeficient, self.rotation_response_coeficient, self.quaternion)


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
		start = self.global_position
	## Query the entity navigation server
	EntityNavigationServer.request_path(self, start, location)

func _path_received(path: PackedVector3Array) -> void:
	self.is_waiting_for_path = false
	## Check path has data (paths generated before Navmesh sync can be empty as can 0 distance paths)
	if path.is_empty():
		return
	if self.is_shift:
		self.current_path.append_array(path)
	else:
		self.current_path = path
		self.path_index = 1
		self.next_point = self.current_path[1]
	
	## Debug - TODO Maybe turn this into an effect
	self.debug_render_unit_path(self.current_path)

	# If there's a buffered request, send it now
	if self.has_pending_request:
		self.is_shift = self.is_queued_shift
		self._request_path_async(self.pending_target)

func update_target_location(target_location:Vector3, is_shift:bool = false):
	# raycast target location
	# if raycast is a unit, set that unit as the target and stop when you're in range
	# if raycast is not a unit, set that location as a target and stop at the target
	self.set_navigation_path(target_location, is_shift)


func move(delta:float):
	## Check if path is empty, stop moving
	if self.global_position.is_equal_approx(self.target_position) and self.current_path.is_empty():
		return
	
	## Increment next path point if current point has been reached
	if self.target_position.distance_to(self.next_point) <= self.path_point_margin:
		self.path_index += 1
		if self.path_index >= self.current_path.size():
			self.current_path.clear()
			self.path_index = 0
	
	## Set the next point to navigate to
	if self.current_path.is_empty():
		self.next_point = target_position
	else:
		self.next_point = self.current_path[self.path_index]
	
	""" POSITION """
	
	## Set movement speed for this frame
	var movement_delta : float = self.entity_statistics[STATS.SPEED] * delta
	
	## Set unit velocity to the next path point
	self.target_position = self.target_position.move_toward(self.next_point, movement_delta)
	self.global_position = self.position_dynamics.update(delta, self.target_position)
	
	""" ROTATION """
	
	## Point unit towards the next path point
	var relative_target:Vector3 = self.next_point - self.target_position
	if not relative_target.is_zero_approx():
		var target_quaternion = Quaternion(Basis.looking_at(relative_target))
		self.quaternion = self.rotation_dynamics.update(delta, target_quaternion)


""" DEBUG METHODS """

## Debug method : draws a mesh polyline to represent the unit's chosen navigation path
func debug_render_unit_path(path:PackedVector3Array) -> void:
	self.path_updated.emit(self, path)
