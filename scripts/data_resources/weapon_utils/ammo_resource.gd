class_name AmmoResource extends Resource

const AmmoType = preload("uid://coiglhf6wydkv").AmmoType
const ShotType = preload("uid://coiglhf6wydkv").ShotType
const DamageType = preload("uid://coiglhf6wydkv").DamageType

@export_group("General")
@export var name : String
@export_multiline var description : String
@export_multiline var ui_tooltip : String
@export var ammo_type : AmmoType

@export_group("Statistics")
@export var number_of_clips : int
@export var clip_size : int
@export var damage : float
@export var shot_type : ShotType
@export var damage_type : DamageType
@export var explosion_radius : float
