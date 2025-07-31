class_name MoveOrder extends Order

## Internal variables
var _path:PackedVector3Array
var _has_received_path:bool = false
var _is_new_path:bool = false
var _next_point : Vector3
var _target_position:Vector3
var _path_index : int = 0
var _path_point_margin : float = 0.1

func execute(entity:Entity, queue_order:bool, location:Vector3 = Vector3.INF) -> void:
	self._request_path_async(entity, queue_order, location)

func process(entity:Entity, delta:float) -> void:
	## Only abort if the EntityPathServer has finished processing the request
	if not self._has_received_path:
		return
	super.process(entity, delta)
	
	if self._is_new_path:
		self._is_new_path = false
		self._target_position = entity.global_position
		## Debug - TODO Maybe turn this into an effect
		EventBus.on_entity_move.emit(entity, self._path)
	
	## Check if path is empty, stop moving
	if entity.global_position.is_equal_approx(self._target_position) and self._path.is_empty():
		self._order_completed()
		return
	
	""" UPDATE PATH """
	## Increment next path point if current point has been reached
	if self._target_position.distance_to(self._next_point) <= self._path_point_margin:
		self._path_index += 1
		if self._path_index >= self._path.size():
			self._path.clear()
			self._path_index = 0
	## Set the next point to navigate to
	if self._path.is_empty():
		self._next_point = self._target_position
	else:
		self._next_point = self._path[self._path_index]
	
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

## Calls the EntityNavigationServer and queues a path request
func _request_path_async(entity:Entity, queue_order:bool, location:Vector3) -> void:
	var start:Vector3
	if queue_order:
		var order:Order
		for i in range(0, entity.order_queue.size(), -1):
			order = entity.order_queue[i]
			if order is MoveOrder:
				start = order._path[order._path.size() - 1]
				break
	else:
		start = entity.global_position
	## Query the entity navigation server
	EntityNavigationServer.request_path(self, start, location)

## Called when the path is received back from the EntityNavigationServer
func _path_received(path: PackedVector3Array) -> void:
	## Check path has data (paths generated before Navmesh sync can be empty as can 0 distance paths)
	if path.is_empty():
		self._order_failed()
		return
	self._path = path
	self._path_index = 1
	self._next_point = self._path[1]
	## Inform the update loop that it has received data
	self._has_received_path = true
	self._is_new_path = true
	
	print(self)


func _to_string() -> String:
	return "Move Order along " + str(self._path)
