class_name ArmyEquipmentResource extends Resource

const ExperienceLevel := preload("uid://coiglhf6wydkv").ExperienceLevel

@export_group("General")
@export var loadout_name : String
@export_multiline var description : String
@export_multiline var ui_tooltip : String

@export_group("Statistics")
@export var unit_accuracy : float
@export var experience_level : ExperienceLevel
@export var weapons : Array[EquipmentResource]
