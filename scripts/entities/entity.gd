class_name Entity extends Node3D

signal received_damage(health:int)

## Constants
const Vector3SecondOrderDynamics:Script = preload("uid://dk0dxwf2vi886")
const QuaternionSecondOrderDynamics:Script = preload("uid://2qt0fxo8oqaa")
const RESOURCE := preload("uid://c4mlh3p0sd0vd").RESOURCE
const ENTITY_ID := preload("uid://dki6gr7rrru2p").ENTITY_ID
const ORDER_REQUEST := preload("uid://dki6gr7rrru2p").ORDER_REQUEST
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

## Legal Orders
@export_group("Entity Orders")
@export var entity_specific_orders:Array[OrderData] ## Specific entity abilities and orders

## Common Entity states
@export_group("States")
@export var is_damageable:bool = true
@export var is_selectable:bool = true
@export var is_mobile:bool = false
@export var is_military:bool = false
var is_awaiting_deletion:bool = false

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
	self.active_order = self.default_order.new(self)

func _physics_process(delta) -> void:
	## Execute current order
	self.active_order.process(self, delta)

## Function called when entity takes damage
func receive_damage(dmg:float) -> void:
	current_health -= dmg
	if current_health <= 0:
		self._on_destroyed()
	else:
		received_damage.emit(current_health)

## Function called when entity is selected.
## Returns true if the object is selectable. Other functionality can be added on top of this.
func select() -> bool:
	return is_selectable

func deselect() -> void:
	return

## Updates the allegiance of entities and executes any code required on an allegiance change
func _update_allegiance(new_allegiance:int) -> void:
	self.allegiance = new_allegiance

## Code to execute when entity is destroyed
func _on_destroyed() -> void:
	## Inform the event bus of imminent death
	self.is_awaiting_deletion = true
	EventBus.on_entity_destroyed.emit(self)
	## Remove entity or play a death animation which deletes the entity at the end of it
	self.queue_free()


""" MANAGE ORDERS """

## Adds the defined order to this entity. The is_queued flag determines if the order should be appended to the end of the order queue or executed immediately.
func add_order(order:Order, is_queued:bool = false) -> void:
	## Add order to queue or overwrite queue with new order
	if is_queued:
		self.order_queue.push_back(order)
		if self.is_default_order:
			self.is_default_order = false
			self.active_order.abort()
	else:
		self.order_queue.resize(1)
		self.order_queue[0] = order
		self.active_order.abort()
		self.is_default_order = false

## Called when the current order aborts. This is usually because another order has received priority from the queue.
func _order_aborted() -> void:
	self.active_order = self.order_queue.pop_front()
	if self.active_order == null:
		self.active_order = self.default_order.new(self)
		self.is_default_order = true

## Called when the current order has been completed. The entity pops the next order from the queue or goes to it's idle order.
func _order_completed() -> void:
	self.active_order = self.order_queue.pop_front()
	if self.active_order == null:
		self.active_order = self.default_order.new(self)
		self.is_default_order = true

## Called when the current order fails. The entity then pops the next order from the queue or goes to it's idle order.
func _order_failed() -> void:
	self.active_order = self.order_queue.pop_front()
	if self.active_order == null:
		self.active_order = self.default_order.new(self)
		self.is_default_order = true

""" ABILITY METHODS """

## Returns the orders that this unit can do split up per line in the UI
func get_entity_orders() -> Array[OrderData]:
	return self.entity_specific_orders

""" FOG OF WAR METHODS """

func initialise_fog_of_war_propagation() -> Sprite2D:
	if is_mobile:
		self.add_to_group("fog_of_war_propagators")
	
	## Create the FoW sprite, assign it's texture and return it to the calling object
	self.fog_of_war_sprite = Sprite2D.new()
	self.fog_of_war_sprite.scale = (Vector2.ONE / self.vision_texture.get_size()) * self.entity_statistics[STATS.VIEW_DISTANCE] * 2
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
		STATS.VIEW_DISTANCE:
			self.fog_of_war_sprite.scale = (Vector2.ONE / self.vision_texture.get_size()) * self.entity_statistics[STATS.VIEW_DISTANCE] * 2 * GameSettings.fog_of_war_resolution
