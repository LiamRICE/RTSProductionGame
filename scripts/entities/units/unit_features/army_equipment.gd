class_name ArmyEquipment extends Node3D

# Imports
const WeaponDebugView := preload("uid://mw2q7lomrl1p")
const CombatState := preload("uid://coiglhf6wydkv").CombatState
const CombatMode := preload("uid://coiglhf6wydkv").CombatMode
const EngagementMode := preload("uid://coiglhf6wydkv").EngagementMode
const EXPERIENCE_ACCURACY_MODIFIER := preload("uid://coiglhf6wydkv").EXPERIENCE_ACCURACY_MODIFIER
const WeaponUtils := preload("uid://coiglhf6wydkv")

# set variables
var equipment_resource : ArmyEquipmentResource

# DEBUG
@export_group("Debug")
@export var debug_view : WeaponDebugView

# internal variables
var _unit_accuracy : float
var equipment : Array[Equipment]
var _tracked_enemy_entities : Array[Entity]
var _weapon_range_detector : Area3D
var _combat_state : CombatState
var _parent : Entity
var _is_attacked : bool

# Unit Combat Settings
var _combat_mode : CombatMode
var _engagement_mode : EngagementMode

""" NODE METHODS """

func _ready():
	self._parent = self.get_parent()
	self._parent.received_damage.connect(self.manage_attacked_state)
	# initialise the equipment
	self._initialise()

func _physics_process(delta: float) -> void:
	if not self._tracked_enemy_entities.is_empty():
		engage(self._tracked_enemy_entities, delta)

""" ARMY EQUIPMENT METHODS """

# initialises all of the variables in the army equipment object
func _initialise():
	# fetch the equipment resource from the entity database
	self.equipment_resource = EntityDatabase.get_entity_armament(self._parent.entity_id)
	# extract base variables
	self._unit_accuracy = self.equipment_resource.unit_accuracy * EXPERIENCE_ACCURACY_MODIFIER[self.equipment_resource.experience_level]
	self._combat_mode = CombatMode.BALANCED
	self._engagement_mode = EngagementMode.FULL
	self._combat_state = CombatState.NONE
	self._is_attacked = false
	self._weapon_range_detector = self.get_child(0)
	# var to search highest range
	var highest_range : float = 0
	# extract equipment
	for equipment_res in self.equipment_resource.weapons:
		# set the equipment
		var new_equipment := Equipment.new()
		new_equipment.ammunition = equipment_res.weapon.ammunition * equipment_res.quantity
		new_equipment.max_ammunition = equipment_res.weapon.ammunition * equipment_res.quantity
		new_equipment.quantity = equipment_res.quantity
		new_equipment.max_quantity = equipment_res.quantity
		new_equipment.ammunition_use_per_unit_per_second = equipment_res.weapon.fire_rate_per_minute / 60
		# set the weapon
		new_equipment.weapon = Weapon.new()
		new_equipment.weapon.name = equipment_res.weapon.weapon_name
		new_equipment.weapon.description = equipment_res.weapon.description
		new_equipment.weapon.ui_tooltip = equipment_res.weapon.ui_tooltip
		new_equipment.weapon.weapon_type = equipment_res.weapon.weapon_type
		new_equipment.weapon.weapon_range = equipment_res.weapon.weapon_range
		new_equipment.weapon.weapon_accuracy = equipment_res.weapon.weapon_accuracy
		new_equipment.weapon.self_guided_weapon = equipment_res.weapon.self_guided_weapon
		new_equipment.weapon.weapon_damage_type = equipment_res.weapon.damage_type
		new_equipment.weapon.weapon_damage_per_second = equipment_res.weapon.damage * (equipment_res.weapon.fire_rate_per_minute / 60)
		new_equipment.weapon.weapon_armour_penetration = equipment_res.weapon.armour_penetration
		print("Weapon ready : ", new_equipment.weapon.name, " with ", new_equipment.weapon.weapon_damage_per_second, " dps and ", new_equipment.ammunition, " ammunition over ", new_equipment.quantity, " ", self.equipment_resource.loadout_name, "s")
		self.equipment.append(new_equipment)
		# set the highest range value to the highest weapon range
		if new_equipment.weapon.weapon_range > highest_range:
			highest_range = new_equipment.weapon.weapon_range
	# set the range of the area2D as the highest range
	self._weapon_range_detector.get_child(0).shape.radius = highest_range

# attacks each target in range with each weapon
func engage(targets : Array[Entity], _delta : float):
	# DEBUG clear shooting attay
	self.debug_view.set_values_shooting([])
	var found : bool = false
	# only attacks if there are valid targets
	if len(targets) > 0:
		# Full engagement mode : attacks each enemy equally
		if self._engagement_mode == EngagementMode.FULL:
			for weapon in self.equipment:
				var targets_in_range = weapon.targets_in_range(targets, self.global_position)
				if not targets_in_range.is_empty():
					found = true
					self._combat_state = WeaponUtils.update_combat_state(self._is_attacked, true)
					# DEBUG show shooting
					self.debug_view.add_value_shooting(weapon.weapon)
					# create the proportion of fire to split between each target (can check weapons to optimise damage between attacking units)
					var fire_proportion : float = 1. / float(len(targets_in_range))
					for target in targets_in_range:
						# decrease damage as proportion to the number of attacking enemies as damage is split between targets
						var accuracy = self._unit_accuracy + weapon.weapon.weapon_accuracy
						if weapon.weapon.self_guided_weapon:
							accuracy = weapon.weapon.weapon_accuracy
						var damage = weapon.fire(_delta, self._combat_mode) * fire_proportion
						target.receive_damage(damage, weapon.weapon.weapon_damage_type, weapon.weapon.weapon_armour_penetration, accuracy)
		
		# Optimal engagement mode : weapons only attack optimal targets
		elif self._engagement_mode == EngagementMode.OPTIMAL:
			pass
		
		if not found:
			self._combat_state = WeaponUtils.update_combat_state(self._is_attacked, false)
		
		if self._combat_state in [CombatState.ENGAGED, CombatState.ENGAGED_ENGAGING]:
			self.debug_view.set_values_shot_at(true)
			self._is_attacked = false


func manage_attacked_state():
	self.is_attacked = true


func get_weapons() -> Array[Weapon]:
	var weapons : Array[Weapon] = []
	for equip in self.equipment:
		weapons.append(equip.weapon)
	return weapons

""" INTERNAL SIGNALS """

func _on_weapon_range_detector_body_entered(body: Node3D) -> void:
	if body.get_parent() is Entity:
		var entity = body.get_parent()
		print("Body entered : ", entity)
		print(self.get_parent().allegiance, " == ", entity.allegiance)
		if entity.allegiance != 0 and entity.allegiance != self.get_parent().allegiance:
			self._tracked_enemy_entities.append(entity)
	print("Tracked Enemies : ", self._tracked_enemy_entities)


func _on_weapon_range_detector_body_exited(body: Node3D) -> void:
	if body.get_parent() is Entity:
		var entity = body.get_parent()
		print("Body exited : ", entity)
		if body in self._tracked_enemy_entities:
			self._tracked_enemy_entities.erase(entity)
		print("Tracked Enemies : ", self._tracked_enemy_entities)


func _damage_taken():
	pass
