class_name Unit extends Entity

const unit_utils:GDScript = preload("res://scripts/utilities/unit_utils.gd")

@export_group("Properties")
@export var move_speed : float = 0.
@export var rotation_speed : float = 0.
@export var view_distance : float = 0.

# path information
@export_group("Navigation")
var current_path : PackedVector3Array
var next_point : Vector3
var path_index : int = 0
@export var path_point_margin : float = 0.1

# selection
@onready var selection_sprite : Sprite3D = $SelectionSprite3D
var TEAM : int


func _ready():
	TEAM = allegiance
	_unit_specific_ready()

func spawn(location:Vector3, rally_point:Vector3) -> void:
	self.global_position = location
	set_navigation_path(rally_point)

func _unit_specific_ready():
	pass


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
func set_navigation_path(location:Vector3, is_shift:bool = false):
	"""
	Function description stuff...
	"""
	var path:PackedVector3Array
	# check that object is in tree
	if is_inside_tree():
		# fetch the world's navigation map
		var map_RID:RID = get_world_3d().get_navigation_map()
		# Fetch safe coordinates
		var safe_start:Vector3 = NavigationServer3D.map_get_closest_point(map_RID, global_position)
		if is_shift:
			if len(self.current_path) > 0:
				safe_start = self.current_path[len(self.current_path)-1]
		var safe_end:Vector3 = NavigationServer3D.map_get_closest_point(map_RID, location)
		# caluclate the path
		path = NavigationServer3D.map_get_path(map_RID, safe_start, safe_end, true)
		# return the path
	if is_shift:
		self.current_path.append_array(path)
	else:
		self.current_path.clear()
		self.current_path.append_array(path)
		self.path_index = 0


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
	var movement_delta : float = move_speed * delta
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
