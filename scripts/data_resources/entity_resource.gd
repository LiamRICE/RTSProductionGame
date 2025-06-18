class_name EntityResource extends Resource

## PackedScene
@export var entity_instance:PackedScene

## Properties
@export_group("Properties")
@export var health:float
@export var production_cost:float

@export_group("Abilities")
@export var abilities:Array[EntityAbility]

## Additional info
@export_group("UI variables")
@export var name:String
@export var ui_icon:Texture2D
@export_multiline var ui_description:String
@export_multiline var ui_tooltip:String
