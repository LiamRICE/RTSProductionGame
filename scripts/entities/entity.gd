class_name Entity extends Node3D

## Constants
const Vector3SecondOrderDynamics:Script = preload("uid://dk0dxwf2vi886")
const QuaternionSecondOrderDynamics:Script = preload("uid://2qt0fxo8oqaa")
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
@export var current_shield:float ## The current amount of shields the unit has
@export var vision_texture:Texture2D = preload("uid://btgh61vpoq8b3") ## Texture used to represent the sight of the unit. Scaled by sight stat.
@export var allegiance:int = 0

## Animation Parameters
@export_group("Animation Parameters")
var target_position:Vector3 ## The commanded linear position along the path
@export_subgroup("Position Interpolation")
@export var position_frequency:float = 1.0 ## Must be positive, a higher frequency implies a faster reaction to the stimulus
@export var position_damping_coeficient:float = 1.0 ## Must be positive, between 0 and 1 is underdamped, 1 is critically damped and more that 1 is overdamped
@export var position_response_coeficient:float = 0.0 ## Less than 0 is anticipation, 0 is smooth acceleration and above 0 starts with some impulse
@export_subgroup("Rotation Interpolation")
@export var rotation_frequency:float = 2.0 ## Must be positive, a higher frequency implies a faster reaction to the stimulus
@export var rotation_damping_coeficient:float = 1.0 ## Must be positive, between 0 and 1 is underdamped, 1 is critically damped and more that 1 is overdamped
@export var rotation_response_coeficient:float = 0.0 ## Less than 0 is anticipation, 0 is smooth acceleration and above 0 starts with some impulse
var position_dynamics:Vector3SecondOrderDynamics
var rotation_dynamics:QuaternionSecondOrderDynamics

@export_group("Abilities")
@export var abilities:Array[EntityAbility]

## Common Entity states
@export_group("States")
@export var is_damageable:bool = true
@export var is_selectable:bool = true
@export var is_mobile:bool = false

## Entity internal orders
var order_queue:Array[Order] = []
var default_order:Script = Order
var active_order:Order = null
var is_default_order:bool = true


""" ENTITY METHODS """

func _ready() -> void:
	## Fetch unit's statistics from the database
	self.entity_statistics = EntityDatabase.get_stats(self.entity_id)
	
	## Set unit health to max
	self.current_health = self.entity_statistics[STATS.HEALTH]
	self.current_shield = self.entity_statistics[STATS.SHIELD]
	
	## Initialise orders
	self.active_order = self.default_order.new()
	
	## Start abilities
	for ability in self.abilities:
		ability.init_ability(self)

func _physics_process(delta) -> void:
	print("Active Order : ", self.active_order)
	## Execute current order
	self.active_order.process(self, delta)
	if self.active_order is MoveOrder:
		print(active_order._target_position)

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
	## Inform the event bus of imminent death
	EventBus.on_entity_destroyed.emit(self)
	## Remove unit
	self.queue_free()


""" MANAGE ORDERS """

func add_order(order:Order, is_shift:bool) -> void:
	## Add order to queue or overwrite queue with new order
	if is_shift:
		self.order_queue.push_back(order)
		if self.is_default_order:
			self.is_default_order = false
			self.active_order.abort()
	else:
		self.order_queue.resize(1)
		self.order_queue[0] = order
		self.active_order.abort()

func _order_aborted() -> void:
	print("Current order was aborted")
	self.active_order = self.order_queue.pop_front()
	if self.active_order == null:
		self.active_order = self.default_order.new()
		self.is_default_order = true

func _order_completed() -> void:
	print("Current order was completed")
	self.active_order = self.order_queue.pop_front()
	if self.active_order == null:
		self.active_order = self.default_order.new()
		self.is_default_order = true

func _order_failed() -> void:
	print("Current order failed")
	self.active_order = self.order_queue.pop_front()
	if self.active_order == null:
		self.active_order = self.default_order.new()
		self.is_default_order = true

""" ABILITY METHODS """

## Triggered by an ability that modifies an entity's statistic
func ability_stat_modification(stat:STATS, modifier:float) -> void:
	self.entity_statistics[stat] += modifier
	if stat == STATS.SHIELD or stat == STATS.ATTACK_SPEED or stat == STATS.ATTACK_RANGE or stat == STATS.SIGHT:
		self.update_offline_stat(stat)

## Triggered by an ability that overrides an entity's statistic
func ability_stat_override(stat:STATS, value:float) -> void:
	self.entity_statistics[stat] = value
	if stat == STATS.SHIELD or stat == STATS.ATTACK_SPEED or stat == STATS.ATTACK_RANGE or stat == STATS.SIGHT:
		self.update_offline_stat(stat)


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

func update_offline_stat(stat:STATS) -> void:
	match stat:
		STATS.SHIELD:
			pass
		STATS.ATTACK_SPEED:
			pass
		STATS.SIGHT:
			self.fog_of_war_sprite.scale = (Vector2.ONE / self.vision_texture.get_size()) * self.entity_statistics[STATS.SIGHT] * 2 * GameSettings.fog_of_war_resolution
		STATS.ATTACK_RANGE:
			pass
