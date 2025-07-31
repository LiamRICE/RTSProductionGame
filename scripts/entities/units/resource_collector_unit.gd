class_name ResourceCollectorUnit extends Infantry

@onready var gatherer = $ResourceCollectorModule

@export var gather_speed:float = 0.
@export var max_res:int = 10
@export var gather_amount:int = 1


func _ready():
	## Execute parent _ready function
	super._ready()


func _physics_process(delta: float) -> void:
	self.gatherer.manage_gathering(delta)


func set_gathering_target(target:Resources, is_shift:bool = false):
	self.gatherer.set_gathering_target(target, is_shift)

func _get(property:StringName) -> Variant:
	if property == "type":
		return gatherer.resource["type"]
	else:
		return null
