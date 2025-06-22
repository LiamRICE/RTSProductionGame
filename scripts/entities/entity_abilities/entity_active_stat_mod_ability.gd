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
func start_ability() -> void:
	super.start_ability()

## Called every frame once start_ability has been called until the ability times out
func process_ability(delta:float) -> void:
	super.process_ability(delta)

## Called when the ability stops being active
func stop_ability() -> void:
	super.stop_ability()

## Called when ability is reset to it's ready to activate state
func reset_ability() -> void:
	super.reset_ability()
