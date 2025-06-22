class_name EntityActiveAbility extends EntityAbility

## Common Active Ability properties
@export_group("Properties")
@export var ability_duration:float
@export var ability_cooldown:float

## Nodes
var ability_cooldown_timer:Timer = Timer.new()
var ability_duration_timer:Timer = Timer.new()


## Initialise the ability, should be run when the initialising the unit
func init_ability(parent_entity:Entity) -> void:
	super.init_ability(parent_entity)
	self.current_state = STATE.READY
	self.ability_duration_timer.set_wait_time(self.ability_duration)
	self.ability_cooldown_timer.set_wait_time(self.ability_cooldown)
	self.ability_duration_timer.timeout.connect(self.stop_ability)
	self.ability_cooldown_timer.timeout.connect(self.reset_ability)

## Called when an ability is activated. This function should start the "process ability" function
func start_ability() -> void:
	if self.current_state == STATE.READY:
		self.current_state = STATE.ACTIVE
		self.ability_duration_timer.start()
		self.ability_cooldown_timer.start()

## Called every frame once start_ability has been called until the ability times out
func process_ability(delta:float) -> void: pass

## Called when the ability stops being active
func stop_ability() -> void:
	self.current_state = STATE.COOLDOWN

## Called when ability is reset to it's ready to activate state
func reset_ability() -> void:
	self.current_state = STATE.READY
