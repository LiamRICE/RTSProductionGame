extends RefCounted

static func get_relative_angle(original_quaternion:Quaternion, final_quaternion:Quaternion) -> float:
	var current_angle:float = original_quaternion.get_angle()
	var final_angle:float = final_quaternion.get_angle()
	print("Starting angle : ", current_angle)
	print("Target angle : ", final_angle)
	if current_angle > final_angle:
		pass
	else:
		pass
	return final_angle - current_angle
