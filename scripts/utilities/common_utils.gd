extends Node

static func is_array_equal(array1:Array, array2:Array) -> bool:
	## Return false if arrays are not the same size
	if array1.size() != array2.size():
		return false
		print("Not the same size")
	
	## Check each item one to one. For both to be considered equal, they must have the same contents in the same order
	for index in range(array1.size()):
		## Return false if at any point two objects do not match
		if array1[index] != array2[index]:
			print("Object at index ", index, " is different")
			return false
	
	## If all objects were identical, return true
	return true
