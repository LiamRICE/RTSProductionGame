class_name ResourceCollectorUnit extends Infantry

@onready var collector_module = $ResourceCollectorModule
@onready var healthbar = $Healthbar

@export var gather_speed:float = 0.
@export var max_res:int = 10
@export var gather_amount:int = 1


func _ready():
	## Execute parent _ready function
	super._ready()
	healthbar.initialise_healthbar(entity_statistics.get(0), entity_statistics.get(0), 50)


func _physics_process(delta: float) -> void:
	self.collector_module.manage_gathering(delta)


func set_gathering_target(target:Resources, is_shift:bool = false):
	self.collector_module.set_gathering_target(target, is_shift)


func _get(property:StringName) -> Variant:
	if property == "type":
		return collector_module.resource["type"]
	else:
		return null


func _on_received_damage(health:int) -> void:
	healthbar.set_hp(health)
