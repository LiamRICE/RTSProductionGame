class_name AmmunitionType extends Resource

# external enums
const AmmoType := preload("uid://cklliejhey2vf").AmmoType
const DamageType := preload("uid://cklliejhey2vf").DamageType
const ShotType := preload("uid://cklliejhey2vf").ShotType

@export_group("Ammunition Type")
@export var ammo_type:AmmoType # the type of ammunition used
@export var damage:float # the amount of damage the weapon deals on a hit
@export var shot_type:ShotType # determines whether the weapon is AoE or not
@export var damage_type:DamageType
@export_multiline var ui_description:String
@export_multiline var ui_tooltip:String
