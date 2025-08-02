extends CSGSphere3D

var damage:int = 0
@onready var area:Area3D = $Area3D
@onready var collision_area:CollisionShape3D = $Area3D/CollisionShape3D


func init(radius:float, damage:int):
	self.damage = damage
	self.collision_area.shape.radius = radius
	self.area.body_entered.connect(self.deal_damage)


func detonate():
	self.area.monitoring = true


func deal_damage(body:Node3D):
	if body is Entity:
		body.receive_damage(self.distance_damage_reduction(body.global_position, self.damage))


func distance_damage_reduction(target_position:Vector3, damage:float) -> float:
	return damage
