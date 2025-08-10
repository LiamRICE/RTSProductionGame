class_name OrderData extends Resource

## Constants
const ORDER_REQUEST := preload("uid://dki6gr7rrru2p").ORDER_REQUEST

@export var order:Script = null
@export var order_icon:Texture2D = null
@export_multiline var order_tooltip:String = ""
@export var order_request:ORDER_REQUEST = ORDER_REQUEST.NONE

func _init(script:Script = null, icon:Texture2D = null, tooltip:String = "", request:ORDER_REQUEST = ORDER_REQUEST.NONE) -> void:
	self.order = script
	self.order_icon = icon
	self.order_tooltip = tooltip
	self.order_request = request
