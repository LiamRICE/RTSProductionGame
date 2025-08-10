extends HBoxContainer

## Loading script classes
const UIStateUtils := preload("uid://cs16g08ckh1rw")
const ActionsContainer:Script = preload("uid://cqkd5l78qvysq")
const Selection:Script = preload("uid://cj0c8liafc0fd")

## Constants
const ORDER_REQUEST := preload("uid://dki6gr7rrru2p").ORDER_REQUEST

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
func _on_button_pressed(order:Script, index:int, request:ORDER_REQUEST) -> void:
	## TODO - execute button's effect on object
	print("Signal dispatched for ", order.get_global_name())
	EventBus.on_ui_order_dispatch.emit(self.selection_list, order, index, request)

func _on_sub_selection_changed(sub_selection:Selection, selection_type:UIStateUtils.SelectionType) -> void:
	## Assign Sub selection
	var entity:Entity
	
	## Execute code depending on the unit selected
	match selection_type:
		UIStateUtils.SelectionType.NONE when self.selection_list.contents.size() != 0: ## Nothing is selected
			for button in self.actions_container.button_list:
				button.set_button_icon(null)
				button.set_tooltip_text("")
				button.set_disabled(true)
				button.set_flat(true)
		
		UIStateUtils.SelectionType.UNITS:
			if self.selection_type != UIStateUtils.SelectionType.NONE:
				for button in self.actions_container.button_list:
					button.set_button_icon(null)
					button.set_tooltip_text("")
					button.set_disabled(true)
					button.set_flat(true)
			entity = sub_selection.contents[0]
			for index in range(entity.abilities.size()):
				var entity_ability:EntityAbility = entity.abilities[index]
				if entity_ability is EntityPassiveAbility:
					self.actions_container.button_list[index + self.container_size.x * 2].icon = entity_ability.ability_icon
					self.actions_container.button_list[index + self.container_size.x * 2].tooltip_text = entity_ability.ability_tooltip
					self.actions_container.button_list[index + self.container_size.x * 2].set_disabled(true)
					self.actions_container.button_list[index + self.container_size.x * 2].set_flat(false)
				else:
					self.actions_container.button_list[index + self.container_size.x * 2].icon = entity_ability.ability_icon
					self.actions_container.button_list[index + self.container_size.x * 2].tooltip_text = entity_ability.ability_tooltip
					self.actions_container.button_list[index + self.container_size.x * 2].set_disabled(false)
					self.actions_container.button_list[index + self.container_size.x * 2].set_flat(false)
					#print(entity.abilities[index])
			
		
		UIStateUtils.SelectionType.BUILDINGS:
			if self.selection_type != UIStateUtils.SelectionType.NONE:
				for button in self.actions_container.button_list:
					button.set_button_icon(null)
					button.set_tooltip_text("")
					button.set_disabled(true)
					button.set_flat(true)
			entity = sub_selection.contents[0]
			if entity.has_node("ProductionModule"):
				var production_module:ProductionModule = entity.get_node("ProductionModule")
				for index in range(production_module.building_entities.size()):
					var offset = index + (self.container_size.x * 2)
					var entity_resource:EntityResource = EntityDatabase.get_resource(production_module.building_entities[index])
					self.actions_container.button_list[offset].icon = entity_resource.ui_icon
					self.actions_container.button_list[offset].tooltip_text = entity_resource.ui_tooltip
					self.actions_container.button_list[offset].set_disabled(false)
					self.actions_container.button_list[offset].set_flat(false)
					self.actions_container.button_list[offset].set_variables(ProductionOrder, production_module.building_entities[index], ORDER_REQUEST.ENTITY_ID)
			for index_2 in range(entity.abilities.size()):
				print(entity.abilities[index_2])
		
		UIStateUtils.SelectionType.UNITS_ECONOMIC:
			if self.selection_type != UIStateUtils.SelectionType.NONE:
				for button in self.actions_container.button_list:
					button.set_button_icon(null)
					button.set_tooltip_text("")
					button.set_disabled(true)
					button.set_flat(true)
			## TODO - List all construction orders
			pass

	## Assign the sub selection to be the current selection
	self.selection_list = sub_selection
	self.selection_type = selection_type
