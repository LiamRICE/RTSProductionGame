class_name Weapon extends RefCounted

const WeaponType := preload("uid://coiglhf6wydkv").WeaponType
const DamageType := preload("uid://coiglhf6wydkv").DamageType

var name : String
var ui_tooltip : String
var description : String
var weapon_type : WeaponType
var weapon_range : float
var weapon_accuracy : float
var weapon_damage_per_second : float
var weapon_damage_type : DamageType
var weapon_armour_penetration : float
var self_guided_weapon : bool
