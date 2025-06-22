class_name Resources extends Entity

const resource_utils:GDScript = preload("uid://c4mlh3p0sd0vd")


@export var resource_type:resource_utils.Res
@export var resource_amount:int


func harvest(amount:int) -> bool:
	resource_amount -= amount
	if resource_amount <= 0:
		queue_free()
		return false
	else:
		return true
