class_name WeaponHandler extends RefCounted

const WeaponState = preload("uid://coiglhf6wydkv").WeaponState

# Data
var ammunition_handlers : Array[AmmunitionHandler] = []
var fire_mode_handlers : Array[FireMethodHandler] = []
var weapon_position_marker : Marker3D

# Current data
var selected_ammunition : AmmunitionHandler
var selected_fire_method : FireMethodHandler
var weapon_position : Marker3D

# states
var weapon_state : WeaponState = WeaponState.NONE

static func load(weapon_resource:WeaponResource, weapon_position:Marker3D) -> WeaponHandler:
	var weapon_handler = WeaponHandler.new()
	weapon_handler.weapon_position = weapon_position
	# weapon_handler.ammunition_handlers = []
	# weapon_handler.fire_mode_handlers = []
	# initialise ammunition
	for ammunition_resource in weapon_resource.ammo:
		weapon_handler.ammunition_handlers.append(AmmunitionHandler.load(ammunition_resource))
	# initialise fire methods
	for fire_method in weapon_resource.fire_methods:
		weapon_handler.fire_mode_handlers.append(FireMethodHandler.load(fire_method))
	return weapon_handler
