class_name PlayerManager extends Node

# Loading Script Classes
const UIManager := preload("res://scripts/managers/ui_manager.gd")
const ResourceUtils := preload("res://scripts/utilities/resource_utils.gd")

# Child controls
@export var ui_manager:UIManager

# Player information
@export_group("Resources")
@export var food:int
@export var materials:int
@export var metals:int
@export var rare_metals:int
@export var composites:int
@export var computers:int
@export var nanotech:int
@export var fuel:int
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


func _physics_process(delta:float):
	if self.gatherers_counter <= 0:
		self.gatherers_counter = self.refresh_rate_gatherers
		self.update_gatherers()
		self.update_gatherer_ui()
	self.gatherers_counter -= delta


func add_resource(amount:int, type:ResourceUtils.Res):
	if type == ResourceUtils.Res.FOOD:
		self.food += amount
	if type == ResourceUtils.Res.MATERIAL:
		self.materials += amount
	if type == ResourceUtils.Res.METAL:
		self.metals += amount
	if type == ResourceUtils.Res.RARE_METAL:
		self.rare_metals += amount
	if type == ResourceUtils.Res.COMPOSITE:
		self.composites += amount
	if type == ResourceUtils.Res.COMPUTER:
		self.computers += amount
	if type == ResourceUtils.Res.NANOTECH:
		self.nanotech += amount
	if type == ResourceUtils.Res.FUEL:
		self.fuel += amount
	print(amount, type)
	# update resources UI every time you modify the amount of resources in the stockpile
	update_resources_ui()


func remove_resource(amount:int, type:ResourceUtils.Res):
	if type == ResourceUtils.Res.FOOD:
		self.food -= amount
	if type == ResourceUtils.Res.MATERIAL:
		self.materials -= amount
	if type == ResourceUtils.Res.METAL:
		self.metals -= amount
	if type == ResourceUtils.Res.RARE_METAL:
		self.rare_metals -= amount
	if type == ResourceUtils.Res.COMPOSITE:
		self.composites -= amount
	if type == ResourceUtils.Res.COMPUTER:
		self.computers -= amount
	if type == ResourceUtils.Res.NANOTECH:
		self.nanotech -= amount
	if type == ResourceUtils.Res.FUEL:
		self.fuel -= amount
	# update resources UI every time you modify the amount of resources in the stockpile
	update_resources_ui()


func check_resources(amount:Array[int], type:Array[ResourceUtils.Res]) -> bool:
	var num:int = min(len(amount), len(type))
	var is_valid:bool = true
	# check if resources are present
	for i in range(num):
		is_valid = is_valid and check_resource(amount[i], type[i])
	return is_valid


func check_resource(amount:int, type:ResourceUtils.Res) -> bool:
	var is_valid:bool = true
	if type == ResourceUtils.Res.FOOD:
		is_valid = self.food >= amount
	elif type == ResourceUtils.Res.MATERIAL:
		is_valid = self.materials >= amount
	elif type == ResourceUtils.Res.METAL:
		is_valid = self.metals >= amount
	elif type == ResourceUtils.Res.RARE_METAL:
		is_valid = self.rare_metals >= amount
	elif type == ResourceUtils.Res.COMPOSITE:
		is_valid = self.composites >= amount
	elif type == ResourceUtils.Res.COMPUTER:
		is_valid = self.computers >= amount
	elif type == ResourceUtils.Res.NANOTECH:
		is_valid = self.nanotech >= amount
	elif type == ResourceUtils.Res.FUEL:
		is_valid = self.fuel >= amount
	return is_valid


func spend_resources(amount:Array[int], type:Array[ResourceUtils.Res]) -> bool:
	if check_resources(amount, type):
		var num:int = min(len(amount), len(type))
		for i in range(num):
			remove_resource(amount[i], type[i])
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
			if unit.gatherer.resource.get("type") == ResourceUtils.Res.FOOD:
				food_count += 1
			if unit.gatherer.resource.get("type") == ResourceUtils.Res.MATERIAL:
				material_count += 1
			if unit.gatherer.resource.get("type") == ResourceUtils.Res.METAL:
				metal_count += 1
			if unit.gatherer.resource.get("type") == ResourceUtils.Res.RARE_METAL:
				rare_metal_count += 1
	self.food_gatherers = food_count
	self.materials_gatherers = material_count
	self.metals_gatherers = metal_count
	self.rare_metals_gatherers = rare_metal_count


func update_resources_ui():
	self.ui_manager.resource_bar.set_resources([self.food, self.materials, self.metals, self.rare_metals, self.composites, self.computers, self.nanotech, self.fuel])


func update_gatherer_ui():
	self.ui_manager.resource_bar.set_gatherers([self.food_gatherers, self.materials_gatherers, self.metals_gatherers, self.rare_metals_gatherers, self.composites_gatherers, self.computers_gatherers, self.nanotech_gatherers, self.fuel_gatherers])
