class_name MoveReverseOrder extends MoveOrder


func process(entity:Entity, delta:float) -> void:
	## Only abort if the EntityPathServer has finished processing the request
	if not self._has_received_path:
		return
	if self.should_abort:
		self.should_abort = false
		self.order_aborted.emit()
		return
	
	if self._is_new_path:
		self._is_new_path = false
		self._target_position = entity.global_position
		## Debug - TODO Maybe turn this into an effect
		EventBus.on_entity_move.emit(entity, self._path)
	
	""" UPDATE PATH """
	## Increment next path point if current point has been reached
	var has_arrived_at_destination:bool = false
	if self._target_position.is_equal_approx(self._next_point):
		self._path_index += 1
		if self._path_index >= self._path.size():
			self._path_index -= 1
			if entity.global_position.distance_squared_to(self._target_position) < self._path_point_margin:
				has_arrived_at_destination = true
		## Set the next point to navigate to
		self._next_point = self._path[self._path_index]
	
	""" POSITION """
	## Set movement speed for this frame
	var movement_delta : float = entity.entity_statistics[entity.STATS.SPEED] * delta / 3
	## Set unit velocity to the next path point
	self._target_position = self._target_position.move_toward(self._next_point, movement_delta)
	entity.global_position = entity.position_dynamics.update(delta, self._target_position)
	
	""" ROTATION """
	## Point unit towards the next path point
	var relative_target:Vector3 = self._next_point - entity.global_position
	if not relative_target.is_zero_approx():
		var target_quaternion = Quaternion(Basis.looking_at(-relative_target))
		entity.quaternion = entity.rotation_dynamics.update(delta, target_quaternion)
	
	if has_arrived_at_destination:
		self._order_completed()
