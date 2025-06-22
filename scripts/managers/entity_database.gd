extends Node

## Constants
const RESOURCE := preload("uid://c4mlh3p0sd0vd").RESOURCE
const ENTITY_ID := preload("uid://dki6gr7rrru2p").ENTITY_ID
const STATS := preload("uid://dki6gr7rrru2p").STATS

## Database
@export var db:Dictionary[ENTITY_ID, DataRef]

""" DATABASE METHODS """

func get_entity(id:ENTITY_ID) -> PackedScene:
	return db[id].scene

func get_resource(id:ENTITY_ID) -> EntityResource:
	return db[id].resource

func get_stats(id:ENTITY_ID) -> Dictionary[STATS, float]:
	return db[id].resource.entity_statistics.duplicate()

func get_entity_name(id:ENTITY_ID) -> String:
	return db[id].resource.name

func get_production_cost(id:ENTITY_ID) -> Dictionary[RESOURCE, float]:
	return db[id].resource.production_cost.duplicate()

func get_production_time(id:ENTITY_ID) -> float:
	return db[id].resource.production_time

func get_ui_info(id:ENTITY_ID) -> Array:
	var ref:DataRef = db[id]
	return [ref.resource.name, ref.resource.ui_description, ref.resource.ui_tooltip, ref.resource.ui_icon]
