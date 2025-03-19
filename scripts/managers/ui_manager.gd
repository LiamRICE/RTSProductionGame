extends Node

## Constants
const PlayerInterface := preload("res://scenes/player/player_interface.gd")
const OrdersInterface := preload("res://scripts/ui/level_ui/bottom_bar_container.gd")

## Child controls
@export var player_interface:PlayerInterface
@export var orders_interface:OrdersInterface

## Internal parameters
var is_on_ui:bool = false:
	set(value):
		player_interface.is_on_ui = value
		is_on_ui = value


func _ready() -> void:
	self.player_interface.selection_changed.connect(self.orders_interface._on_selection_changed)
	self.player_interface.mouse_entered.connect(self._on_mouse_entered)
	self.player_interface.mouse_exited.connect(self._on_mouse_exited)
	self.orders_interface.mouse_entered.connect(self._on_mouse_entered)
	self.orders_interface.mouse_exited.connect(self._on_mouse_exited)

func _on_mouse_entered() -> void:
	self.is_on_ui = true
	print(is_on_ui)

func _on_mouse_exited() -> void:
	self.is_on_ui = false
	print(is_on_ui)
