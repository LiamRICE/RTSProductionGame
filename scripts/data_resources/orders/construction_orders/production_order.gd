class_name ProductionOrder extends Order

## Constants
const RESOURCE := preload("uid://c4mlh3p0sd0vd").RESOURCE
const ENTITY_ID := preload("uid://dki6gr7rrru2p").ENTITY_ID

## Internal variables
var _produced_entity:ENTITY_ID = ENTITY_ID.DEFAULT
var _production_module:ProductionModule
var _has_just_started:bool = true
var _has_enough_resources:bool = false

func _init(entity:Entity, queue_order:bool = false, operation:Operation = null, entity_id:ENTITY_ID = ENTITY_ID.DEFAULT) -> void:
	super._init(entity, queue_order, operation)
	## Check the entity has a production module
	assert(entity.has_node("ProductionModule"), "Entity is missing a production module ! Entity can't build other entities without a production module.")
	self._produced_entity = entity_id
	self._production_module = entity.get_node("ProductionModule")

func process(entity:Entity, delta:float) -> void:
	super.process(entity, delta)
	
	if self._has_just_started:
		self._has_just_started = false
		EventBus.on_resource_spent.emit(EntityDatabase.get_production_cost(self._produced_entity), self._verification_callback)
		if self._has_enough_resources:
			self._start_production(entity)


""" PRODUCTION METHODS """

func get_produced_entity() -> ENTITY_ID:
	return self._produced_entity

## Starts the production of the unit at index 0 in the production queue
func _start_production(entity:Entity) -> void:
	print("Starting production with time ", EntityDatabase.get_production_time(self._produced_entity))
	self._production_module.is_producing = true
	self._production_module.production_timer.timeout.connect(self._on_production_timer_timeout)
	self._production_module.production_timer.start(EntityDatabase.get_production_time(self._produced_entity))

func _verification_callback(is_possible:bool) -> void:
	if not is_possible:
		print("Not enough resources to buy ", EntityDatabase.get_entity_name(self._produced_entity), "!")
		self._order_failed()
	self._has_enough_resources = is_possible

## Called when the timer for the unit production is completed
func _on_production_timer_timeout():
	print("Production complete.")
	## New unit to instantiate
	var new_entity:Entity = EntityDatabase.get_entity(self._produced_entity).instantiate()
	new_entity.allegiance = self._production_module.get_parent().allegiance
	## Update the production module's state and emit the signal from the event bus to spawn the new entity
	self._production_module.is_producing = false
	EventBus.on_entity_produced.emit(new_entity, self._production_module.unit_spawn_point.global_position, self._production_module.rally_point.global_position)
