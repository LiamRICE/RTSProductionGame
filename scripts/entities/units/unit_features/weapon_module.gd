class_name WeaponModule extends Node3D

@export_group("Weapons")
@export var weapon_resource_array : Array[WeaponResource]
@export var weapon_position_array : Array[Marker3D]
@export_group("Orders")
@export var weapon_orders : Array[OrderData]

var _weapon_handlers : Array[WeaponHandler]
var _weapon_range_detector : Area3D
var _collision_shape : CollisionShape3D
var _tracked_enemy_entities : Array[Entity]

func _ready() -> void:
	# loads weapon handlers from weapon resources
	self._weapon_handlers = []
	for i in range(min(len(weapon_resource_array), len(weapon_position_array))):
		self._weapon_handlers.append(WeaponHandler.load(weapon_resource_array[i], weapon_position_array[i]))
	# initialise area and detectors
	self._weapon_range_detector = self.get_node("WeaponRangeDetector")
	self._collision_shape = $WeaponRangeDetector/CollisionShape3D
	var shape : SphereShape3D = self._collision_shape.shape
	shape.radius = 10 # TODO - maximum range of all weapons


func get_enemies_in_range() -> Array[Entity]:
	print("Enemies in range :", self._tracked_enemy_entities)
	return self._tracked_enemy_entities


func get_optimal_configuration_for_target(entity : Entity):
	# TODO
	pass


func get_weapons() -> Array[WeaponHandler]:
	return self._weapon_handlers


func engage_target(target:Entity):
	pass


func _on_weapon_range_detector_body_entered(body: Node3D) -> void:
	if body.get_parent() is Entity:
		var entity : Entity = body.get_parent()
		if entity.allegiance != 0 and entity.allegiance != self.get_parent().allegiance:
			self._tracked_enemy_entities.append(entity)
			print("Entities in range :", self._tracked_enemy_entities)


func _on_weapon_range_detector_body_exited(body: Node3D) -> void:
	if body.get_parent() is Entity:
		var entity : Entity = body.get_parent()
		if entity.allegiance != 0 and entity.allegiance != self.get_parent().allegiance:
			self._tracked_enemy_entities.erase(entity)
			print("Entities in range :", self._tracked_enemy_entities)
