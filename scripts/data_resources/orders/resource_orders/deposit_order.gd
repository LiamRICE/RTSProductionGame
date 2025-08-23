class_name DepositOrder extends Order

## Constants
const RESOURCE := preload("uid://c4mlh3p0sd0vd").RESOURCE

## Internal variables
var _target:Entity = null


func _init(entity:Entity, queue_order:bool = false, operation:Operation = null, target:Entity = null) -> void:
	super._init(entity, queue_order, operation)
	assert(target.has_node("DepotModule"))
	self._target = target

func process(entity:Entity, delta:float) -> void:
	super.process(entity, delta)
	
	## Check target is still available
	if self._target == null:
		self._order_failed() ## Exit out of this and search for new resource to mine
		return
	elif self._target.is_queued_for_deletion() or self._target.is_awaiting_deletion:
		self._order_failed()
		return
	
	if entity.global_position.distance_squared_to(self._target.global_position) < 4:
		self._deposit_resources(entity)
	else:
		self._order_failed()


func _deposit_resources(entity:Entity) -> void:
	entity = entity as ResourceCollectorUnit
	self._target.get_node("DepotModule").drop_off(entity.inventory_module.deliver())
	## Signal that the order was successfully completed
	self._order_completed()
	
