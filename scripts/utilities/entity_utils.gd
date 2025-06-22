extends Resource

## Entity constants
enum ENTITY_LIST{
	DEFAULT,
	INFANTRY,
	VEHICLE,
	RESOURCE_GATHERER,
	CITY_CENTRE,
	BARRACKS,
	TURRET
}

## Entity stats
class STATS:
	var health:String = "health"
	var shield:String = "shield"
	var armour:String = "armour"
	var damage:String = "damage"
	var attack_range:String = "attack_range"
	var attack_speed:String = "attack_speed"
	var sight:String = "sight"
	var speed:String = "speed"
	var acceleration:String = "acceleration"
	var turn_rate:String = "turn_rate"
	var turret_turn_speed:String = "turret_turn_speed"
