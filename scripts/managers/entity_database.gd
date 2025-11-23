extends Node

## Constants
const RESOURCE := preload("uid://c4mlh3p0sd0vd").RESOURCE
const ENTITY_ID := preload("uid://dki6gr7rrru2p").ENTITY_ID
const STATS := preload("uid://dki6gr7rrru2p").STATS
const TYPE := preload("uid://dki6gr7rrru2p").TYPE

## Database
@export var entity_db:Dictionary[ENTITY_ID, DataRef]
@export var move_orders:Array[OrderData]

""" DATABASE METHODS """

func get_entity(id:ENTITY_ID) -> PackedScene:
	return entity_db[id].scene

func get_resource(id:ENTITY_ID) -> EntityResource:
	return entity_db[id].resource

func get_stats(id:ENTITY_ID) -> Dictionary[STATS, Variant]:
	return entity_db[id].resource.entity_statistics.duplicate()

func get_entity_name(id:ENTITY_ID) -> String:
	return entity_db[id].resource.name

func get_entity_type(id:ENTITY_ID) -> TYPE:
	return entity_db[id].resource.unit_type

## Returns a dictionary containing the amount of each resource it costs the build the queried entity.
func get_production_cost(id:ENTITY_ID) -> Dictionary[RESOURCE, float]:
	return entity_db[id].resource.production_cost.duplicate()

func get_production_time(id:ENTITY_ID) -> float:
	return entity_db[id].resource.production_time

func get_entity_armament(id:ENTITY_ID) -> ArmyEquipmentResource:
	return entity_db[id].resource.unit_equipment_resource

## Returns the ui info for the given entity_id in an array in the following format : name, description, tooltip, icon
func get_ui_info(id:ENTITY_ID) -> Array:
	var ref:DataRef = entity_db[id]
	return [ref.resource.name, ref.resource.ui_description, ref.resource.ui_tooltip, ref.resource.ui_icon]

## Returns the script of the order at the index supplied
func get_move_order(index:int) -> OrderData:
	return self.move_orders[index]
