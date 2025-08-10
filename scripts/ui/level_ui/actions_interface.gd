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
	assert(sub_selection.contents.size() > 0 or selection_type == UIStateUtils.SelectionType.NONE)
	## Assign Sub selection
	if selection_type == UIStateUtils.SelectionType.NONE:
		self.selection_list = sub_selection
		self.selection_type = selection_type
		for button in self.actions_container.button_list:
			button.set_inactive()
		return
	
	## Reset all the buttons to inactive
	for button in self.actions_container.button_list:
		button.set_inactive()
	var entity:Entity = sub_selection.contents[0]
	
	if entity.is_mobile: ## Assign move orders if the entity is mobile
		for index in range(EntityDatabase.move_orders.size()):
			var move_order_data:OrderData = EntityDatabase.get_move_order(index)
			self.actions_container.button_list[index].set_active_order(move_order_data)
			self.actions_container.button_list[index].set_variables(move_order_data.order, index, ORDER_REQUEST.POSITION)
	
	if entity.has_node("ProductionModule"): ## Assign production buttons if the entity has a production module
		var production_module:ProductionModule = entity.get_node("ProductionModule")
		for index in range(production_module.building_entities.size()):
			var offset = index + self.container_size.x
			var entity_resource:EntityResource = EntityDatabase.get_resource(production_module.building_entities[index])
			self.actions_container.button_list[offset].set_active_entity_resource(entity_resource)
			self.actions_container.button_list[offset].set_variables(ProductionOrder, production_module.building_entities[index], ORDER_REQUEST.ENTITY_ID)
	
	var spec_order_index:int = 0
	if entity.has_node("InventoryModule"): ## Assign gathering orders if the unit has an inventory module
		var inventory_module:InventoryModule = entity.get_node("InventoryModule")
		for index in range(inventory_module.logistics_orders.size()):
			var offset = self.container_size.x * 2
			self.actions_container.button_list[offset].set_active_order(inventory_module.logistics_orders[index])
			self.actions_container.button_list[offset].set_variables(inventory_module.logistics_orders[index].order, index, inventory_module.logistics_orders[index].order_request)
			spec_order_index += 1
	
	for index in range(entity.get_entity_orders().size()):
		var offset = index + spec_order_index + self.container_size.x * 2
		self.actions_container.button_list[offset].set_active_order(entity.get_entity_orders()[index])
		self.actions_container.button_list[offset].set_variables(entity.get_entity_orders()[index].order, index, entity.get_entity_orders()[index].order_request)

	## Assign the sub selection to be the current selection
	self.selection_list = sub_selection
	self.selection_type = selection_type
