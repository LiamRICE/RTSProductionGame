class_name Order extends RefCounted

## Signals
signal order_completed
signal order_failed
signal order_aborted

## Internal variables
var should_abort:bool = false

## Virtual function to call when starting the order.
func _init(entity:Entity, _queue_order:bool = false, operation:Operation = null) -> void:
	## Add order signal connections
	if operation == null:
		self.order_aborted.connect(entity._order_aborted)
		self.order_completed.connect(entity._order_completed)
		self.order_failed.connect(entity._order_failed)
	else:
		self.order_aborted.connect(operation._order_aborted)
		self.order_completed.connect(operation._order_completed)
		self.order_failed.connect(operation._order_failed)

## Runs the logic for the order every physics frame. Must stop the process when should_abort is true.
func process(_entity:Entity, _delta:float) -> void:
	if self.should_abort:
		self.should_abort = false
		self.order_aborted.emit()
		return

## Virtual function to call when stopping the order. Returns whether the unit can abort it's current order.
func abort() -> bool:
	self.should_abort = true
	return true

## Called when the order is completed. Fires a signal to the listening unit to have it's next order in the queue executed.
func _order_completed() -> void:
	self.order_completed.emit()

## Called when an order is aborted automatically (not called abort() ) if the conditions of the order are no longer true.
func _order_failed() -> void:
	self.order_failed.emit()

func _to_string() -> String:
	return "Order N°" + str(self.get_instance_id())
