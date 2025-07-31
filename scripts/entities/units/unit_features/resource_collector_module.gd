class_name ResourceCollectorModule extends Node

const RESOURCE := preload("res://scripts/utilities/resource_utils.gd").RESOURCE
const GATHER_STATE := preload("res://scripts/utilities/resource_utils.gd").GATHER_STATE

@export var resource:Dictionary = {
	"quantity":0,
	"type":RESOURCE.NONE,
	"node":null
}
@export var depot:Building = null
@onready var parent:Unit = self.get_parent()

var resource_amount:int = 0
var resource_type:RESOURCE = RESOURCE.NONE
var gather_state:GATHER_STATE = GATHER_STATE.NONE

var counter = 1


# When resource node is depleted, but resource not full, try to find other resource node nearby.
# When going to get resource node and node is depleted, try to find other resource node nearby.

func manage_gathering(delta:float):
	# print("Gather state = ", self.gather_state)
	match self.gather_state:
		GATHER_STATE.NONE:
			## Move
			self.parent.move(delta)
		GATHER_STATE.GATHERING:
			## Go gathering
			self.go_gathering(delta)
		GATHER_STATE.DROPPING:
			## Go to drop off point
			self.go_drop_off(delta)


func set_gathering_target(target:Resources, is_shift:bool = false):
	# set target as the navigation target
	print(target.resource_type)
	self.resource.set("node", target)
	self.resource.set("type", target.resource_type)
	self.gather_state = GATHER_STATE.GATHERING
	#self.parent.set_navigation_path(target.global_transform.origin, is_shift)


func gather(res:RESOURCE, gather_speed:float, resource_max:int, amount:int, delta:float) -> bool:
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
		if resource.get("quantity") >= resource_max:
			ret = true
	if not exists:
		resource.set("node", null)
	return ret


func check_node_exists() -> bool:
	# check if resource is not null
	if self.resource.get("node") != null:
		# if it is not null, check if there are resources
		if self.resource.get("node").resource_amount <= 0:
			# if there are no resources, the node is depleted and should be set to null
			self.resource.set("node", null)
			return false
		else:
			return true
	else:
		return false


func go_gathering(delta:float):
	# check and set resource node status
	# if resource node exists
	if check_node_exists():
		var node:Resources = self.resource.get("node")
		var distance:float = node.global_transform.origin.distance_to(self.parent.global_transform.origin)
		# if within gathering distance
		if distance <= 1:
			# gather
			var done:bool = self.gather(node.resource_type, self.parent.gather_speed, self.parent.max_res, self.parent.gather_amount, delta)
			# if gather full -> set depot to null and drop off
			if done:
				self.depot = null
				self.gather_state = GATHER_STATE.DROPPING
		# else move to resource node
		else:
			self.parent.move(delta)
	# else
	else:
		#	find nearest resource node
		#	if node found -> continue gathering
		if self.get_closest_resource_node_of_type(self.resource.get("type")):
			self.parent.set_navigation_path(self.resource.get("node").global_transform.origin)
			self.gather_state = GATHER_STATE.GATHERING
		#	else stop gathering
		else:
			if resource.get("quantity") > 0:
				self.depot = null
				self.gather_state = GATHER_STATE.DROPPING
			else:
				self.gather_state = GATHER_STATE.NONE
				self.resource.set("node", null)
				self.resource.set("type", RESOURCE.NONE)


func go_drop_off(delta:float):
	# if depot exists
	if self.depot != null:
		# if within dropping distance
		if self.depot.global_transform.origin.distance_to(self.parent.global_transform.origin) <= 1:
			# drop_off
			self.depot.drop_off(self.resource.get("quantity"), self.resource.get("type"))
			# empty resources from container
			self.resource.set("quantity", 0)
			# set to gathering
			self.gather_state = GATHER_STATE.GATHERING
			# if node still exists, set as target
			if check_node_exists():
				print("Setting node as path")
				self.parent.set_navigation_path(self.resource.get("node").global_transform.origin)
		# else move to depot
		else:
			self.parent.move(delta)
	# else
	else:
		# find closest depot
		if self.get_closest_depot(self.parent.allegiance):
			# if depot exists -> continue dropping
			self.parent.set_navigation_path(self.depot.global_transform.origin)
		else:
			# else stop gathering
			self.gather_state = GATHER_STATE.NONE
			self.resource.set("node", null)
			self.resource.set("type", RESOURCE.NONE)


func get_closest_depot(allegiance:int) -> bool:
	var depots:Array = get_tree().get_nodes_in_group("depot")
	var closest:Building = null
	var dist:float = -1
	# find closest depot
	for d in depots:
		if d.allegiance == allegiance:
			var distance:float = self.parent.global_transform.origin.distance_to(d.global_transform.origin)
			if closest == null or distance < dist:
				dist = distance
				closest = d
	if closest != null:
		# assign it in the depot variable
		print("Closest Depot found at ", closest.global_transform.origin)
		self.depot = closest
		# return the position of the depot
		return true
	else:
		return false


func get_closest_resource_node_of_type(res:RESOURCE) -> bool:
	var resources:Array = get_tree().get_nodes_in_group("resource")
	var resource_type:RESOURCE = resource.get("type")
	# search all resources
	var closest:Resources = null
	var dist:float = -1
	for r in resources:
		var distance:float = self.parent.global_transform.origin.distance_to(r.global_transform.origin)
		if closest == null or distance < dist:
			closest = r
			dist = distance
	if closest != null:
		print("Closest Resource found at ", closest.global_transform.origin)
		self.resource.set("node", closest)
		return true
	else:
		return false
		
