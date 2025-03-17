class_name Vehicle extends Unit


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
	#var rotation_quantity:float = rotation_speed * delta
	var target_vector = global_position.direction_to(next_point)
	var target_quaternion:Quaternion = Basis.looking_at(target_vector).get_rotation_quaternion()
	var angle = unit_utils.get_relative_angle(quaternion, target_quaternion)
	#print("Required rotation : ", angle)
	# rotate unit
	#if abs(angle) > rotation_quantity:
		#basis = basis.rotated(Vector3(0, 1, 0), rotation_quantity)
	# set unit velocity to the next path point if pointing the right direction
	#else:
		#basis = basis.rotated(Vector3(0, 1, 0), angle)
	var new_velocity: Vector3 = global_transform.origin.direction_to(next_point) * movement_delta
	global_transform.origin = global_transform.origin.move_toward(global_transform.origin + new_velocity, movement_delta)
