class_name OrderButton extends Button

## Constants
const ORDER_REQUEST := preload("uid://dki6gr7rrru2p").ORDER_REQUEST

## Signals
signal pressed_order(order:Script, index:int, request:ORDER_REQUEST)

## Properties
var order:Script = null
var index_in_array:int = 0
var request:ORDER_REQUEST = ORDER_REQUEST.NONE


func _init(order:Script = null, index:int = 0, request:ORDER_REQUEST = ORDER_REQUEST.NONE) -> void:
	self.order = order
	self.index_in_array = index
	self.request = request

## Connects itself to the signal emitting it's index on ready
func _ready() -> void:
	set_expand_icon(true)
	set_mouse_filter(Control.MOUSE_FILTER_PASS)
	self.pressed.connect(_on_pressed)

## Emits a signal when pressed
func _on_pressed() -> void:
	self.pressed_order.emit(self.order, self.index_in_array, self.request)

func set_variables(order:Script, index:int, request:ORDER_REQUEST = ORDER_REQUEST.NONE) -> void:
	self.order = order
	self.index_in_array = index
	self.request = request
