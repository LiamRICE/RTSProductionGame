class_name AttackMoveOperation extends Operation

enum AttackMoveState{
	MOVING,
	ATTACKING,
}

# internal variables
var _target_position : Vector3
var _enemies_in_range : Array[Entity] = []
var _state : AttackMoveState = AttackMoveState.MOVING

""" OPERATION FUNCTIONS """

func _init(entity:Entity, queue_order:bool = false, operation:Operation = null, target:Vector3 = Vector3.ZERO) -> void:
	super._init(entity, queue_order, operation)
	self._target_position = target
	## Create the order to move to the target location
	# create the order to move to the location
	var move:MoveOrder = MoveOrder.new(entity, false, self, target)
	self.add_order(move, false)


func process(entity:Entity, delta:float) -> void:
	super.process(entity, delta)
	
	if self._state == AttackMoveState.MOVING and self._active_order == null:
		# Check number of enemies in range
		self._enemies_in_range = entity.get_node("WeaponModule").get_enemies_in_range()
		if len(self._enemies_in_range) > 0:
			# Enemies in range - begin attacking
			self._state = AttackMoveState.ATTACKING
		else:
			## Create the order to move to the target location
			var move:MoveOrder = MoveOrder.new(entity, false, self, self._target_position)
			self.add_order(move, false)
	elif self._state == AttackMoveState.MOVING:
		# Check number of enemies in range
		self._enemies_in_range = entity.get_node("WeaponModule").get_enemies_in_range()
		if len(self._enemies_in_range) > 0:
			print("Enemy found !")
			# Enemies in range - begin attacking
			self._state = AttackMoveState.ATTACKING
		
	
	if self._state == AttackMoveState.ATTACKING and self._active_order == null:
		print("Engaging target")
		pass
	elif self._state == AttackMoveState.ATTACKING:
		print("Shooting...")
	



""" SIGNAL RECEIVING FUNCTIONS """

## Called when the current order aborts. This is usually because another order has received priority from the queue.
func _on_order_aborted() -> void:
	self._active_order = self._order_queue.pop_front()
	if self._active_order == null:
		self.abort()

## Called when the current order has been completed. The entity pops the next order from the queue or goes to it's idle order.
func _on_order_completed() -> void:
	if self._active_order is MoveOrder:
		print("Movement completed")
		
		# self._state = GATHER_STATE.DROPPING
	elif self._active_order is DepositOrder:
		print("Depositing completed")
		# self._state = GATHER_STATE.GATHERING
	self._active_order = self._order_queue.pop_front()

## Called when the current order fails. The entity then pops the next order from the queue or goes to it's idle order.
func _on_order_failed() -> void:
	if self._active_order is MoveOrder:
		print("Movement order failed")
	#if self._active_order is AttackOrder:
		#print("Attack order failed")
	self._active_order = self._order_queue.pop_front()
