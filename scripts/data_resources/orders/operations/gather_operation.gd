## An order object which moves a unit to a specified gather location and object and starts the gathering operations there.
class_name GatherOperation extends Operation

## Constants
const RESOURCE := preload("res://scripts/utilities/resource_utils.gd").RESOURCE

## Internal variables
var _target:Resources


func _init(entity:Entity, queue_order:bool = false, operation:Operation = null, target:Resources = null) -> void:
	super._init(entity, queue_order, operation)

func process(entity:Entity, delta:float) -> void:
	## Check if a target was given.
	assert(self._target != null)
	
	## If not close enough, queue order to move to the target and gather from it
	
	## If close enough, queue order to gather from the target
	
	## If target no longer available on route (move failed), reroute to next closest and gather from it
	
	## While gathering, if target no longer available (gather failed), reroute to next closest and gather from it
	
	## If resource storage full (gather successful), give move command to depot, depot dropoff, check the target is still present
	
	## If target is still present loop back to top
	
	## If target no longer exists, find nearest resource node of the same type and queue order to go there
	
	## If no resource of the same type exists, fail the operation


""" HELPER METHODS """

## Returns a pointer to the closest (euclidian distance) Depot object to this entity
func _get_closest_depot(entity:Entity) -> DepotBuilding:
	var depots:Array = entity.get_tree().get_nodes_in_group("depot")
	var closest:Building = null
	var dist:float = -1
	# find closest depot
	for d in depots:
		if d.allegiance == entity.allegiance:
			var distance:float = entity.global_position.distance_squared_to(d.global_position)
			if closest == null or distance < dist:
				dist = distance
				closest = d
	if closest != null:
		## Return the found depot variable
		print("Closest Depot found at ", closest.global_transform.origin)
		return closest
	else:
		## Return no depot found
		print("No depot found")
		return null

## Returns a pointer to the closest (euclidian distance) Resources object to this entity
func _get_closest_resource_node_of_type(entity:Entity, type:RESOURCE) -> Resources:
	var resources:Array = entity.get_tree().get_nodes_in_group("resource")
	# search all resources
	var closest:Resources = null
	var dist:float = -1
	for r in resources:
		## Only calculate the distance to it if it is the correct resource type
		if r.resource_type == type:
			var distance:float = entity.global_position.distance_squared_to(r.global_position)
			if closest == null or distance < dist:
				closest = r
				dist = distance
	if closest != null:
		print("Closest Resource found at ", closest.global_transform.origin)
		return closest
	else:
		return null
