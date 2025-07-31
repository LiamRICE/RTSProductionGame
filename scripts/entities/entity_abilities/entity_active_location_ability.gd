class_name EntityActiveLocationAbility extends EntityActiveAbility

## Signals
signal location_ability_fired(ability:EntityActiveLocationAbility)
signal location_ability_effect_spawn(ability_effect) ## TODO create the ability effect resource/packed_scene

## Shape and position of the ability
@export var ability_effect:int
var ability_position:Vector3


func init_ability(parent_entity:Entity) -> void:
	super.init_ability(parent_entity)

## Fires the location ability signal to set the player interface into ability mode
func fire_ability() -> void:
	self.location_ability_fired.emit(self)

## Used to start the location of the ability
func start_ability_at_location(location:Vector3) -> void:
	self.ability_position = location
	self.location_ability_effect_spawn.emit(self.ability_effect)
	print(self.ability_position)

func start_ability() -> bool:
	if not super.start_ability():
		return false
	## Start the ability
	return true
