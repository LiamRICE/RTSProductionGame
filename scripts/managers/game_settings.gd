extends Node


enum ShadowResolution {
	VERY_LOW = 1024, ## 1024x1024
	LOW = 2048, ## 2048x2048
	MED = 4096, ## 4096x4096
	HIGH = 8192 ## 8192x8192
}
enum FOWResolution {
	LOW = 1, ## 1 pixel/metre
	MED = 2, ## 2 pixel/metre
	HIGH = 4, ## 3 pixel/metre
	VERY_HIGH = 8, ## 4 pixel/metre
}

##############
### VALUES ###
##############

## Rendering
@export_group("Rendering")
@export_subgroup("Shadows")
@export var shadow_resolution:ShadowResolution = ShadowResolution.HIGH ## Resolution of the directional shadow texture
@export var dynamic_shadow_resolution:ShadowResolution = ShadowResolution.MED ## Resolution of the dynamic shadow texture

## Fog of war
@export_group("Gameplay")
@export_subgroup("Fog Of War")
@export var fog_of_war_resolution:FOWResolution = FOWResolution.HIGH ## Resolution of the fog of war in pixels per metre


func _ready() -> void:
	ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/size", self.shadow_resolution)
	ProjectSettings.set_setting("rendering/lights_and_shadows/positional_shadow/atlas_size", self.dynamic_shadow_resolution)
