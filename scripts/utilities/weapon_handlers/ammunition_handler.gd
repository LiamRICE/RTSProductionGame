class_name AmmunitionHandler extends Node


var ammunition_resource : AmmoResource


static func load(ammunition_resource : AmmoResource) -> AmmunitionHandler:
	var ammo_handler = AmmunitionHandler.new()
	ammo_handler.ammunition_resource = ammunition_resource
	return ammo_handler
