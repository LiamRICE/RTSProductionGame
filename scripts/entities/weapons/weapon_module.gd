extends Node3D

# signals
signal ammo_depleted

# enumerations
const FireMode := preload("uid://cklliejhey2vf").FireMode
const ShotType := preload("uid://cklliejhey2vf").ShotType
const ACCURACY_LIST := preload("uid://cklliejhey2vf").ACCURACY_LIST

# timers
@onready var burst_timer:Timer = $BurstTimer
@onready var aim_timer:Timer = $AimTimer
@onready var reload_timer:Timer = $ReloadTimer
@onready var rearm_timer:Timer = $RearmTimer

# external variables
@export_group("Weapon Type")
@export var weapon_type:WeaponType
@export var _ammunition_types:Array[AmmunitionType] # the type of ammunition this weapon uses
var ammunition_handlers:Array[AmmunitionHandler]
@export_group("Weapon Positions")
@export var weapon_positions:Node3D
var weapon_position_list:Array[Marker3D] = []

## internal variables
# checks
var is_firing:bool = false # indicates whether the weapon is cleared to fire
var is_aimed:bool = false # indicates whether the weapon is zeroed in on the target
var is_in_rearm_zone:bool = false # indicates whether the weapon is cleared to be rearmed
var target_is_entity:bool = false # is true if targetting an Entity, false if targetting a position
var shooting_now:bool = false # is true if the unit is shooting now
# target variables
var is_hits:Array[bool] = []
var target_unit:Entity
var target_position:Vector3
var offsets:Array[int] = []
var current_offset:int = 0
# shooting variables
var selected_ammunition:AmmunitionHandler
var explosive_shell := preload("uid://c0yuub3wk4q0b")


""" NODE METHODS """

func _ready():
	# set timers
	self.burst_timer.wait_time = self.weapon_type.time_between_shots
	self.aim_timer.wait_time = self.weapon_type.aim_time
	self.reload_timer.wait_time = self.weapon_type.reload_time
	self.rearm_timer.wait_time = self.weapon_type.rearm_time
	# set default ammunition
	self.ammunition_handlers = []
	for ammo in self._ammunition_types:
		self.ammunition_handlers.append(AmmunitionHandler.create(ammo))
	self.selected_ammunition = self.ammunition_handlers[0]
	# extract the weapon positions
	var list = self.weapon_positions.get_children()
	for l in list:
		if l is Marker3D:
			self.weapon_position_list.append(l)


func _physics_process(delta: float) -> void:
	# shoot
	if self.shooting_now:
		for i in range(len(self.offsets)):
			if self.target_is_entity:
				if self.current_offset == self.offsets[i]:
					self._fire_at_entity(i, self.target_unit, self.selected_ammunition, self.is_hits[i])
			else:
				self._fire_at_position(i, self.target_position, self.selected_ammunition)
		self.current_offset += 1
		if self.current_offset > 2:
			self.shooting_now = false


""" EXTERNALLY TRIGGERED PERMISSIONS """

func set_on_target(target:Entity):
	if self.weapon_type.fire_mode == FireMode.POSITION:
		self.target_position = target.global_position
		self.target_is_entity = false
	else:
		self.target_unit = target
		self.target_is_entity = true


func set_on_position(target:Vector3):
	if self.weapon_type.fire_mode == FireMode.TARGET:
		pass # cannot use this firemode
	else:
		self.target_is_entity = false
		self.target_position = target


func set_action_fire(ammunition_type_id:int = -1):
	if ammunition_type_id != -1:
		self.select_ammunition_type(ammunition_type_id)
	self._fire(true)


func set_in_rearm_zone(is_rearm:bool):
	self.is_in_rearm_zone = is_rearm
	if is_rearm:
		self.rearm_timer.start(self.weapon_type.rearm_time)


func get_ammunition_types() -> Array[AmmunitionType]:
	return self.ammunition_types


func select_ammunition_type(id:int):
	if id < len(self.ammunition_handlers) and id > 0:
		self.selected_ammunition = self.ammunition_handlers[id]
	else:
		self.selected_ammunition = self.ammunition_handlers[0]


