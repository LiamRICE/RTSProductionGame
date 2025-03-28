class_name PlayerManager extends Node

const UIManager := preload("res://scripts/managers/ui_manager.gd")
const resource_utils:GDScript = preload("res://scripts/utilities/resource_utils.gd")

@export_group("Resources")
@export var food:int
@export var materials:int
@export var metals:int
@export var rare_metals:int
@export_group("Resource Gatherers")
@export var food_gatherers:int
@export var materials_gatherers:int
@export var metals_gatherers:int
@export var rare_metals_gatherers:int

@export_group("Properties")
@export var allegiance:int = 1


func add_resource(amount:int, type:resource_utils.Res):
	if type == resource_utils.Res.FOOD:
		self.food += amount
	if type == resource_utils.Res.MATERIAL:
		self.materials += amount
	if type == resource_utils.Res.METAL:
		self.metals += amount
	if type == resource_utils.Res.RARE_METAL:
		self.rare_metals += amount


func update_gatherers():
	var all_gatherers:Array = get_tree().get_nodes_in_group("resource_gatherer")
	var food_count:int = 0
	var material_count:int = 0
	var metal_count:int = 0
	var rare_metal_count:int = 0
	for unit:ResourceCollectorUnit in all_gatherers:
		if unit.allegiance == self.allegiance:
			if unit.gatherer.resource.get("type") == resource_utils.Res.FOOD:
				food_count += 1
			if unit.gatherer.resource.get("type") == resource_utils.Res.MATERIAL:
				material_count += 1
			if unit.gatherer.resource.get("type") == resource_utils.Res.METAL:
				metal_count += 1
			if unit.gatherer.resource.get("type") == resource_utils.Res.RARE_METAL:
				rare_metal_count += 1


func update_resources_ui():
	pass


func update_gatherer_ui():
	pass
