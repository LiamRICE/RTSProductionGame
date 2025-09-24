class_name AttackMoveOrder extends MoveOrder

## Internal variables
var _current_speed:float = 0
var _enemies_in_range : Array[Entity] = []

func _init(entity:Entity, queue_order:bool = false, operation:Operation = null, location:Vector3 = Vector3.INF) -> void:
	super._init(entity, queue_order, operation, location)
	# self._request_path_async(entity, queue_order, location)
	print("Initialised attack move order")

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
	
	## Trigger movment
	self._enemies_in_range = entity.get_node("ArmyEquipment").get_enemies_in_range()
	if len(self._enemies_in_range) > 0:
		self._stop(entity, delta)
	else:
		self._move(entity, delta, has_arrived_at_destination)

# Moves the unit along the calculated path
func _move(entity:Entity, delta:float, has_arrived_at_destination:bool):
	""" POSITION """
	## Set movement speed for this frame
	var movement_delta : float = entity.entity_statistics[entity.STATS.SPEED] * delta
	## Set unit velocity to the next path point
	self._target_position = self._target_position.move_toward(self._next_point, movement_delta)
	entity.global_position = entity.position_dynamics.update(delta, self._target_position)
	
	""" ROTATION """
	## Point unit towards the next path point
	var relative_target:Vector3 = self._next_point - entity.global_position
	if not relative_target.is_zero_approx():
		var target_quaternion = Quaternion(Basis.looking_at(relative_target))
		entity.quaternion = entity.rotation_dynamics.update(delta, target_quaternion)
	
	if has_arrived_at_destination:
		self._order_completed()

# Stops the unit as quickly as possible
func _stop(entity:Entity, delta:float):
	if self._current_speed > 0:
		self._current_speed -= 1
		if self._current_speed < 0:
			self._current_speed = 0
		else:
			## Set movement speed for this frame
			var movement_delta : float = self._current_speed * delta
			self._target_position = self._target_position.move_toward(self._next_point, movement_delta)
			entity.global_position = entity.position_dynamics.update(delta, self._target_position)

## Calls the EntityNavigationServer and queues a path request
func _request_path_async(entity:Entity, queue_order:bool, location:Vector3) -> void:
	var start:Vector3 = entity.global_position
	if queue_order:
		var order:Order
		if entity.order_queue.size() > 0:
			for i in range(entity.order_queue.size()-1, -1, -1):
				order = entity.order_queue[i]
				if order is MoveOrder:
					start = order._path[order._path.size() - 1]
					break
		elif entity.active_order is MoveOrder:
			start = entity.active_order._path[entity.active_order._path.size() - 1]
	## Query the entity navigation server
	print("Requesting path...")
	EntityNavigationServer.request_path(self, start, location)

## Called when the path is received back from the EntityNavigationServer
func _path_received(path:PackedVector3Array) -> void:
	## Check path has data (paths generated before Navmesh sync can be empty as can 0 distance paths)
	print("Path received : ", path)
	if path.is_empty():
		self._order_failed()
		return
	self._path = path
	self._path_index = 1
	self._next_point = self._path[1]
	## Inform the update loop that it has received data
	self._has_received_path = true
	self._is_new_path = true


## Called when the order is completed. Fires a signal to the listening unit to have it's next order in the queue executed.
func _order_completed() -> void:
	print("Attack Move Order completed")
	self.order_completed.emit()

## Called when an order is aborted automatically (not called abort() ) if the conditions of the order are no longer true.
func _order_failed() -> void:
	print("Attack Move Order failed")
	self.order_failed.emit()


func _to_string() -> String:
	return "Move Order " + str(self._path)
