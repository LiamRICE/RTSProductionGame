class_name EntityAbility extends Node

## Signals
signal modify_stat(stat:String, mod:float)

## Constants
enum STATE{DISABLED, READY, ACTIVE, COOLDOWN}

## Class properties
@export_group("Properties")
@export var ability_name:String
@export var ability_icon:Texture2D
@export_multiline var ability_description:String
@export_multiline var ability_tooltip:String

## Internal parameters
var entity:Entity = null
var current_state:STATE = STATE.DISABLED

## Initialise the ability, should be run when the initialising the unit
func init_ability(parent_entity:Entity) -> void:
	self.entity = parent_entity

## Called when an ability is activated. This function should start the "process ability" function
func start_ability() -> void:pass

## Called every frame once start_ability has been called until the ability times out
func process_ability(_delta:float) -> void: pass

## Called when the ability stops being active
func stop_ability() -> void: pass

## Called when ability is reset to it's ready to activate state
func reset_ability() -> void: pass

## To string override
func _to_string() -> String:
	return self.ability_name
