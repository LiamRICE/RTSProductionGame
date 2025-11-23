extends Sprite3D

const UnitCard := preload("uid://babr1rdcwc7hk")
const STATS := preload("uid://dki6gr7rrru2p").STATS
const TYPE := preload("uid://dki6gr7rrru2p").TYPE

@onready var viewport = $SubViewport

var _unit_card : UnitCard

func _ready():
	self._unit_card = $SubViewport/UnitCard


func set_hp(hp:float):
	self._unit_card.set_hp(hp)


func set_cover(cover_bonus:float):
	self._unit_card.set_cover(cover_bonus)


func initialise(unit : Entity, equipment : ArmyEquipment = null):
	self._initialise_unit_card(unit, equipment)


func _initialise_unit_card(unit : Entity, equipment : ArmyEquipment):
	self._unit_card.initialise_healthbar(unit.entity_statistics.get(STATS.HEALTH), unit.current_health)
	self._unit_card.initialise_coverbar()
	if equipment:
		self._unit_card.initialise_statistics(unit.name, TYPE.keys()[unit.entity_type], equipment.get_weapons())
	else:
		self._unit_card.initialise_statistics(unit.name, TYPE.keys()[unit.entity_type], [])
