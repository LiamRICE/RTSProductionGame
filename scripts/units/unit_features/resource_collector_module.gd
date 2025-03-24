class_name ResourceCollectorModule extends Node

const resource_utils:GDScript = preload("res://scripts/utilities/resource_utils.gd")

var resource:Dictionary = {
	"quantity":0,
	"type":resource_utils.Res.NONE,
	"node":null
}
var depot:Entity = null
@onready var parent:Unit = self.get_parent()

var resource_amount:int = 0
var resource_type:resource_utils.Res = resource_utils.Res.NONE
var gather_state:resource_utils.GatherState = resource_utils.GatherState.NONE

var counter = 1


func set_gathering_target(target:Resources, is_shift:bool = false):
	# set target as the navigation target
	self.resource.set("node", target)
	self.resource.set("type", target.resource_type)
	self.gather_state = self.resource_utils.GatherState.GATHERING
	self.parent.set_navigation_path(target.global_transform.origin, is_shift)


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



func manage_gathering(delta:float):
	if self.gather_state == self.resource_utils.GatherState.GATHERING:
		go_gathering(delta)
	elif self.gather_state == self.resource_utils.GatherState.DROPPING:
		go_drop_off(delta)


func go_gathering(delta:float):
	if self.resource.get("node") != null:
		var node:Resources = self.resource.get("node")
		var distance:float = node.global_transform.origin.distance_to(self.parent.global_transform.origin)
		if distance <= 1:
			var done:bool = self.gather(node.resource_type, self.parent.gather_speed, self.parent.max_res, self.parent.gather_amount, delta)
			# check if resource collection is finished
			if done:
				var target:Vector3 = self.get_closest_depot(self.parent.allegiance)
				# set depot as move target
				self.parent.set_navigation_path(target)
				self.gather_state = self.resource_utils.GatherState.DROPPING
		else:
			self.parent.move(delta)
	else:
		# node is null so resource is depleted
		# find nearest duplicate of that resource type
		var node:Vector3 = self.get_closest_resource_node_of_type(self.resource.get("type"))
		self.parent.set_navigation_path(self.parent.position)
		if self.resource.get("node") == null:
			self.gather_state = self.resource_utils.GatherState.NONE


func go_drop_off(delta:float):
	if self.depot != null:
		# if within range, drop off resources and trigger
		if self.depot.global_transform.origin.distance_to(self.parent.global_transform.origin) <= 1:
			self.depot.drop_off(self.resource.get("quantity"))
			self.resource.set("quantity", 0)
			self.gather_state = self.resource_utils.GatherState.GATHERING
			if self.resource.get("node") != null:
				self.parent.set_navigation_path(self.resource.get("node").global_transform.origin)
			else:
				var position:Vector3 = self.get_closest_resource_node_of_type(self.resource.get("type"))
				self.parent.set_navigation_path(position)
		else:
			# if target is selected, move to target
			self.parent.move(delta)
	else:
		# if null, then find closest depot
		var target:Vector3 = self.get_closest_depot(self.parent.allegiance)
		self.parent.set_navigation_path(target)
		if self.depot == null:
			self.gatherer.gather_state = self.gatherer.resource_utils.GatherState.NONE


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
		
