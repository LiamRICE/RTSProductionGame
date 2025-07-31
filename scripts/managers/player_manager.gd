extends Node

# Loading Script Classes
const UIManager := preload("res://scripts/managers/ui_manager.gd")
const RESOURCE := preload("res://scripts/utilities/resource_utils.gd").RESOURCE

# Child controls
@export var ui_manager:UIManager
@onready var ui_update_timer:Timer = $UIUpdateTimer

# Player information
@export_group("Resources")
@export var food:float
@export var materials:float
@export var metals:float
@export var rare_metals:float
@export var composites:float
@export var computers:float
@export var nanotech:float
@export var fuel:float
@export_group("Resource Gatherers")
@export var food_gatherers:int
@export var materials_gatherers:int
@export var metals_gatherers:int
@export var rare_metals_gatherers:int
@export var composites_gatherers:int
@export var computers_gatherers:int
@export var nanotech_gatherers:int
@export var fuel_gatherers:int

@export_group("Properties")
@export var allegiance:int = 1
@export var refresh_rate_gatherers:float = 0.5

# Counters
var gatherers_counter:float = 0.05


func _ready() -> void:
	self.food = 500
	self.materials = 500
	self.metals = 500
	self.rare_metals = 200
	
	self.ui_update_timer.wait_time = self.refresh_rate_gatherers
	self.ui_update_timer.timeout.connect(self.update_gatherers)
	
	self.update_resources_ui()


func add_resource(type:RESOURCE, amount:int):
	match type:
		RESOURCE.FOOD: self.food += amount
		RESOURCE.MATERIAL: self.materials += amount
		RESOURCE.METAL: self.metals += amount
		RESOURCE.RARE_METAL: self.rare_metals += amount
		RESOURCE.COMPOSITE: self.composites += amount
		RESOURCE.COMPUTER: self.computers += amount
		RESOURCE.NANOTECH: self.nanotech += amount
		RESOURCE.FUEL: self.fuel += amount
	print(amount, type)
	# update resources UI every time you modify the amount of resources in the stockpile
	update_resources_ui()


func remove_resource(type:RESOURCE, amount:int):
	match type:
		RESOURCE.FOOD: self.food -= amount
		RESOURCE.MATERIAL: self.materials -= amount
		RESOURCE.METAL: self.metals -= amount
		RESOURCE.RARE_METAL: self.rare_metals -= amount
		RESOURCE.COMPOSITE: self.composites -= amount
		RESOURCE.COMPUTER: self.computers -= amount
		RESOURCE.NANOTECH: self.nanotech -= amount
		RESOURCE.FUEL: self.fuel -= amount
	# update resources UI every time you modify the amount of resources in the stockpile
	update_resources_ui()


func check_resources(amount:Dictionary[RESOURCE, float]) -> bool:
	var is_valid:bool = true
	# check if resources are present
	for i in range(amount.size()):
		is_valid = is_valid and check_resource(amount.keys()[i], amount.values()[i])
	return is_valid


func check_resource(type:RESOURCE, amount:int) -> bool:
	var is_valid:bool = true
	match type:
		RESOURCE.FOOD: is_valid = self.food >= amount
		RESOURCE.MATERIAL: is_valid = self.materials >= amount
		RESOURCE.METAL: is_valid = self.metals >= amount
		RESOURCE.RARE_METAL: is_valid = self.rare_metals >= amount
		RESOURCE.COMPOSITE: is_valid = self.composites >= amount
		RESOURCE.COMPUTER: is_valid = self.computers >= amount
		RESOURCE.NANOTECH: is_valid = self.nanotech >= amount
		RESOURCE.FUEL: is_valid = self.fuel >= amount
	return is_valid


func spend_resources(amount:Dictionary[RESOURCE, float]) -> bool:
	if check_resources(amount):
		for i in range(amount.size()):
			remove_resource(amount.keys()[i], amount.values()[i])
		return true
	else:
		return false


func update_gatherers():
	var all_gatherers:Array = get_tree().get_nodes_in_group("resource_gatherer")
	var food_count:int = 0
	var material_count:int = 0
	var metal_count:int = 0
	var rare_metal_count:int = 0
	for unit:ResourceCollectorUnit in all_gatherers:
		if unit.allegiance == self.allegiance:
			if unit.gatherer.resource.get("type") == RESOURCE.FOOD:
				food_count += 1
			if unit.gatherer.resource.get("type") == RESOURCE.MATERIAL:
				material_count += 1
			if unit.gatherer.resource.get("type") == RESOURCE.METAL:
				metal_count += 1
			if unit.gatherer.resource.get("type") == RESOURCE.RARE_METAL:
				rare_metal_count += 1
	self.food_gatherers = food_count
	self.materials_gatherers = material_count
	self.metals_gatherers = metal_count
	self.rare_metals_gatherers = rare_metal_count
	
	## Update UI
	self.update_gatherer_ui()


func update_resources_ui():
	self.ui_manager.resource_bar.set_resources([self.food, self.materials, self.metals, self.rare_metals, self.composites, self.computers, self.nanotech, self.fuel])


func update_gatherer_ui():
	self.ui_manager.resource_bar.set_gatherers([self.food_gatherers, self.materials_gatherers, self.metals_gatherers, self.rare_metals_gatherers, self.composites_gatherers, self.computers_gatherers, self.nanotech_gatherers, self.fuel_gatherers])
