class_name GatherOrder extends Order

## Constants
const RESOURCE := preload("uid://c4mlh3p0sd0vd").RESOURCE

## Internal variables
var _target:Resources = null
var _gather_speed:float = 0
var _gather_amount:float = 0
var _max_amount:float = 0
var _counter:float = 1

func _init(entity:Entity, queue_order:bool = false, operation:Operation = null, target:Resources = null) -> void:
	assert(entity.has_node("InventoryModule"), "Gather order started on entity that doesn't have an inventory !")
	super._init(entity, queue_order, operation)
	self._target = target
	## Get the entity's stats
	self._gather_speed = entity.entity_statistics[entity.STATS.GATHER_SPEED]
	self._gather_amount = entity.entity_statistics[entity.STATS.GATHER_AMOUNT]
	self._max_amount = entity.entity_statistics[entity.STATS.MAX_RESOURCE]

func process(entity:Entity, delta:float) -> void:
	super.process(entity, delta)
	
	## Check target is still available
	if self._target == null:
		self._order_failed() ## Exit out of this and search for new resource to mine
		return
	elif self._target.is_queued_for_deletion() or self._target.is_awaiting_deletion:
		self._order_failed()
		return
	
	if entity.global_position.distance_squared_to(self._target.global_position) < 1:
		self._gather_resource(entity, self._target.resource_type, delta)
	else:
		self._order_failed()

func _gather_resource(entity:Entity, type:RESOURCE, delta:float) -> void:
	self._counter -= self._gather_speed * delta
	var ret:bool = false
	var exists:bool = true
	if self._counter <= 0:
		self._counter = 1
		## to collect all the amount without branching
		for i in range(roundi(self._gather_amount)):
			exists = self._target.harvest(1)
			ret = entity.inventory_module.store(type, 1)
			if not exists:
				break
		print("Quanity of resource mined = ", entity.inventory_module._current_inventory)
	if ret:
		self._order_completed() ## Exit out of this and return to depot
	if not exists:
		self._order_failed() ## Exit out of this and search for a new resource to mine
