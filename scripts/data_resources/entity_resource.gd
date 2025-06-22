class_name EntityResource extends Resource

## Imports
const ResourceType := preload("uid://c4mlh3p0sd0vd").Res

## PackedScene
@export var entity_instance:PackedScene

## Properties
@export_group("Properties")
@export var health:float
@export var production_cost:Dictionary[ResourceType, float]

## Additional info
@export_group("UI variables")
@export var name:String
@export var ui_icon:Texture2D
@export_multiline var ui_description:String
@export_multiline var ui_tooltip:String

func get_type():
	print(ResourceType.get_typed_key_script())