""" INTERNAL ACTION METHODS """

func _fire(first_shot:bool = false):
	self.is_firing = true
	if self.is_aimed:
		print("Ammunition count: ", self.selected_ammunition.num_shots)
		if self.selected_ammunition.num_shots > 0:
			if first_shot:
				self.burst_timer.start(0)
			else:
				self.burst_timer.start(self.weapon_type.time_between_shots)
		else:
			if self.selected_ammunition.num_clips > 0:
				self._reload()
			else:
				self.is_firing = false
	else:
		print("Aiming...")
		self.aim_timer.start(self.weapon_type.aim_time)


func _rearm():
	if self.is_in_rearm_zone:
		print("Rearming...")
		self.rearm_timer.start(self.weapon_type.rearm_time)


func _reload():
	if self.selected_ammunition.num_clips > 0:
		print("Reloading...")
		self.reload_timer.start(self.weapon_type.reload_time)
	else:
		self.is_firing = false


func _clear_target():
	self.is_firing = false
	self.target_is_entity = false
	self.is_aimed = false
	self.target_unit = null
	self.target_position = Vector3.ZERO


""" FIRING METHODS """

func _fire_at_entity(id:int, target:Entity, ammunition:AmmunitionHandler, is_hit:bool):
	print("BANG !!!")
	# TODO - trigger fire and hit/miss animation
	# trigger hit on the target if target exists
	if ammunition.ammunition_type.shot_type == ShotType.SINGLE:
		self._damage_entity(target)
	else:
		self._damage_area(target.global_position)


func _fire_at_position(id:int, target:Vector3, ammunition:AmmunitionHandler):
	# TODO - if shooting at position, trigger explosion within Circular Area Probable
	self._damage_area(target)


func _damage_entity(target:Entity):
	if "receive_damage" in target:
		# TODO - for each hit, send damage information
		if target.receive_damage(self.selected_ammunition.get_damage()):
			# remove target and de-aggro if target is destroyed
			self._clear_target()
	else:
		# remove target and de-aggro if target is destroyed
		self._clear_target()


func _damage_area(target:Vector3):
	# TODO - trigger AoE at the target position and damage all units within that area
	var shell = explosive_shell.instantiate()
	shell.init(self.selected_ammunition.ammunition_type.explosion_radius, self.selected_ammunition.ammunition_type.damage)
	shell.global_position = target
	self.add_child(shell)
	shell.detonate()


""" TIMER TRIGGERS """

func _on_burst_timer_timeout() -> void:
	self.offsets = []
	self.current_offset = 0
	if self.target_is_entity:
		# TODO - shoot 1 ray from each weapon position at the target? the number of hits multiplies the accuracy
		
		# TODO - update accuracy with bonuses or maluses
		var accuracy = self.weapon_type.accuracy
		if "is_hit" in self.target_unit:
			for weapon in self.weapon_position_list:
				# check if hit based on accuracy
				# send accuracy information to the target and get back hits
				self.is_hits.append(self.target_unit.is_hit(accuracy))
				# set firing offsets
				self.offsets.append(randi_range(0, 2))
				# shoot
				self.shooting_now = true
		else:
			self._clear_target()
	else:
		for weapon in self.weapon_position_list:
			self.offsets.append(randi_range(0, 2))
		self.shooting_now = true
	# use ammunition
	self.selected_ammunition.fire(1)
	# check if reload is needed
	self._fire()


func _on_aim_timer_timeout() -> void:
	print("Aimed.")
	self.is_aimed = true
	self._fire(true)


func _on_reload_timer_timeout() -> void:
	print("Reloaded.")
	if not self.selected_ammunition.reload():
		self.ammo_depleted.emit()
	if self.target_position == Vector3.ZERO and self.target_unit == null:
		_clear_target()
	else:
		self._fire(true)


func _on_rearm_timer_timeout() -> void:
	print("Rearmed 1 clip.")
	var done = false
	for ammunition in self.ammunition_handlers:
		if not done:
			if not ammunition.rearm():
				done = true
