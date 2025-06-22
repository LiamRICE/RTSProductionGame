class_name EntityStats extends Resource

## Entity stats
@export var entity_statistics:Dictionary[String, float] = {
	"health" : 0,
	"shield" : 0,
	"armour" : 0,
	"damage" : 0,
	"range" : 0,
	"attack speed" : 0,
	"sight" : 0,
	"speed" : 0,
	"acceleration" : 0,
	"turn rate" : 0,
	"turret turn speed" : 0
}

func update_stat(stat:String, value:float) -> void:
	self.entity_statistics[stat] = value

func modify_stat(stat:String, modifier:float) -> void:
	self.entity_statistics[stat] += modifier

func get_stat(stat:String) -> float:
	return self.entity_statistics[stat]
