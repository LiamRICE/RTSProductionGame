extends Node

# define constants
const SQUARE_NUMBERS = [0, 1, 4, 9, 16, 25, 36, 49, 64, 81, 100, 121, 144, 169, 196, 225, 256, 289, 324, 361, 400]

## Checks if two arrays are identical item to item.
static func is_array_equal(array1:Array, array2:Array) -> bool:
	## Return false if arrays are not the same size
	if array1.size() != array2.size():
		return false
	
	## Check each item one to one. For both to be considered equal, they must have the same contents in the same order
	for index in range(array1.size()):
		## Return false if at any point two objects do not match
		if array1[index] != array2[index]:
			return false
	
	## If all objects were identical, return true
	return true

## Returns the position of the raycast hit from the local_position relative to the object. Returns Vector3.UP if no hit is detected.
static func raycast(object:Node3D, local_position:Vector3, direction:Vector3, ray_length:float = 50000) -> Vector3:
	var ray_from :Vector3 = object.global_position + object.global_basis * local_position
	var ray_to :Vector3 = ray_from + direction * ray_length
	
	var ray_parameters :PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_from, ray_to, 1)
	
	var result :Dictionary = object.get_world_3d().get_direct_space_state().intersect_ray(ray_parameters)
	
	if result: return result.position
	else: return Vector3.UP


static func get_unit_position_spread(unit_pos:Vector3, box_start_pos:Vector3, box_end_pos:Vector3, num_units:int) -> Array[Vector3]:
	var spread_array:Array[Vector3] = []
	if box_start_pos == box_end_pos:
		var width:float = 0
		var done = false
		var i = 0
		# getting square positions
		while !done:
			if num_units <= SQUARE_NUMBERS[i]:
				width = i
				done = true
			i += 1
		var new_vect:Vector3 = (box_start_pos - unit_pos)
		var length:float = Vector3.ZERO.distance_to(new_vect)
		# calculate position offset variables for X and Y in the movement grid
		var y_diff = new_vect / length
		var x_diff = Vector3(y_diff.z, y_diff.y, -y_diff.x)
		var position:Vector2 = Vector2(-(width-1)/2, 0)
		for x in range(num_units):
			# calculate the position
			var next_pos:Vector3 = box_start_pos + x_diff * position.x + y_diff * position.y
			spread_array.append(next_pos)
			position.x += 1
			if position.x >= width-1:
				position.x = -(width-1)/2
				position.y -= 1
		return spread_array
	else:
		for i in range(num_units):
			spread_array.append(Vector3.ZERO)
		return spread_array
