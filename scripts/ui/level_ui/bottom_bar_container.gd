class_name InfoBar extends HBoxContainer

## Info bar properties
@export var unit_build_container_size:Vector2i = Vector2i(5, 3)
@export var unit_build_container:GridContainer

## Info bar internal variables
var selection_list:Array[Entity]
var button_list:Array[IntButton] = []

## Info bar methods
func _ready() -> void:
	for i in range(self.unit_build_container_size.x * self.unit_build_container_size.y):
		var button:IntButton = IntButton.new()
		button.set_custom_minimum_size(Vector2(100, 100))
		button.index = i
		self.button_list.append(button)
		self.unit_build_container.add_child(button)

## Executed when the selection changes
func _on_selection_changed(new_selection:Array[Entity], is_unit:bool) -> void:
	if new_selection == self.selection_list:
		print("true")
	
	if self.selection_list.size() > 0:
		print(self.button_list[0].pressed_index.get_connections())
		self.button_list[0].pressed_index.disconnect(selection_list[0].queue_unit)
		print(self.button_list[0].pressed_index.get_connections())
	
	if new_selection.size() == 0:
		return
	## Get the selection's first item
	var item:Entity = new_selection[0]
	print("Button icon assigned")
	if not is_unit and item is ProductionBuilding:
		for index in range(item.building_units.size()):
			var unit:Unit = item.building_units[index].instantiate()
			button_list[index].icon = unit.icon
			button_list[index].pressed_index.connect(item.queue_unit)
			unit.free()
	self.selection_list = new_selection

## Executed when a button is pressed
func _on_button_pressed(index:int) -> void:
	print("Pressed : ", index)
