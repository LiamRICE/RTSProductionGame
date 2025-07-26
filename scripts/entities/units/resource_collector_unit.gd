class_name ResourceCollectorUnit extends Infantry

@onready var gatherer = $ResourceCollectorModule
@onready var healthbar = $Healthbar

@export var gather_speed:float = 0.
@export var max_res:int = 10
@export var gather_amount:int = 1


func _ready():
	## Execute parent _ready function
	super._ready()
	healthbar.initialise_healthbar(entity_statistics.get(0), entity_statistics.get(0), 50)


func _physics_process(delta: float) -> void:
	self.gatherer.manage_gathering(delta)


func update_target_location(target_location:Vector3, is_shift:bool = false):
	# raycast target location
	# if raycast is a unit, set that unit as the target and stop when you're in range
	# if raycast is not a unit, set that location as a target and stop at the target
	# if raycast is a resource, start resource gathering loop (manage_gathering)
	self.gatherer.clear_gathering_target()
	set_navigation_path(target_location, is_shift)


func set_gathering_target(target:Resources, is_shift:bool = false):
	self.gatherer.set_gathering_target(target, is_shift)


func _get(property:StringName) -> Variant:
	if property == "type":
		return gatherer.resource["type"]
	else:
		return null


func _on_received_damage(health:int) -> void:
	healthbar.set_hp(health)
