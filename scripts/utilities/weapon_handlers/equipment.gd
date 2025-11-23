class_name Equipment extends RefCounted

const CombatMode := preload("uid://coiglhf6wydkv").CombatMode
const COMBAT_MODE_DAMAGE_MODIFIER := preload("uid://coiglhf6wydkv").COMBAT_MODE_DAMAGE_MODIFIER

var weapon : Weapon
var max_quantity : int
var quantity : int
var max_ammunition : int
var ammunition : float
var ammunition_use_per_unit_per_second : float

# returns the raw damage of the unit over the time delta
func fire(_delta:float, combat_mode:CombatMode) -> float:
	# decrease ammo
	var decrease_ammount := self.ammunition_use_per_unit_per_second * self.quantity * _delta
	var damage = self.weapon.weapon_damage_per_second * self.quantity * _delta
	if decrease_ammount >= ammunition:
		self.ammunition -= decrease_ammount
	elif decrease_ammount < ammunition:
		self.ammunition = 0
		var fraction := decrease_ammount - ammunition / decrease_ammount
		damage = damage * fraction
	# modify damage by combat mode
	damage = damage * COMBAT_MODE_DAMAGE_MODIFIER[combat_mode]
	# return amount of damage dealt over this time period
	return damage


func targets_in_range(entities:Array[Entity], current_position:Vector3) -> Array[Entity]:
	var entities_in_range : Array[Entity] = []
	var to_clear : Array[int] = []
	var i := 0
	for entity in entities:
		if entity:
			if current_position.distance_to(entity.global_position) < self.weapon.weapon_range:
				entities_in_range.append(entity)
		else:
			to_clear.append(i)
		i += 1
	if not to_clear.is_empty():
		to_clear.reverse()
		for j in to_clear:
			entities.remove_at(j)
	return entities_in_range
