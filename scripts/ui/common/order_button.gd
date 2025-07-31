class_name OrderButton extends Button

## Signals
signal pressed_order(order:Order, index:int)

## Properties
var order:Order = null

## Connects itself to the signal emitting it's index on ready
func _ready() -> void:
	set_expand_icon(true)
	set_mouse_filter(Control.MOUSE_FILTER_PASS)
	self.pressed.connect(_on_pressed)

## Emits a signal when pressed
func _on_pressed() -> void:
	self.pressed_index.emit(self.order, self.order_index)

func set_order(order:Order) -> void:
	self.order = order
