## An order object which moves a unit to a specified gather location and object and starts the gathering operations there.
class_name GatherOperation extends Operation


## Internal variables
var target:Resources


func _init(entity:Entity, queue_order:bool = false, target:Resources = null) -> void:
	super._init(entity, queue_order)

func process(entity:Entity, delta:float) -> void:
	## Check if a target was given.
	assert(target != null)
	
	## If not close enough, queue order to move to the target and gather from it
	
	## If close enough, queue order to gather from the target
	
	## If target no longer available on route (move failed), reroute to next closest and gather from it
	
	## While gathering, if target no longer available (gather failed), reroute to next closest and gather from it
	
	## If resource storage full (gather successful), give move command to depot, depot dropoff, check the target is still present
	
	## If target is still present loop back to top
	
	## If target no longer exists, find nearest resource node of the same type and queue order to go there
	
	## If no resource of the same type exists, fail the operation
