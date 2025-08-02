class_name EntityPassiveAbility extends EntityAbility

## Initialise the ability, should be run when the initialising the unit
func init_ability(parent_entity:Entity) -> void:
	super.init_ability(parent_entity)
	self.start_ability()

## Called when an ability is activated. This function should start the "process ability" function
func start_ability() -> bool:
	return super.start_ability()

## Called every frame once start_ability has been called until the ability times out
func process_ability(_delta:float) -> void:
	super.process_ability(_delta)

## Called when the ability stops being active
func stop_ability() -> void:
	super.stop_ability()

## Called when ability is reset to it's ready to activate state
func reset_ability() -> void:
	super.stop_ability()
