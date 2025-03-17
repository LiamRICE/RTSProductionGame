class_name Entity extends Node3D

## Common Entity nodes
@export var body:PhysicsBody3D

## Common Entity properties
@export_group("Properties")
@export var health:float
@export var production_cost:float ## Cost of production for the unit in seconds
@export var allegiance:int = 0
@export var icon:Texture2D

## Common Entity states
@export_group("States")
@export var is_damageable:bool
@export var is_selectable:bool


## Entity Methods ##

## Function called when entity takes damage
func receive_damage(dmg:float) -> void:
	health -= dmg
	if health <= 0:
		self._on_destroyed()

## Function called when entity is selected.
## Returns true if the object is selectable. Other functionality can be added on top of this.
func select() -> bool:
	return is_selectable

func deselect() -> void:
	return

## Updates the allegiance of entities and executes any code required on an allegiance change
func _update_allegiance(new_allegiance:int) -> void:
	self.allegiance = new_allegiance

## Code to execute when unit is destroyed
func _on_destroyed() -> void:
	self.queue_free()
