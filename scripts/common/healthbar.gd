extends Sprite3D

@onready var healthbar = $SubViewport/ProgressBar
@onready var viewport = $SubViewport

func set_hp(hp:int):
	self.healthbar.value = hp


func initialise_healthbar(max_hp:int, current_hp:int, width:int=100):
	self.healthbar.max_value = max_hp
	self.healthbar.value = current_hp
	self.viewport.size.x = width
