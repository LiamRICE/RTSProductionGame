class_name EntityPassiveStatModAbility extends EntityPassiveAbility

## Constants
const STATS := preload("uid://dki6gr7rrru2p").STATS

## Properties
@export var stat_to_modify:STATS
@export var stat_mod_amount:float

func start_ability() -> bool:
	super.start_ability()
	self.entity.ability_stat_modification(self.stat_to_modify, self.stat_mod_amount)
	return true
