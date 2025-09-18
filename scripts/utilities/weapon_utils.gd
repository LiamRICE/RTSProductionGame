extends RefCounted

# CombatMode Modifiers
const COMBAT_MODE_DAMAGE_MODIFIER:Array[float] = [1, 0.85, 1.05]
const COMBAT_MODE_SHOCK_MODIFIER:Array[float] = [1, 0.75, 0.9]
# ExperienceLevel Modifiers
const EXPERIENCE_ACCURACY_MODIFIER:Array[float] = [0.85, 0.9, 1, 1.05, 1.1]
const EXPERIENCE_SHOCK_MODIFIER:Array[float] = [0.75, 1, 1, 1.25, 1.5]

# enumerations
enum CombatMode{
	BALANCED=0,
	ENTRENCH=1,
	ASSAULT=2
}

enum EngagementMode {
	FULL = 0,
	OPTIMAL = 1,
	NONE = 2,
}

enum AmmoType {
	SOLID = 0,
	SMART_SOLID = 1,
	EXPLOSIVE = 2,
	SMART_EXPLOSIVE = 3,
	ENERGY = 4,
}

enum ExperienceLevel{
	CONSCRIPT=0,
	VOLUNTEER=1,
	REGULAR=2,
	PROFESSIONAL=3,
	ELITE=4
}

enum WeaponType {
	DIRECT_FIRE = 0,
	INDIRECT_FIRE = 1,
}

enum DamageType {
	EXPLOSIVE = 0,
	KINETIC = 1,
	HEAT = 2,
	ENERGY_LASER = 3,
	ENERGY_MICROWAVE = 4,
	NO_DAMAGE = 5,
}

enum WeaponCategory {
	# large calibre direct fire
	GUN = 0,
	AUTOCANNON = 1,
	LASER_CANNON = 2,
	# small calibre direct fire
	RIFLE = 3,
	MACHINE_GUN = 4,
	LASER_GUN = 5,
	# large calibre point fire
	ARTILLERY_GUN = 6,
	ARTILLERY_ROCKET = 7,
	# missile direct fire
	AIR_AIR_MISSILE = 8,
	AIR_GROUND_MISSILE = 9,
	SURFACE_AIR_MISSILE = 10,
	MANPAD = 11,
	ANTI_TANK_GUIDED_MISSILE = 12,
	ROCKET = 13,
	# missile point fire
	BALLISTIC_MISSILE = 14,
	CRUISE_MISSILE = 15,
	# bombs
	GLIDE_BOMB = 16,
	DUMB_BOMB = 17,
	# drones
	FPV_DRONE = 18,
	DROP_DRONE = 19,
	AREA_DRONE = 20,
}

enum WeaponState {
	NONE = 0,
	AIMING = 1,
	FIRING = 2,
	RELOADING = 3,
	REARMING = 4,
}
