class_name WeaponModule extends Node

const WeaponState = preload("uid://coiglhf6wydkv").WeaponState

@export_group("Weapons")
@export var weapon_resource_array : Array[WeaponResource]
@export var weapon_position_array : Array[Marker3D]
@export_group("Orders")
@export var weapon_orders : Array[OrderData]

var weapon_handlers : Array[WeaponHandler]
var weapon_state : WeaponState = WeaponState.NONE

func _ready() -> void:
	# loads weapon handlers from weapon resources
	self.weapon_handlers = []
	for i in range(min(len(weapon_resource_array), len(weapon_position_array))):
		self.weapon_handlers.append(WeaponHandler.load(weapon_resource_array[i], weapon_position_array[i]))
