class_name Entity extends Node3D

signal received_damage(health:int)

## Constants
const RESOURCE := preload("uid://c4mlh3p0sd0vd").RESOURCE
const ENTITY_ID := preload("uid://dki6gr7rrru2p").ENTITY_ID
const STATS := preload("uid://dki6gr7rrru2p").STATS

## Common Entity nodes
@export var body:PhysicsBody3D
var fog_of_war_sprite:Sprite2D

## Necessary Entity declaration
@export_group("Properties")
@export var entity_id:ENTITY_ID

## Common Entity properties
@export_group("Statistics")
@export var entity_statistics:Dictionary[STATS, float]
@export var current_health:float ## The current health the unit has
@export var vision_texture:Texture2D = preload("uid://btgh61vpoq8b3") ## Texture used to represent the sight of the unit. Scaled by sight stat.
@export var allegiance:int = 0

@export_group("Abilities")
@export var abilities:Array[EntityAbility]

## Common Entity states
@export_group("States")
@export var is_damageable:bool = true
@export var is_selectable:bool = true
@export var is_mobile:bool = false


""" ENTITY METHODS """

func _ready() -> void:
	## Set unit health to max
	self.entity_statistics = EntityDatabase.get_stats(self.entity_id)
	
	## Initialise abilities
	for ability in self.abilities:
		ability.init_ability(self)
	
	## Initialise health
	self.current_health = self.entity_statistics.get(0)
	print("Starting health = ", self.current_health)

## Function called when entity is selected.
## Returns true if the object is selectable. Other functionality can be added on top of this.
func select() -> bool:
	return is_selectable

func deselect() -> void:
	return

## Updates the allegiance of entities and executes any code required on an allegiance change
func _update_allegiance(new_allegiance:int) -> void:
	self.allegiance = new_allegiance

""" COMBAT METHODS """

## Function called when entity takes damage - returns true if the unit is destroyed
func receive_damage(dmg:float) -> bool:
	current_health -= dmg
	if current_health <= 0:
		self._on_destroyed()
		return true
	else:
		received_damage.emit(current_health)
		return false

func is_hit(accuracy:float) -> bool:
	# TODO - update accuracy based on this unit's cover, etc...
	if randf() <= accuracy:
		return true
	else:
		return false

## Code to execute when unit is destroyed
func _on_destroyed() -> void:
	## Remove FOW effect nodes
	self.remove_from_group("fog_of_war_propagators")
	if self.fog_of_war_sprite != null:
		self.fog_of_war_sprite.queue_free()
	
	## Remove unit
	self.queue_free()

""" ABILITY METHODS """

## Triggered by an ability
func _on_ability_stat_modification(stat:STATS, value_mod:float) -> void:
	self.modify_stat(stat, value_mod)

## Triggered by an ability
func _on_ability_stat_override(stat:STATS, value:float) -> void:
	self.update_stat(stat, value)

""" FOG OF WAR METHODS """

func initialise_fog_of_war_propagation() -> Sprite2D:
	if is_mobile:
		self.add_to_group("fog_of_war_propagators")
	
	## Create the FoW sprite, assign it's texture and return it to the calling object
	self.fog_of_war_sprite = Sprite2D.new()
	self.fog_of_war_sprite.scale = (Vector2.ONE / self.vision_texture.get_size()) * self.entity_statistics[STATS.SIGHT] * 2
	self.fog_of_war_sprite.texture = self.vision_texture
	return self.fog_of_war_sprite

func update_visibility(position_2d:Vector2, fow_image:Image):
	if fow_image.get_pixel(roundi(position_2d.x), roundi(position_2d.y)).r > 0.1:
		self.visible = true
	else:
		self.visible = false

""" STATS METHODS """

func update_stat(stat:STATS, value:float) -> void:
	self.entity_statistics[stat] = value

func modify_stat(stat:STATS, modifier:float) -> void:
	self.entity_statistics[stat] += modifier
