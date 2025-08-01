class_name DepositOrder extends Order

## Constants
const RESOURCE := preload("res://scripts/utilities/resource_utils.gd").RESOURCE

## Internal variables
var _target:DepotBuilding = null
var _resource_gathered:Dictionary[RESOURCE, int]


func _init(entity:Entity, queue_order:bool = false, operation:Operation = null, target:DepotBuilding = null) -> void:
	super._init(entity, queue_order, operation)
	self._target = target
	## Check target is available and close enough, else fail
	
	## Get the entity's stats
	self._gather_speed = entity.entity_statistics[entity.STATS.GATHER_SPEED]
	self._gather_amount = entity.entity_statistics[entity.STATS.GATHER_AMOUNT]
	self._max_amount = entity.entity_statistics[entity.STATS.MAX_RESOURCE]

func process(entity:Entity, delta:float) -> void:
	super.process(entity, delta)
	
	## Check target is still available
	if self._target == null:
		self._order_failed() ## Exit out of this and search for new resource to mine
	elif self._target.is_queued_for_deletion() or self._target.is_awaiting_deletion:
		self._order_failed()
	
	if entity.global_position.distance_squared_to(self._target.global_position) < 1:
		self._deposit_resources()
	else:
		self._order_failed()


func _deposit_resources() -> void:
	self._target.drop_off(self._resource_gathered)
	## Signal that the order was successfully completed
	self._order_completed()
	
