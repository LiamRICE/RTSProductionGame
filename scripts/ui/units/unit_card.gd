extends CanvasLayer

# Info bars
@onready var healthbar : ProgressBar = %HealthBar
@onready var coverbar : ProgressBar = %CoverBar
# Labels
@onready var unit_name_label := %UnitNameLabel
@onready var unit_type_label := %UnitTypeLabel

func set_hp(hp:float):
	self.healthbar.value = hp


func set_cover(cover_bonus:float):
	self.coverbar.value = cover_bonus
	if cover_bonus > 0:
		self.coverbar.show()
	else:
		self.coverbar.hide()


func initialise_healthbar(max_hp:float, current_hp:float):
	self.healthbar.max_value = max_hp
	self.healthbar.value = current_hp


func initialise_coverbar(max_cover_bonus:float = 1):
	self.coverbar.max_value = max_cover_bonus
	self.coverbar.value = 0
	if self.coverbar.value <= 0:
		self.coverbar.hide()


func initialise_statistics(unit_name:String, unit_type:String, weapons:Array[Weapon]):
	self.unit_name_label.text = unit_name
	self.unit_type_label.text = unit_type
