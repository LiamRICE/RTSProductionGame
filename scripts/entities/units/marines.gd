class_name Marines extends Unit

const UnitCard:Script = preload("uid://45nawhpn2sjv")

@onready var _unit_card:UnitCard = %UnitCard
@onready var _army_equipment:ArmyEquipment = %ArmyEquipment

func _ready():
	## Execute parent _ready function
	super._ready()
	self.received_damage.connect(self._on_received_damage)
	self._unit_card.initialise(self, self._army_equipment)
	print("Marines ready")


func _on_received_damage(health:int) -> void:
	self._unit_card.set_hp(health)
