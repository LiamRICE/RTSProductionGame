extends GridContainer

## Grid internal variables
var types_array:Array[String]
var button_list:Array[Button] = []


func init(container_size:Vector2i, index_button_callback:Callable, order_button_callback:Callable) -> void:
	for i in range(container_size.x * (container_size.y - 1)):
		var button:IntButton = IntButton.new()
		button.set_custom_minimum_size(Vector2(100, 100))
		button.index = i
		button.set_disabled(true)
		button.set_flat(true)
		button.set_focus_mode(Control.FOCUS_NONE)
		button.pressed_index.connect(index_button_callback)
		self.button_list.append(button)
		self.add_child(button)
	for i in range(container_size.x):
		var button:OrderButton = OrderButton.new()
		button.set_custom_minimum_size(Vector2(100, 100))
		button.set_disabled(true)
		button.set_flat(true)
		button.set_focus_mode(Control.FOCUS_NONE)
		button.pressed_order.connect(order_button_callback)
		self.button_list.append(button)
		self.add_child(button)
