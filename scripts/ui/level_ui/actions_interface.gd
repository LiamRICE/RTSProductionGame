extends PanelContainer

## Loading script classes
const UIStateUtils := preload("uid://cs16g08ckh1rw")
const ActionsContainer:Script = preload("uid://cqkd5l78qvysq")

## Info bar properties
@export var container_size:Vector2i = Vector2i(5, 3)
@export var actions_container:ActionsContainer

## Info bar internal variables
var selection_list:Array[Entity]

## Info bar methods
func _ready() -> void:
	self.actions_container.init(container_size, _on_button_pressed)


## Executed when a button is pressed
func _on_button_pressed(index:int) -> void:
	print("Pressed : ", index)
	## TODO - execute button's effect on object
	selection_list[0].queue_unit(index)

func _on_player_interface_selection_changed(sub_selection: Array[Entity], selection_type: UIStateUtils.SelectionType) -> void:
	print("Selection changed")
	
	## Execute code depending on the unit selected
	match selection_type:
		UIStateUtils.SelectionType.NONE: ## Nothing is selected
			for button in self.actions_container.button_list:
				button.set_button_icon(null)
				button.set_disabled(true)
				button.set_flat(true)
			return
		
		UIStateUtils.SelectionType.UNITS:
			pass
		
		UIStateUtils.SelectionType.BUILDINGS:
			pass
		
		UIStateUtils.SelectionType.UNITS_ECONOMIC:
			pass

	## Get the selection's first item
	var item:Entity = sub_selection[0]
	print("Button icon assigned")
	if item is ProductionBuilding:
		for index in range(item.building_units.size()):
			var unit:Unit = item.building_units[index].entity_instance.instantiate()
			self.actions_container.button_list[index].icon = unit.icon
			self.actions_container.button_list[index].set_disabled(false)
			self.actions_container.button_list[index].set_flat(false)
			unit.free()
	self.selection_list = sub_selection
