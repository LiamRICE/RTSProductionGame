class_name Vehicle extends Unit

const Healthbar:Script = preload("uid://45nawhpn2sjv")

@onready var healthbar:Healthbar = $Healthbar


func _ready():
	## Execute parent _ready function
	super._ready()
	healthbar.initialise_healthbar(entity_statistics.get(0), entity_statistics.get(0), 50)


func _on_received_damage(health:int) -> void:
	healthbar.set_hp(health)
