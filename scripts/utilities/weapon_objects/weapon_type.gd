class_name WeaponType extends Resource

# external enums
const WeaponType := preload("uid://cklliejhey2vf").WeaponType
const FireMode := preload("uid://cklliejhey2vf").FireMode

@export_group("General")
@export var weapon_effect:int
@export var fire_mode:FireMode

@export_group("Weapon Statistics")
@export var clip_size:int # number of bursts in a clip
@export var num_reloads:int # number of clips in a unit
@export var reload_time:float # amount of time it takes to reload a clip
@export var shots_per_burst:int # amount of shots are fired in a burst
@export var time_between_bursts:float # the amount of time it takes to fire a burst
@export var aim_time:float # the amount of time it takes to start firing at a new unit
@export var accuracy:float # 0-1, the fraction of time this weapon hits the target - ONLY USED FOR WEAPON THAT SHOOTS AT AN ENTITY
@export var circular_area_probable:float # the radius where 100% of the shots will land - ONLY USED FOR WEAPON THAT SHOOTS AT A POSITION
@export var range:float # the distance at which the weapon can hit the target

@export_group("Weapon Ammunition")
@export var ammunition_types:Array[AmmunitionType] # the type of ammunition this weapon uses
@export var rearm_time:float # the amount of time it takes to rearm a clip of the weapon
