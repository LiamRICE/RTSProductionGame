class_name Entity extends Node3D

## Common Entity nodes
@export var body:PhysicsBody3D
var fog_of_war_sprite:Sprite2D

## Common Entity properties
@export_group("Properties")
@export var health:float
@export var max_health:float
@export var production_cost:float ## Cost of production for the unit in seconds
@export var vision_radius:float ## Used to scale the vision sprite
@export var vision_texture:Texture2D = preload("uid://btgh61vpoq8b3") ## Texture used to represent the sight of the unit. Scaled by vision_radius.
@export var allegiance:int = 0
@export var icon:Texture2D

## Common Entity states
@export_group("States")
@export var is_damageable:bool = true
@export var is_selectable:bool = true
@export var is_mobile:bool = false


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

func initialise_fog_of_war_propagation() -> Sprite2D:
	if is_mobile:
		self.add_to_group("fog_of_war_propagators")
	
	## Create the FoW sprite, assign it's texture and return it to the calling object
	self.fog_of_war_sprite = Sprite2D.new()
	self.fog_of_war_sprite.scale = (Vector2.ONE / self.vision_texture.get_size()) * vision_radius * 2
	self.fog_of_war_sprite.texture = self.vision_texture
	return self.fog_of_war_sprite

func update_visibility(position_2d:Vector2, fow_image:Image):
	if fow_image.get_pixel(roundi(position_2d.x), roundi(position_2d.y)).r > 0.1:
		self.visible = true
	else:
		self.visible = false

## Updates the allegiance of entities and executes any code required on an allegiance change
func _update_allegiance(new_allegiance:int) -> void:
	self.allegiance = new_allegiance

## Code to execute when unit is destroyed
func _on_destroyed() -> void:
	self.queue_free()
