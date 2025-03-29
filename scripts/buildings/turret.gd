class_name Turret extends Building

## Dedicated Nodes
@export var rotating_mesh:MeshInstance3D
var attack_zone:Area3D

## Properties
@export_group("Properties")
@export var damage:float ## Damage inflicted for each attack. DPS is damage * attack speed
@export var attack_speed:float ## Speed of attacks in attacks per second
@export var attack_range:float ## Range of attacks in grid units

## Properties
var target:Entity
var target_list:Array[Entity]
var is_attacking:bool


## Turret methods ##

## Ready function
func _ready() -> void:
	# Create the attack zone which detects attackable units
	_initialise_range_detection()

func _initialise_range_detection() -> void:
	## Create the attack zone which detects attackable units
	# Create the shape
	var shape:CylinderShape3D = CylinderShape3D.new()
	shape.height = 5
	shape.radius = self.attack_range
	# Create the collider to hold the shape
	var collider:CollisionShape3D = CollisionShape3D.new()
	collider.position.y = 2.5
	collider.shape = shape
	# Create the attack zone
	self.attack_zone = Area3D.new()
	self.add_child(self.attack_zone)
	self.attack_zone.add_child(collider)
	# Connect bodies entering and exiting to their relevant functions
	self.attack_zone.body_entered.connect(_unit_entered_range)
	self.attack_zone.body_exited.connect(_unit_left_range)

## Sets the target of the turret, usually defaults to nearest unit and concentrates fire on that unit until it dies or leaves range
func _switch_target() -> void:
	_set_target(null)
	## Go through the potential target list and fire at the closest
	if self.target_list.size() > 0:
		var closest_entity:Entity
		var distance:float = 1000
		for entity in self.target_list:
			var dist:float = entity.global_position.distance_squared_to(self.global_position)
			if dist < distance:
				distance = dist
				closest_entity = entity
		_set_target(closest_entity)

## Rotate the turret to aim at it's current target
func _rotate_towards_target(target_position:Vector3):
	self.rotating_mesh.look_at(target_position, Vector3.UP, true)

## Sets the target of the turret, starts attacks and animations
func _set_target(target:Entity) -> void:
	self.target = target
	if target != null:
		_rotate_towards_target(target.position)
		_start_attacking()
	else:
		_stop_attacking()

## Called when the unit starts attacking
## Play attack animations, show warnings, etc...
func _start_attacking() -> void:
	self.is_attacking = true

## Called when unit stops attacking
## Stop attack animations, hide warnings, etc...
func _stop_attacking() -> void:
	self.is_attacking = false

## Called when a body enters the turret range
func _unit_entered_range(body:Node3D) -> void:
	if body.get_parent_node_3d() is Entity and not body.get_parent_node_3d() == null:
		var entity:Entity = body.get_parent_node_3d()
		if entity.allegiance != self.allegiance and entity.allegiance != 0:
			self.target_list.push_back(entity)
			if self.target == null: # Find new target
				self._set_target(entity)

## Called when a body leaves the turret range
func _unit_left_range(body:Node3D) -> void:
	if body.get_parent_node_3d() is Entity and not body.get_parent_node_3d() == null:
		var entity:Entity = body.get_parent_node_3d()
		self.target_list.erase(entity)
		if entity == self.target: # If the entity leaving range was the target, switch target
			_switch_target()
