extends Node3D

# signals
signal ammo_depleted

# enumerations
const FireMode := preload("uid://cklliejhey2vf").FireMode

# timers
@onready var burst_timer:Timer = $BurstTimer
@onready var aim_timer:Timer = $AimTimer
@onready var reload_timer:Timer = $ReloadTimer
@onready var rearm_timer:Timer = $RearmTimer

# variables
var is_firing:bool = false # indicates whether the weapon is cleared to fire
var is_on_target:bool = false # indicates that the turret of the vehicle is slewed onto the target and is in range
var is_aimed:bool = false # indicates whether the weapon is zeroed in on the target
var is_in_rearm_zone:bool = false # indicates whether the weapon is cleared to be rearmed
var is_target:bool = false

var target_unit:Entity
var target_position:Vector3

# current state
var number_of_clips:int
var number_of_bursts:int

@export_group("Weapon Type")
@export var weapon_type:WeaponType


func _ready():
	# set timers
	self.burst_timer.wait_time = self.weapon_type.time_between_bursts
	self.aim_timer.wait_time = self.weapon_type.aim_time
	self.reload_timer.wait_time = self.weapon_type.reload_time
	self.rearm_timer.wait_time = self.weapon_type.rearm_time
	# set combat variables
	self.number_of_clips = self.weapon_type.num_reloads
	self.number_of_bursts = self.weapon_type.clip_size


func on_target(target:Entity, is_on_target:bool):
	if self.weapon_type.fire_mode == FireMode.POSITION:
		self.target_position = target.global_position
		self.is_target = false
	else:
		self.target_unit = target
		self.is_on_target = is_on_target
		self.is_target = true


func on_position(target:Vector3, is_on_target:bool):
	if self.weapon_type.fire_mode == FireMode.TARGET:
		pass
	else:
		self.is_target = false
		self.target_position = target
		self.is_on_target = is_on_target


func fire():
	self.is_firing = true
	if self.is_on_target:
		if self.is_aimed:
			if self.number_of_bursts > 0:
				self.burst_timer.start(0)
			else:
				if self.number_of_clips > 0:
					self.reload()
				else:
					self.is_firing = false
		else:
			print("Aiming...")
			self.aim_timer.start(self.weapon_type.aim_time)


func rearm():
	if self.is_in_rearm_zone:
		print("Rearming...")
		self.rearm_timer.start(self.weapon_type.rearm_time)


func reload():
	if self.number_of_clips > 0:
		print("Reloading...")
		self.reload_timer.start(self.weapon_type.reload_time)
	else:
		self.is_firing = false


func _on_burst_timer_timeout() -> void:
	for i in self.weapon_type.shots_per_burst:
		print("Bang!")
		if is_target:
			# TODO - FIRE WEAPON
			# TODO - trigger fire animation
			# check if hit
			if randf() <= self.weapon_type.accuracy:
				# trigger hit on the target
				self.target_unit.receive_damage(self.weapon_type.damage)
		else:
			pass
			# TODO - if shooting at position, trigger explosion within Circular Area Probable
	self.number_of_bursts -= 1
	if self.is_firing and self.is_on_target:
		if self.number_of_bursts > 0:
			self.burst_timer.start(self.weapon_type.time_between_bursts)
		else:
			self.reload()


func _on_aim_timer_timeout() -> void:
	print("Aimed.")
	self.is_aimed = true
	self.fire()


func _on_reload_timer_timeout() -> void:
	print("Reloaded.")
	self.number_of_clips -= 1
	self.number_of_bursts = self.weapon_type.clip_size
	self.fire()


func _on_rearm_timer_timeout() -> void:
	print("Rearmed 1 clip.")
	if self.number_of_clips < self.weapon_type.num_reloads:
		self.number_of_clips += 1
		self.rearm()
