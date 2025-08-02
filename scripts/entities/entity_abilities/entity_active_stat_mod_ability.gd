class_name EntityActiveStatModAbility extends EntityActiveAbility

## Constants
const STATS := preload("uid://dki6gr7rrru2p").STATS

## Properties
@export var stat_to_modify:STATS
@export var stat_mod_amount:float

## Initialise the ability, should be run when the initialising the unit
func init_ability(parent_entity:Entity) -> void:
	super.init_ability(parent_entity)

## Called when an ability is activated. This function should start the "process ability" function
func start_ability() -> bool:
	if super.start_ability():
		self.entity.ability_stat_modification(self.stat_to_modify, self.stat_mod_amount)
		print("Ability ", self.ability_name, " activated on ", self.get_parent())
		return true
	return false

## Called when the ability stops being active
func stop_ability() -> void:
	super.stop_ability()
	print("Ability stopped")
	self.entity.ability_stat_modification(self.stat_to_modify, -self.stat_mod_amount)

## Called when ability is reset to it's ready to activate state
func reset_ability() -> void:
	print("Ability cooldown over")
	super.reset_ability()
