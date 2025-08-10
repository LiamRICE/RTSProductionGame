class_name Resources extends Entity

## Properties
@export var navigation_obstacle:NavigationObstacle3D
@export var resource_type:RESOURCE
@export var resource_amount:int


func harvest(amount:int) -> bool:
	resource_amount -= amount
	if resource_amount <= 0:
		self._on_destroyed()
		return false
	else:
		return true
