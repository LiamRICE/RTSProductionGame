class_name WeaponResource extends Resource

const DamageType := preload("uid://coiglhf6wydkv").DamageType
const WeaponType := preload("uid://coiglhf6wydkv").WeaponType

@export_group("General")
@export var weapon_name : String
@export_multiline var description : String
@export_multiline var ui_tooltip : String
@export var weapon_type : WeaponType

@export_group("Statistics")
@export var weapon_range : float
@export var damage : float
@export var damage_type : DamageType
@export var armour_penetration : float
@export var ammunition : int
@export var fire_rate_per_minute : float
@export var weapon_accuracy : float # this accuracy is added to the unit's accuracy to represent weapons assisting the unit's base precision (like gps guidance, self-correcting shots, etc...)
@export var self_guided_weapon : bool # if weapon is self guided, only it's accuracy is taken into account rather than the unit's accuracy
