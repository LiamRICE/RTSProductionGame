class_name Unit extends Entity

## Constants
const unit_utils:Script = preload("uid://dsx2p0n73ktne")

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
	var order:MoveOrder = MoveOrder.new(self, false, null, rally_point)
	self.add_order(order)
	
	## Animation initialisation
	self.target_position = self.global_position
	self.position_dynamics = Vector3SecondOrderDynamics.new(self.position_frequency, self.position_damping_coeficient, self.position_response_coeficient, self.global_position)
	self.rotation_dynamics = QuaternionSecondOrderDynamics.new(self.rotation_frequency, self.rotation_damping_coeficient, self.rotation_response_coeficient, self.quaternion)


func select() -> bool:
	if is_selectable:
		selection_sprite.show()
	return is_selectable


func deselect():
	selection_sprite.hide()


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
	var relative_target:Vector3 = self.next_point - self.global_position
	if not relative_target.is_zero_approx():
		var target_quaternion = Quaternion(Basis.looking_at(relative_target))
		self.quaternion = self.rotation_dynamics.update(delta, target_quaternion)


""" DEBUG METHODS """

## Debug method : draws a mesh polyline to represent the unit's chosen navigation path
func debug_render_unit_path(path:PackedVector3Array) -> void:
	self.path_updated.emit(self, path)
