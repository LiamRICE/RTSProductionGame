extends TabContainer

# Loading script classes
const UIStateUtils := preload("res://scripts/utilities/ui_state_utils.gd")

## Info bar properties
@export var abilities_build_container_size:Vector2i = Vector2i(5, 3)
@export var abilities_build_container:GridContainer

## Info bar internal variables
var selection_list:Array[Entity]
var types_array:Array[String]
var button_list:Array[IntButton] = []

## Info bar methods
func _ready() -> void:
	for i in range(self.abilities_build_container_size.x * self.abilities_build_container_size.y):
		var button:IntButton = IntButton.new()
		button.set_custom_minimum_size(Vector2(100, 100))
		button.index = i
		button.set_disabled(true)
		button.pressed_index.connect(self._on_button_pressed)
		self.button_list.append(button)
		self.abilities_build_container.add_child(button)


## Executed when a button is pressed
func _on_button_pressed(index:int) -> void:
	print("Pressed : ", index)
	## TODO - execute button's effect on object
	selection_list[0].queue_unit(index)


func _on_player_interface_selection_changed(selection: Array[Entity], selection_type: UIStateUtils.SelectionType) -> void:
	print("Selection changed")
	if selection.size() == 0:
		for button in button_list:
			button.set_disabled(true)
			button.set_button_icon(null)
		return
	## Get the selection's first item
	var item:Entity = selection[0]
	print("Button icon assigned")
	if selection_type == UIStateUtils.SelectionType.BUILDINGS and item is ProductionBuilding:
		for index in range(item.building_units.size()):
			var unit:Unit = item.building_units[index].entity_instance.instantiate()
			self.button_list[index].icon = unit.icon
			self.button_list[index].set_disabled(false)
			unit.free()
	self.selection_list = selection
