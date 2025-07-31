class_name GatherOrder extends Order

## Constants
const RESOURCE := preload("res://scripts/utilities/resource_utils.gd").RESOURCE

## Internal variables
var _target:Resources = null
var _gather_speed:float = 0
var _gather_amount:float = 0
var _max_amount:float = 0
var _resource_gathered:Dictionary[RESOURCE, int]
var _counter:float = 1

func _init(entity:Entity, queue_order:bool = false, target:Resources = null) -> void:
	super._init(entity, queue_order)
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
	elif self._target.is_queued_for_deletion():
		self._order_failed()
	
	if entity.global_position.distance_squared_to(self._target.global_position) < 1:
		self._gather_resource(self._target.resource_type, self._gather_speed, self._max_amount, self._gather_amount, delta)
	else:
		self._order_failed()

func _gather_resource(type:RESOURCE, gather_speed:float, resource_max:float, amount:float, delta:float) -> void:
	self._counter -= gather_speed * delta
	var ret:bool = false
	var exists:bool = true
	if self._counter <= 0:
		self._counter = 1
		## to collect all the amount without branching
		for i in range(roundi(amount)):
			exists = self._target.harvest(1)
			if exists:
				self._resource_gathered[type] += 1 ## Add one to the amount of that resource stored
			else:
				break
		print("Quanity of resource mined = ", self._resource_gathered)
		var sum:int = 0
		for val in self._resource_gathered.values():
			sum += val
		if sum >= self._max_amount:
			ret = true
	if not exists:
		self._order_failed() ## Exit out of this and search for a new resource to mine
	if ret:
		self._order_completed() ## Exit out of this and return to depot
