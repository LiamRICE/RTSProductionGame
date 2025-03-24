class_name ResourceCollectorUnit extends Infantry

@onready var gatherer = $ResourceCollectorModule

@export var gather_speed:float = 0.
@export var max_res:int = 10
@export var gather_amount:int = 1


func _ready():
	pass


func _physics_process(delta: float) -> void:
	if self.gatherer.gather_state == self.gatherer.resource_utils.GatherState.NONE:
		# just do the normal moving
		move(delta)
	else:
		manage_gathering(delta)


func update_target_location(target_location:Vector3, is_shift:bool = false):
	# raycast target location
	# if raycast is a unit, set that unit as the target and stop when you're in range
	# if raycast is not a unit, set that location as a target and stop at the target
	# if raycast is a resource, start resource gathering loop (manage_gathering)
	set_navigation_path(target_location, is_shift)
	self.gatherer.gather_state = self.gatherer.resource_utils.GatherState.NONE


func set_gathering_target(target:Resources, is_shift:bool = false):
	# set target as the navigation target
	self.gatherer.resource.set("node", target)
	self.gatherer.resource.set("type", target.resource_type)
	self.gatherer.gather_state = self.gatherer.resource_utils.GatherState.GATHERING
	set_navigation_path(target.global_transform.origin, is_shift)


func manage_gathering(delta:float):
	if self.gatherer.gather_state == self.gatherer.resource_utils.GatherState.GATHERING:
		go_gathering(delta)
	elif self.gatherer.gather_state == self.gatherer.resource_utils.GatherState.DROPPING:
		drop_off(delta)


func go_gathering(delta:float):
	if self.gatherer.resource.get("node") != null:
		var node:Resources = self.gatherer.resource.get("node")
		var distance:float = node.global_transform.origin.distance_to(global_transform.origin)
		if distance <= 1:
			var done:bool = self.gatherer.gather(node.resource_type, gather_speed, max_res, gather_amount, delta)
			# check if resource collection is finished
			if done:
				var target:Vector3 = self.gatherer.get_closest_depot(self.allegiance)
				# set depot as move target
				set_navigation_path(target)
				self.gatherer.gather_state = self.gatherer.resource_utils.GatherState.DROPPING
		else:
			move(delta)
	else:
		# node is null so resource is depleted
		# find nearest duplicate of that resource type
		var node:Vector3 = self.gatherer.get_closest_resource_node_of_type(self.gatherer.resource.get("type"))
		set_navigation_path(position)
		if self.gatherer.resource.get("node") == null:
			self.gatherer.gather_state = self.gatherer.resource_utils.GatherState.NONE


func drop_off(delta:float):
	if self.gatherer.depot != null:
		# if within range, drop off resources and trigger
		if self.gatherer.depot.global_transform.origin.distance_to(global_transform.origin) <= 1:
			self.gatherer.depot.drop_off(self.gatherer.resource.get("quantity"))
			self.gatherer.resource.set("quantity", 0)
			self.gatherer.gather_state = self.gatherer.resource_utils.GatherState.GATHERING
			if self.gatherer.resource.get("node") != null:
				set_navigation_path(self.gatherer.resource.get("node").global_transform.origin)
			else:
				var position:Vector3 = self.gatherer.get_closest_resource_node_of_type(self.gatherer.resource.get("type"))
				set_navigation_path(position)
		else:
			# if target is selected, move to target
			move(delta)
	else:
		# if null, then find closest depot
		var target:Vector3 = self.gatherer.get_closest_depot(self.allegiance)
		set_navigation_path(target)
