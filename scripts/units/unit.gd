class_name Unit extends Entity

const unit_utils:GDScript = preload("res://scripts/utilities/unit_utils.gd")

@export_group("Properties")
@export var move_speed : float = 0.
@export var rotation_speed : float = 0.

# path information
@export_group("Navigation")
var current_path : PackedVector3Array
var next_point : Vector3
var path_index : int = 0
@export var path_point_margin : float = 0.2

# selection
@onready var selection_sprite : Sprite3D = $SelectionSprite3D
var TEAM : int


func _ready():
	TEAM = allegiance


func _physics_process(delta: float) -> void:
	# run movment code
	move(delta)


func select():
	selection_sprite.show()


func deselect():
	selection_sprite.hide()


# order the unit to move to a location
func set_navigation_path(location:Vector3, is_shift:bool = false):
	"""
	Function description stuff...
	"""
	var path:PackedVector3Array = PackedVector3Array()
	# check that object is in tree
	if is_inside_tree():
		# fetch the world's navigation map
		var map_RID:RID = get_world_3d().get_navigation_map()
		# caluclate the path
		path = NavigationServer3D.map_get_path(map_RID, global_transform.origin, location, true)
		print(path)
		# return the path
	if is_shift:
		current_path.append_array(path)
	else:
		current_path = path


func update_target_location(target_location:Vector3, is_shift:bool = false):
	# raycast target location
	# if raycast is a unit, set that unit as the target and stop when you're in range
	# if raycast is not a unit, set that location as a target and stop at the target
	set_navigation_path(target_location, is_shift)


func move(delta:float):
	# check if path is empty, stop moving
	if current_path.is_empty():
		return
	# set movement speed for this frame
	var movement_delta : float = move_speed * delta
	# increment next path point if current point has been reached
	if global_transform.origin.distance_to(next_point) <= path_point_margin:
		path_index += 1
		if path_index >= current_path.size():
			current_path = []
			path_index = 0
			next_point = global_transform.origin
			return
	if path_index < len(current_path):
		next_point = current_path[path_index] # index out of bounds!
	else:
		current_path = PackedVector3Array()
	# point unit towards the next path point
	var target_vector = global_position.direction_to(next_point)
	var target_basis = Basis.looking_at(target_vector)
	basis = target_basis
	# set unit velocity to the next path point
	var new_velocity: Vector3 = global_transform.origin.direction_to(next_point) * movement_delta
	global_transform.origin = global_transform.origin.move_toward(global_transform.origin + new_velocity, movement_delta)
