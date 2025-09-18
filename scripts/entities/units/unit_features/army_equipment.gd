class_name ArmyEquipment extends Node3D

# Imports
const CombatMode := preload("uid://coiglhf6wydkv").CombatMode
const EngagementMode := preload("uid://coiglhf6wydkv").EngagementMode
const EXPERIENCE_ACCURACY_MODIFIER := preload("uid://coiglhf6wydkv").EXPERIENCE_ACCURACY_MODIFIER

# set variables
@export_group("Equipment")
@export var equipment_resource : ArmyEquipmentResource

# internal variables
var _unit_accuracy : float
var equipment : Array[Equipment]

# Unit Combat Settings
var _combat_mode : CombatMode
var _engagement_mode : EngagementMode


func _ready():
	self._initialise()

# initialises all of the variables in the army equipment object
func _initialise():
	# extract base variables
	self._unit_accuracy = self.equipment_resource.unit_accuracy * EXPERIENCE_ACCURACY_MODIFIER[self.equipment_resource.experience_level]
	self._combat_mode = CombatMode.BALANCED
	self._engagement_mode = EngagementMode.FULL
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

# attacks each target in range with each weapon
func engage(targets : Array[Entity], _delta : float):
	# only attacks if there are valid targets
	if len(targets) > 0:
		# Full engagement mode : attacks each enemy equally
		if self._engagement_mode == EngagementMode.FULL:
			for weapon in self.equipment:
				var targets_in_range = weapon.targets_in_range(targets, self.global_position)
				if not targets_in_range.is_empty():
					# create the proportion of fire to split between each target (can check weapons to optimise damage between attacking units)
					var fire_proportion := 1 / len(targets_in_range)
					for target in targets_in_range:
						# decrease damage as proportion to the number of attacking enemies as damage is split between targets
						var accuracy = self._unit_accuracy + weapon.weapon.weapon_accuracy
						if weapon.weapon.self_guided_weapon:
							accuracy = weapon.weapon.weapon_accuracy
						var damage = weapon.fire(_delta, self._combat_mode) * fire_proportion * accuracy
						target.receive_damage(damage, weapon.weapon.weapon_damage_type, weapon.weapon.weapon_armour_penetration)
		
		# Optimal engagement mode : weapons only attack optimal targets
		elif self._engagement_mode == EngagementMode.OPTIMAL:
			pass
