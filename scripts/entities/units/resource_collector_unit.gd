class_name ResourceCollectorUnit extends Unit

## Constants
const InventoryModule:Script = preload("uid://boci3e8npvh1a")
const Healthbar:Script = preload("uid://45nawhpn2sjv")

## Internal nodes
@onready var inventory_module:InventoryModule = $InventoryModule
@onready var healthbar:Healthbar = $Healthbar


func _ready():
	## Execute parent _ready function
	super._ready()
	healthbar.initialise_healthbar(entity_statistics.get(0), entity_statistics.get(0), 50)

func _get(property:StringName) -> Variant:
	if property == "type":
		return inventory_module.resource["type"]
	else:
		return null

func _on_received_damage(health:int) -> void:
	healthbar.set_hp(health)
