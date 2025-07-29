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
@export_group("Weapon Positions")
@export var weapon_positions:Node3D
var weapon_position_list:Array[Marker3D] = []

## internal variables
# checks
var is_firing:bool = false # indicates whether the weapon is cleared to fire
var is_on_target:bool = false # indicates that the turret of the vehicle is slewed onto the target and is in range
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
var selected_ammunition:AmmunitionType
var number_of_clips:int
var number_of_bursts:int



""" NODE METHODS """

func _ready():
	# set timers
	self.burst_timer.wait_time = self.weapon_type.time_between_bursts
	self.aim_timer.wait_time = self.weapon_type.aim_time
	self.reload_timer.wait_time = self.weapon_type.reload_time
	self.rearm_timer.wait_time = self.weapon_type.rearm_time
	# set combat variables
	self.number_of_clips = self.weapon_type.num_reloads
	self.number_of_bursts = self.weapon_type.clip_size
	self.selected_ammunition = self.weapon_type.ammunition_types[0]
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

func set_on_target(target:Entity, is_on_target:bool):
	if self.weapon_type.fire_mode == FireMode.POSITION:
		self.target_position = target.global_position
		self.target_is_entity = false
	else:
		self.target_unit = target
		self.is_on_target = is_on_target
		self.target_is_entity = true


func set_on_position(target:Vector3, is_on_target:bool):
	if self.weapon_type.fire_mode == FireMode.TARGET:
		pass
	else:
		self.target_is_entity = false
		self.target_position = target
		self.is_on_target = is_on_target


func set_action_fire():
	self._fire()


""" INTERNAL ACTION METHODS """

func _fire():
	self.is_firing = true
	if self.is_on_target:
		if self.is_aimed:
			if self.number_of_bursts > 0:
				self.burst_timer.start(0)
			else:
				if self.number_of_clips > 0:
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
	if self.number_of_clips > 0:
		print("Reloading...")
		self.reload_timer.start(self.weapon_type.reload_time)
	else:
		self.is_firing = false


func _clear_target():
	self.is_firing = false
	self.target_is_entity = false
	self.is_on_target = false
	self.is_aimed = false
	self.target_unit = null


""" FIRING METHODS """

func _fire_at_entity(id:int, target:Entity, ammunition:AmmunitionType, is_hit:bool):
	print("BANG !!!")
	# TODO - trigger fire and hit/miss animation
	# trigger hit on the target if target exists
	if ammunition.shot_type == ShotType.SINGLE:
		_damage_entity(target)
	else:
		_damage_area(target.global_position)


func _fire_at_position(id:int, target:Vector3, ammunition:AmmunitionType):
	# TODO - if shooting at position, trigger explosion within Circular Area Probable
	pass


func _damage_entity(target:Entity):
	if "receive_damage" in target:
		# TODO - for each hit, send damage information
		if target.receive_damage(self.selected_ammunition.damage):
			# remove target and de-aggro if target is destroyed
			self._clear_target()
	else:
		# remove target and de-aggro if target is destroyed
		self._clear_target()


func _damage_area(target:Vector3):
	# TODO - trigger AoE at the target position and damage all units within that area
	pass


""" TIMER TRIGGERS """

func _on_burst_timer_timeout() -> void:
	self.offsets = []
	self.current_offset = 0
	for i in self.weapon_type.shots_per_burst:
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
			for weapon in self.weapon_position_list:
				self.offsets.append(randi_range(0, 2))
			self.shooting_now = true
	self.number_of_bursts -= 1
	if self.is_firing and self.is_on_target:
		if self.number_of_bursts > 0:
			self.burst_timer.start(self.weapon_type.time_between_bursts)
		else:
			if not self.target_is_entity:
				self.is_firing = false
				self.is_on_target = false
				self.is_aimed = false
			self._reload()


func _on_aim_timer_timeout() -> void:
	print("Aimed.")
	self.is_aimed = true
	self._fire()


func _on_reload_timer_timeout() -> void:
	print("Reloaded.")
	self.number_of_clips -= 1
	self.number_of_bursts = self.weapon_type.clip_size
	if not self.target_is_entity:
		_clear_target()
	self._fire()


func _on_rearm_timer_timeout() -> void:
	print("Rearmed 1 clip.")
	if self.number_of_clips < self.weapon_type.num_reloads:
		self.number_of_clips += 1
		self._rearm()
