extends Node

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
