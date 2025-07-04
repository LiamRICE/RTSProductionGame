class_name Vehicle extends Unit

@export var current_speed : float = 0 # m/s


func _ready():
	## Execute parent _ready function
	super._ready()
	
	self.current_speed = 0
	

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
	
	# rotate unit DEPRECATED
	# calculate remaining angle
	#var target_vector = self.next_point - self.target_position
	#if not target_vector.is_zero_approx():
		#var target_basis = self.global_basis.looking_at(target_vector)
		#var angle : float = self.quaternion.angle_to(target_basis.get_rotation_quaternion())
		#var rotation_speed:float = deg_to_rad(self.entity_statistics[STATS.TURN_RATE])
		## slerp with amount increasing to 1 as angle approaches zero
		##var weight : float = (delta / rotation_speed) / (angle + (delta / rotation_speed))
		#self.global_basis = self.global_basis.slerp(target_basis, ease(rotation_speed * delta, 2.0)).orthonormalized()
