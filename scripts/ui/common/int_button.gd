class_name IntButton extends Button

## Signals
signal pressed_index(index:int)

## Properties
@export var index:int = 0

## Connects itself to the signal emitting it's index on ready
func _ready() -> void:
	set_expand_icon(true)
	self.pressed.connect(_on_pressed)

## Emits a signal when pressed
func _on_pressed() -> void:
	self.pressed_index.emit(self.index)
