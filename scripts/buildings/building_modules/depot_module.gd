extends Node

const ResourceUtils := preload("res://scripts/utilities/resource_utils.gd")
const PlayerManager := preload("res://player_manager.gd")

func drop_off(player_manager:PlayerManager, amount:int, type:ResourceUtils.Res):
	player_manager.add_resource(amount, type)
