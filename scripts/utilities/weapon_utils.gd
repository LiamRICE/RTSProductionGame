extends Node


enum WeaponType{
	# large calibre direct fire
	GUN,
	AUTOCANNON,
	LASER_CANNON,
	# small calibre direct fire
	RIFLE,
	MACHINE_GUN,
	LASER_GUN,
	# large calibre point fire
	ARTILLERY_GUN,
	ARTILLERY_ROCKET,
	# missile direct fire
	AIR_AIR_MISSILE,
	AIR_GROUND_MISSILE,
	SURFACE_AIR_MISSILE,
	MANPAD,
	ANTI_TANK_GUIDED_MISSILE,
	ROCKET,
	# missile point fire
	BALLISTIC_MISSILE,
	CRUISE_MISSILE,
	# bombs
	GLIDE_BOMB,
	DUMB_BOMB,
	# drones
	FPV_DRONE,
	DROP_DRONE,
	AREA_DRONE,
}


enum AmunitionType{
	SOLID,
	SMART_SOLID,
	EXPLOSIVE,
	SMART_EXPLOSIVE,
	ENERGY,
}


enum ShotType{
	EXPLOSIVE,
	KINETIC,
}

enum DamageType{
	EXPLOSIVE,
	KINETIC,
	HEAT,
}

enum FireMode{
	POSITION,
	TARGET,
	TARGET_AND_POSITION,
}
