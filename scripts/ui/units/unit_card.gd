extends CanvasLayer


@onready var healthbar := %HealthBar
@onready var unit_name_label := %UnitNameLabel
@onready var unit_type_label := %UnitTypeLabel

func set_hp(hp:int):
	self.healthbar.value = hp


func initialise_healthbar(max_hp:int, current_hp:int):
	self.healthbar.max_value = max_hp
	self.healthbar.value = current_hp


func initialise_statistics(unit_name:String, unit_type:String, weapons:Array[Weapon]):
	self.unit_name_label.text = unit_name
	self.unit_type_label.text = unit_type
