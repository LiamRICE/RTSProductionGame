class_name FireMethodResource extends Resource

@export_group("General")
@export var name : String
@export_multiline var description : String
@export_multiline var ui_tooltip : String

@export_group("Statistics")
@export var burst_size : int
@export var aim_time_multiplier : float
@export var accuracy_multiplier : float # for direct target
@export var circular_area_probable_multiplier : float # for area target
@export var range_multiplier : float
