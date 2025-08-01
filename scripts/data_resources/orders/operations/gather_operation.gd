## An order object which moves a unit to a specified gather location and object and starts the gathering operations there.
class_name GatherOperation extends Operation

## Constants
const RESOURCE := preload("uid://c4mlh3p0sd0vd").RESOURCE
enum GATHER_STATE {
	GATHERING,
	DROPPING
}

## Internal variables
var _resource_target:Resources
var _resource_type_target:RESOURCE
var _resources_gathered:Dictionary[RESOURCE, int]
var _state:GATHER_STATE = GATHER_STATE.GATHERING


func _init(entity:Entity, queue_order:bool = false, operation:Operation = null, target:Resources = null) -> void:
	super._init(entity, queue_order, operation)
	## Add the necessary info to this node
	self._resource_target = target
	self._resource_type_target = target.resource_type
	## Create the order to move to the resource
	var move:MoveOrder = MoveOrder.new(entity, false, self, target.global_position)
	self.add_order(move, false)
	var gather:GatherOrder = GatherOrder.new(entity, true, self, target)
	self.add_order(gather, true)

func process(entity:Entity, delta:float) -> void:
	super.process(entity, delta)
	## Check if a target was given.
	
	## If not close enough, queue order to move to the target and gather from it
	
	## If close enough, queue order to gather from the target
	
	## If target no longer available on route (move failed), reroute to next closest and gather from it
	
	## While gathering, if target no longer available (gather failed), reroute to next closest and gather from it
	if self._state == GATHER_STATE.GATHERING and self._active_order == null:
		## Find next closest resource node and go mine from it
		var closest_resource_node:Resources = _get_closest_resource_node_of_type(self._entity, self._resource_type_target)
		if closest_resource_node == null:
			print("No more resources to mine. Gathering operation halted.")
			self._order_failed()
			return
		var move:MoveOrder = MoveOrder.new(self._entity, false, self, closest_resource_node.global_position)
		self.add_order(move, false)
		var gather:GatherOrder = GatherOrder.new(self._entity, true, self, closest_resource_node)
		self.add_order(gather, true)
	
	## If resource storage full (gather successful), give move command to depot, depot dropoff, check the target is still present
	if self._state == GATHER_STATE.DROPPING and self._active_order == null:
		## Depot probably got destroyed during trip, search for new depot to deposit at
		var closest_depot:Entity = _get_closest_depot(self._entity)
		if closest_depot == null:
			print("No depots to deliver to. Gathering operation halted.")
			self._order_failed()
			return
		var move:MoveOrder = MoveOrder.new(self._entity, false, self, closest_depot.global_position)
		self.add_order(move, false)
		var deposit:DepositOrder = DepositOrder.new(self._entity, true, self, closest_depot)
		self.add_order(deposit, true)
	
	## If target is still present loop back to top
	
	## If target no longer exists, find nearest resource node of the same type and queue order to go there
	
	## If no resource of the same type exists, fail the operation


""" SIGNAL RECEIVING FUNCTIONS """

## Called when the current order aborts. This is usually because another order has received priority from the queue.
func _on_order_aborted() -> void:
	self._active_order = self._order_queue.pop_front()
	if self._active_order == null:
		self.abort()
		Script

## Called when the current order has been completed. The entity pops the next order from the queue or goes to it's idle order.
func _on_order_completed() -> void:
	if self._active_order is GatherOrder:
		print("Gathering completed")
		self._state = GATHER_STATE.DROPPING
	elif self._active_order is DepositOrder:
		print("Depositing completed")
		self._state = GATHER_STATE.GATHERING
	self._active_order = self._order_queue.pop_front()

## Called when the current order fails. The entity then pops the next order from the queue or goes to it's idle order.
func _on_order_failed() -> void:
	if self._active_order is GatherOrder:
		print("Gathering order failed")
	if self._active_order is DepositOrder:
		print("Depositing order failed")
	self._active_order = self._order_queue.pop_front()


""" HELPER METHODS """

## Returns a pointer to the closest (euclidian distance) Depot object to this entity
func _get_closest_depot(entity:Entity) -> Entity:
	var depots:Array = entity.get_tree().get_nodes_in_group("depot")
	var closest:Building = null
	var dist:float = -1
	# find closest depot
	for d in depots:
		if d.allegiance == entity.allegiance:
			var distance:float = entity.global_position.distance_squared_to(d.global_position)
			if closest == null or distance < dist:
				dist = distance
				closest = d
	if closest != null:
		## Return the found depot variable
		print("Closest Depot found at ", closest.global_transform.origin)
		return closest
	else:
		## Return no depot found
		print("No depot found")
		return null

## Returns a pointer to the closest (euclidian distance) Resources object to this entity
func _get_closest_resource_node_of_type(entity:Entity, type:RESOURCE) -> Resources:
	var resources:Array = entity.get_tree().get_nodes_in_group("resource")
	# search all resources
	var closest:Resources = null
	var dist:float = -1
	for r in resources:
		## Only calculate the distance to it if it is the correct resource type
		if r.resource_type == type:
			var distance:float = entity.global_position.distance_squared_to(r.global_position)
			if closest == null or distance < dist:
				closest = r
				dist = distance
	if closest != null:
		print("Closest Resource found at ", closest.global_transform.origin)
		return closest
	else:
		return null
