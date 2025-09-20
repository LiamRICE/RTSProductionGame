class_name EntityResource extends Resource

## Imports
const RESOURCE := preload("uid://c4mlh3p0sd0vd").RESOURCE
const STATS := preload("uid://dki6gr7rrru2p").STATS
const TYPE := preload("uid://dki6gr7rrru2p").TYPE

## Properties
@export_group("Statistics")
@export var entity_statistics:Dictionary[STATS, Variant] = {
	STATS.HEALTH : 0,
	STATS.SHIELD : 0,
	STATS.ARMOUR : 0,
	STATS.VIEW_DISTANCE : 0,
	STATS.SPEED : 0,
	STATS.ACCELERATION : 0,
	STATS.TURN_RATE : 0,
}
@export var unit_type:TYPE

@export_group("Properties")
@export var production_cost:Dictionary[RESOURCE, float]
@export var production_time:float

## Additional info
@export_group("UI variables")
@export var name:String
@export var ui_icon:Texture2D
@export_multiline var ui_description:String
@export_multiline var ui_tooltip:String
