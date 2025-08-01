class_name Operation extends Order


var _order_queue:Array[Order] = []
var _active_order:Order = null

func _init(entity:Entity, queue_order:bool = false, operation:Operation = null) -> void:
	super._init(entity, queue_order, operation)
	## Start order queue. Order queue must be populated before process starts.
	## Pass the operation to the entity otherwise it will queue based on the last orders in the entity's orders queue.
	## For example : var move:MoveOrder = MoveOrder.new(entity, queue_order, self, Vector3.FORWARD)

## Handle transitions between order in the queue
func process(entity:Entity, delta:float) -> void:
	super.process(entity, delta)
	
	self.active


""" QUEUE MANAGEMENT METHODS """
## These methods should be overwritten in inheriting operations to handle order transitions

## Adds the defined order to this operation. The is_queued flag determines if the order should be appended to the end of the order queue or executed immediately.
func add_order(order:Order, is_queued:bool = false) -> void:
	## Add order to queue or overwrite queue with new order
	if is_queued:
		self._order_queue.push_back(order)
	else:
		self._order_queue.resize(1)
		self._order_queue[0] = order
		self._active_order.abort()

## Called when the current order aborts. This is usually because another order has received priority from the queue.
func _order_aborted() -> void:
	self._active_order = self._order_queue.pop_front()

## Called when the current order has been completed. The entity pops the next order from the queue or goes to it's idle order.
func _order_completed() -> void:
	self._active_order = self._order_queue.pop_front()

## Called when the current order fails. The entity then pops the next order from the queue or goes to it's idle order.
func _order_failed() -> void:
	self._active_order = self._order_queue.pop_front()
