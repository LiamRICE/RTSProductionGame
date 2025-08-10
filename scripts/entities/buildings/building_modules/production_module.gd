class_name ProductionModule extends Node

## Constants
const ENTITY_ID := preload("uid://dki6gr7rrru2p").ENTITY_ID

## Production building nodes
@export var building_entities:Array[ENTITY_ID]
var production_timer:Timer
@export var unit_spawn_point:Marker3D
@export var rally_point:Marker3D


## Production building internal parameters
var production_queue:Array[ENTITY_ID]
var is_producing:bool = false

func _ready() -> void:
	self.production_timer = Timer.new()
	self.production_timer.one_shot = true
	self.add_child(self.production_timer)

""" ENTITY PRODUCTION QUEUE METHODS """

func get_production_percentage() -> float:
	if self.is_producing:
		var e_id:ENTITY_ID = self.production_queue[0]
		return 1 - self.production_timer.time_left / EntityDatabase.get_production_time(e_id)
	return 0

func get_production_queue() -> Array[ENTITY_ID]:
	var queue:Array[ENTITY_ID]
	for order in self.get_parent().order_queue:
		if order is ProductionOrder:
			queue.push_back(order.get_produced_entity())
	return queue
