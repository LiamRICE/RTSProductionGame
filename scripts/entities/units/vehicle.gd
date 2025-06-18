class_name Vehicle extends Unit

@export var acceleration : float = 0 # m/s²
@export var max_speed : float = 0 # m/s
@export var current_speed : float = 0 # m/s


func _unit_specific_ready():
	current_speed = 0
	

func move(delta:float):
	# check if path is empty, stop moving
	if current_path.is_empty():
		current_speed = 0
		return
	# increment next path point if current point has been reached
	if global_transform.origin.distance_to(next_point) <= path_point_margin:
		path_index += 1
		if path_index >= current_path.size():
			current_path = []
			path_index = 0
			next_point = global_transform.origin
			return
	if path_index < len(current_path):
		next_point = current_path[path_index]

	# rotate unit
	# calculate remaining angle
	var target_vector = global_position.direction_to(next_point)
	var target_basis = Basis.looking_at(target_vector)
	var angle : float = quaternion.angle_to(target_basis.get_rotation_quaternion())
	# slerp with amount increasing to 1 as angle approaches zero
	var weight : float = (delta / rotation_speed) / (angle + (delta / rotation_speed))
	global_basis = global_basis.slerp(target_basis, weight).orthonormalized()
	
	# accelerate unit
	# increase speed by acceleration until max_speed is achieved
	if current_speed != max_speed:
		if current_speed + (acceleration * delta) < max_speed:
			current_speed += acceleration * delta
		else:
			current_speed = max_speed
	# set movement speed for this frame
	var movement_delta : float = current_speed * delta
	var new_velocity: Vector3 = global_transform.origin.direction_to(next_point) * movement_delta
	global_transform.origin = global_transform.origin.move_toward(global_transform.origin + new_velocity, movement_delta)
