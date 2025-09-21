class_name Tank extends Unit

const UnitCard:Script = preload("uid://45nawhpn2sjv")

@onready var _unit_card:UnitCard
@onready var _army_equipment:ArmyEquipment

func _ready():
	## Execute parent _ready function
	super._ready()
	self._army_equipment = %ArmyEquipment
	self._unit_card = %UnitCard
	self._unit_card.initialise(self, self._army_equipment)


func _on_received_damage(health:int) -> void:
	self._unit_card.set_hp(health)
