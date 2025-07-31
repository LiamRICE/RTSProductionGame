## An order object which moves a unit to a specified gather location and object and starts the gathering operations there.
class_name GatherOrder extends Order


func _init(entity:Entity, queue_order:bool = false, target:Resources = null) -> void:
	super._init(entity, queue_order)
	
	## Check what gather state the gatherer is in. If the gatherer is 
