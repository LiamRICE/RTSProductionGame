extends Node

## Loading Script Classes
const PerformanceMonitor:Script = preload("uid://d2jsctbdnmps8")
const PlayerInterface:Script = preload("uid://crs777xecsrt4")
const GroupActionsPanel:Script = preload("uid://cbkqp04y5bfn5")
const ResourceBar:Script = preload("uid://bih6yn0b7x8my")

## Child controls
@export var performance_monitor:PerformanceMonitor
@export var player_interface:PlayerInterface
@export var actions_panel:GroupActionsPanel
@export var resource_bar:ResourceBar

var is_on_ui:bool = false


func _ready() -> void:
	## Register UI elements for mouse hover states
	self.performance_monitor.mouse_entered.connect(_on_mouse_entered)
	self.performance_monitor.mouse_exited.connect(_on_mouse_exited)
	
	self.actions_panel.mouse_entered.connect(_on_mouse_entered)
	self.actions_panel.mouse_exited.connect(_on_mouse_exited)
	
	self.resource_bar.mouse_entered.connect(_on_mouse_entered)
	self.resource_bar.mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	self.is_on_ui = true
	print("Mouse Entered ", self.is_on_ui)

func _on_mouse_exited() -> void:
	self.is_on_ui = false
	print("Mouse Exited ", self.is_on_ui)

func register_control(control:Control) -> void:
	control.mouse_entered.connect(_on_mouse_entered)
	control.mouse_exited.connect(_on_mouse_exited)
