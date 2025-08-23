extends Node

## Constants
const RESOURCE := preload("res://scripts/utilities/resource_utils.gd").RESOURCE


func drop_off(amount:Dictionary[RESOURCE, int]):
	print("Units dropped off ", amount.values(), " of type ", amount.keys())
	for type in amount:
		EventBus.on_resource_deposited.emit(amount)
