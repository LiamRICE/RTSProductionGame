extends Sprite3D

@onready var shooting_label : Label = $SubViewport/ShootingLabel
@onready var shot_at_label : Label = $SubViewport/ShotAtLabel


func _ready():
	shooting_label.text = ""
	shot_at_label.text = ""


func add_value_shooting(weapon : Weapon):
	shooting_label.text += "Shooting " + weapon.name + "\n"

func set_values_shooting(shooting : Array[Weapon]):
	var text = ""
	for weapon in shooting:
		text += "Shooting " + weapon.name + "\n"
	shooting_label.text = text


func set_values_shot_at(shot_at : bool):
	if shot_at:
		shot_at_label.text = "Engaged"
	else:
		shot_at_label.text = ""
