extends TabContainer

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
		button.set_disabled(false)
		button.pressed_index.connect(self._on_button_pressed)
		self.button_list.append(button)
		self.abilities_build_container.add_child(button)

## Executed when the selection changes
func _on_selection_changed(new_selection:Array[Entity], is_unit:bool) -> void:
	print(new_selection == self.selection_list)
	
	if new_selection.size() == 0:
		return
	## Get the selection's first item
	var item:Entity = new_selection[0]
	print("Button icon assigned")
	if not is_unit and item is ProductionBuilding:
		for index in range(item.building_units.size()):
			var unit:Unit = item.building_units[index].instantiate()
			self.button_list[index].icon = unit.icon
			self.button_list[index].set_disabled(false)
			unit.free()
	self.selection_list = new_selection

## Executed when a button is pressed
func _on_button_pressed(index:int) -> void:
	print("Pressed : ", index)
	## TODO - execute button's effect on object
	print(selection_list[0].get_class())
