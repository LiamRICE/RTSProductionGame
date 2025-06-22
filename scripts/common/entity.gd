class_name Entity extends Node3D

const ResourceUtils := preload("uid://c4mlh3p0sd0vd")
const ENTITY_LIST := preload("uid://dki6gr7rrru2p").ENTITY_LIST

## Common Entity nodes
@export var body:PhysicsBody3D
var fog_of_war_sprite:Sprite2D

## Necessary Entity declaration
@export_group("Properties")
@export var entity_name:String = ""
@export var entity_id:ENTITY_LIST = ENTITY_LIST.DEFAULT

## Common Entity properties
@export_group("Statistics")
@export var entity_statistics:EntityStats = EntityStats.new()
@export var current_health:float ## The current health the unit has
@export var health:float ## The max health the unit can have
@export var production_cost:float ## Cost of production for the unit in seconds
@export var vision_radius:float ## Used to scale the vision sprite
@export var vision_texture:Texture2D = preload("uid://btgh61vpoq8b3") ## Texture used to represent the sight of the unit. Scaled by vision_radius.
@export var allegiance:int = 0

@export_group("Abilities")
@export var abilities:Array[EntityAbility]

@export_group("Value")
@export var resource_cost_amount:Array[int]
@export var resource_cost_type:Array[ResourceUtils.Res]

## Common Entity states
@export_group("States")
@export var is_damageable:bool = true
@export var is_selectable:bool = true
@export var is_mobile:bool = false


""" Entity Methods """

func _ready() -> void:
	## Set unit health to max
	self.current_health = self.health
	
	## Initialise abilities
	for ability in self.abilities:
		ability.init_ability(self)

## Function called when entity takes damage
func receive_damage(dmg:float) -> void:
	current_health -= dmg
	if current_health <= 0:
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

## Triggered by an ability
func _on_ability_stat_modification(stat:String, value_mod:float) -> void:
	self.set(stat, self.get(stat) + value_mod)

""" FOG OF WAR METHODS """

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
