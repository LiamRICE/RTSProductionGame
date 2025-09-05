class_name WeaponResource extends Resource

# constants
const WeaponCategory = preload("uid://coiglhf6wydkv").WeaponCategory

@export_group("General")
@export var name : String
@export_multiline var description : String
@export_multiline var ui_tooltip : String
@export var weapon_category : WeaponCategory

@export_group("Statistics")
@export var fire_methods : Array[FireMethodResource]
@export var ammo : Array[AmmoResource]
@export var reload_time : float
@export var time_between_bursts : float
@export var rearm_time : float
@export var is_stabilised : bool
