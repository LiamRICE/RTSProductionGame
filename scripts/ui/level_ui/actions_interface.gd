extends HBoxContainer

## Loading script classes
const UIStateUtils := preload("uid://cs16g08ckh1rw")
const ActionsContainer:Script = preload("uid://cqkd5l78qvysq")
const Selection:Script = preload("uid://cj0c8liafc0fd")

## Info bar properties
@export var container_size:Vector2i = Vector2i(5, 3)
@export var actions_container:ActionsContainer

## Info bar internal variables
var selection_list:Selection
var selection_type:UIStateUtils.SelectionType = UIStateUtils.SelectionType.NONE

## Info bar methods
func _ready() -> void:
	self.actions_container.init(container_size, _on_button_pressed)


## Executed when a button is pressed
func _on_button_pressed(index:int) -> void:
	## TODO - execute button's effect on object
	if self.selection_list.contents[0] is ProductionBuilding:
		for building in self.selection_list.contents:
			building.queue_unit(index)
			print("Queued unit")

func _on_sub_selection_changed(sub_selection:Selection, selection_type:UIStateUtils.SelectionType) -> void:
	## Assign Sub selection
	var entity:Entity
	
	## Execute code depending on the unit selected
	match selection_type:
		UIStateUtils.SelectionType.NONE when self.selection_list.contents.size() != 0: ## Nothing is selected
			for button in self.actions_container.button_list:
				button.set_button_icon(null)
				button.set_disabled(true)
				button.set_flat(true)
		
		UIStateUtils.SelectionType.UNITS:
			if self.selection_type != UIStateUtils.SelectionType.NONE:
				for button in self.actions_container.button_list:
					button.set_button_icon(null)
					button.set_disabled(true)
					button.set_flat(true)
			entity = sub_selection.contents[0]
			for index_2 in range(entity.abilities.size()):
				print(entity.abilities[index_2])
			
		
		UIStateUtils.SelectionType.BUILDINGS:
			if self.selection_type != UIStateUtils.SelectionType.NONE:
				for button in self.actions_container.button_list:
					button.set_button_icon(null)
					button.set_disabled(true)
					button.set_flat(true)
			entity = sub_selection.contents[0]
			if entity is ProductionBuilding:
				for index in range(entity.building_units.size()):
					var entity_resource:EntityResource = EntityDatabase.get_resource(entity.building_units[index])
					self.actions_container.button_list[index].icon = entity_resource.ui_icon
					self.actions_container.button_list[index].set_disabled(false)
					self.actions_container.button_list[index].set_flat(false)
			for index_2 in range(entity.abilities.size()):
				print(entity.abilities[index_2])
		
		UIStateUtils.SelectionType.UNITS_ECONOMIC:
			if self.selection_type != UIStateUtils.SelectionType.NONE:
				for button in self.actions_container.button_list:
					button.set_button_icon(null)
					button.set_disabled(true)
					button.set_flat(true)
			## TODO - List all construction orders
			pass

	## Get the selection's first item
	self.selection_list = sub_selection
	self.selection_type = selection_type
