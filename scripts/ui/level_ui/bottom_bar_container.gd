class_name InfoBar extends HBoxContainer

## Info bar properties
@export var unit_build_container_size:Vector2i = Vector2i(5, 3)
@export var unit_build_container:GridContainer

## Info bar internal variables
var selection_list:Array[Entity] = []
var button_list:Array[IntButton] = []

## Info bar methods
func _ready() -> void:
	for i in range(self.unit_build_container_size.x * self.unit_build_container_size.y):
		var button:IntButton = IntButton.new()
		button.set_custom_minimum_size(Vector2(100, 100))
		button.index = i
		button.pressed_index.connect(_on_button_pressed)
		self.button_list.append(button)
		self.unit_build_container.add_child(button)

## Executed when a button is pressed
func _on_button_pressed(index:int) -> void:
	print("Pressed : ", index)
