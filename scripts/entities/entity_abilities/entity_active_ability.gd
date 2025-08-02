class_name EntityActiveAbility extends EntityAbility

## Constants
enum STATE{DISABLED, READY, ACTIVE, COOLDOWN}

## Common Active Ability properties
@export_group("Properties")
@export var ability_duration:float
@export var ability_cooldown:float
var current_state:STATE = STATE.DISABLED

## Nodes
var ability_cooldown_timer:Timer = Timer.new()
var ability_duration_timer:Timer = Timer.new()


## Initialise the ability, should be run when the initialising the unit
func init_ability(parent_entity:Entity) -> void:
	super.init_ability(parent_entity)
	self.add_child(self.ability_cooldown_timer)
	self.add_child(self.ability_duration_timer)
	self.ability_duration_timer.set_wait_time(self.ability_duration)
	self.ability_cooldown_timer.set_wait_time(self.ability_cooldown)
	self.ability_duration_timer.timeout.connect(self.stop_ability)
	self.ability_cooldown_timer.timeout.connect(self.reset_ability)
	self.ability_duration_timer.one_shot = true
	self.ability_cooldown_timer.one_shot = true
	self.current_state = STATE.READY

## Called when an ability is activated. This function should start the "process ability" function
func start_ability() -> bool:
	if not self.current_state == STATE.READY:
		return false
	self.current_state = STATE.ACTIVE
	self.ability_duration_timer.start()
	return true

## Called when the ability stops being active
func stop_ability() -> void:
	self.current_state = STATE.COOLDOWN
	self.ability_cooldown_timer.start()

## Called when ability is reset to it's ready to activate state
func reset_ability() -> void:
	self.current_state = STATE.READY
