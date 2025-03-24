class_name ResourceCollectorModule extends Node

const resource_utils:GDScript = preload("res://scripts/utilities/resource_utils.gd")

var resource:Dictionary = {
	"quantity":0,
	"type":resource_utils.Res.NONE,
	"node":null
}
var depot:Entity = null

var resource_amount:int = 0
var resource_type:resource_utils.Res = resource_utils.Res.NONE
var gather_state:resource_utils.GatherState = resource_utils.GatherState.NONE

var counter = 1


func gather(res:resource_utils.Res, gather_speed:float, max:int, amount:int, delta:float) -> bool:
	counter -= gather_speed * delta
	if resource.get("type") != res:
		resource.set("type", res)
	var ret:bool = false
	var exists = true
	if counter <= 0:
		counter = 1
		# to collect all the amount without branching
		for i in range(0, amount):
			exists = resource.get("node").harvest(1)
			resource.set("quantity", resource.get("quantity") + 1)
		print("Quanity of resource mined = ",resource.get("quantity"))
		if resource.get("quantity") >= max:
			ret = true
	if not exists:
		resource.set("node", null)
	return ret


func drop_off():
	resource.set("quantity", 0)
	resource.set("type", resource_utils.Res.NONE)
	# add resource to player's stockpiles


func get_closest_depot(allegiance:int) -> Vector3:
	var parent:Node3D = self.get_parent()
	var depots:Array = get_tree().get_nodes_in_group("depot")
	var closest:DepotBuilding = null
	var dist:float = -1
	# find closest depot
	for depot in depots:
		if depot.allegiance == allegiance:
			var distance:float = parent.global_transform.origin.distance_to(depot.global_transform.origin)
			if closest == null or distance < dist:
				dist = distance
				closest = depot
	if closest != null:
		# assign it in the depot variable
		self.depot = closest
		# return the position of the depot
		return closest.global_transform.origin
	else:
		self.gather_state == resource_utils.GatherState.NONE
		return parent.global_transform.origin


func get_closest_resource_node_of_type(res:resource_utils.Res) -> Vector3:
	var resources:Array = get_tree().get_nodes_in_group("resource")
	var resource_type:resource_utils.Res = resource.get("type")
	var parent:Node3D = self.get_parent()
	# search all resources
	var closest:Resources = null
	var dist:float = -1
	for r in resources:
		var distance:float = parent.global_transform.origin.distance_to(r.global_transform.origin)
		if closest == null or distance < dist:
			closest = r
			dist = distance
	if closest != null:
		resource.set("node", closest)
		return closest.global_transform.origin
	else:
		self.gather_state == resource_utils.GatherState.NONE
		return parent.global_transform.origin
		
