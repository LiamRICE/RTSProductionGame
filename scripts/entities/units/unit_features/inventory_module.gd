class_name InventoryModule extends Node

## Constants
const RESOURCE := preload("uid://c4mlh3p0sd0vd").RESOURCE

## Properties
@export var logistics_orders:Array[OrderData]

## Internal variables
var _current_inventory:Dictionary[RESOURCE, int] = {}
var _current_inventory_count:int = 0
var _max_inventory:int = 0


func _ready() -> void:
	self._max_inventory = EntityDatabase.get_stats(self.get_parent().entity_id)[Entity.STATS.MAX_RESOURCE]

## Adds the specified resource in the specified quantity to the inventory of the entity.
## Returns true if the storage of this inventory is full.
func store(type:RESOURCE, amount:int) -> bool:
	self._current_inventory_count += amount
	if self._current_inventory.has(type):
		self._current_inventory[type] += amount
	else:
		self._current_inventory[type] = amount
	## Check if total stored items exceeds storage
	if self._current_inventory_count >= self._max_inventory:
		return true
	return false

## Removes the specified resources from this inventory. Returns true if the amount removed is contained within this inventory.
func spend(amount:Dictionary[RESOURCE, int]) -> bool:
	return true

## Removes and returns all resources in the inventory
func deliver() -> Dictionary[RESOURCE, int]:
	self._current_inventory_count = 0
	var returned_inventory:Dictionary[RESOURCE, int] = self._current_inventory.duplicate()
	self._current_inventory.clear()
	return returned_inventory

func get_current_resource_target() -> RESOURCE:
	return self._current_resource_target
