extends Node

## Loading Script Classes
const PlayerInterface := preload("uid://crs777xecsrt4")

## Child controls
@export var player_interface:PlayerInterface

## Internal parameters
var is_on_ui:bool = false:
	set(value):
		player_interface.is_on_ui = value
		is_on_ui = value


func _ready() -> void:
	for child_control in self.player_interface.find_children("", "Control", false, true):
		child_control.mouse_entered.connect(_on_mouse_entered)
		child_control.mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	print("Mouse Entered")
	self.player_interface.is_on_ui = true

func _on_mouse_exited() -> void:
	print("Mouse Exited")
	self.player_interface.is_on_ui = false

func register_control(control:Control) -> void:
	control.mouse_entered.connect(_on_mouse_entered)
	control.mouse_exited.connect(_on_mouse_exited)
