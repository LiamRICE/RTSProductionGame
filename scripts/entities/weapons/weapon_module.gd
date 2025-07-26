extends Node3D

const WeaponType := preload("uid://cklliejhey2vf").WeaponType
const AmunitionType := preload("uid://cklliejhey2vf").AmunitionType

# timers
@onready var burst_timer:Timer = $BurstTimer
@onready var aim_timer:Timer = $AimTimer
@onready var reload_timer:Timer = $ReloadTimer
@onready var rearm_timer:Timer = $RearmTimer

# variables
var is_firing:bool = false
var is_on_target:bool = false
var is_aimed:bool = false
var is_in_rearm_zone:bool = false

# current state
var number_of_clips:int
var number_of_bursts:int

@export_group("General")
@export var weapon_type:WeaponType
@export var weapon_effect:int

@export_group("Weapon Statistics")
@export var clip_size:int # number of bursts in a clip
@export var max_clips:int # number of clips in a unit
@export var reload_time:float # amount of time it takes to reload a clip
@export var shots_per_burst:int # amount of shots are fired in a burst
@export var time_between_bursts:float # the amount of time it takes to fire a burst
@export var aim_time:float # the amount of time it takes to start firing at a new unit

@export_group("Weapon Ammunition")
@export var ammunition_type:AmunitionType # the type of ammunition this weapon uses
@export var rearm_time:float # the amount of time it takes to rearm a clip of the weapon


func _ready():
	# set timers
	self.burst_timer.wait_time = time_between_bursts
	self.aim_timer.wait_time = aim_time
	self.reload_timer.wait_time = reload_time
	self.rearm_timer.wait_time = rearm_time
	# set combat variables
	self.number_of_clips = max_clips
	self.number_of_bursts = clip_size


func on_target(is_on_target:bool):
	self.is_on_target = is_on_target


func fire():
	self.is_firing = true
	if self.is_on_target:
		if self.is_aimed:
			self.burst_timer.start(0)
		else:
			print("Aiming...")
			self.aim_timer.start(self.aim_time)


func rearm():
	if self.is_in_rearm_zone:
		print("Rearming...")
		self.rearm_timer.start(self.rearm_time)


func reload():
	if self.number_of_clips > 0:
		print("Reloading...")
		self.reload_timer.start(self.reload_time)
	else:
		self.is_firing = false


func _on_burst_timer_timeout() -> void:
	print("Bang!")
	self.number_of_bursts -= 1
	if self.is_firing and self.is_on_target:
		if self.number_of_bursts > 0:
			self.burst_timer.start(self.time_between_bursts)
		else:
			self.reload()


func _on_aim_timer_timeout() -> void:
	print("Aimed.")
	self.is_aimed = true
	self.fire()


func _on_reload_timer_timeout() -> void:
	print("Reloaded.")
	self.number_of_clips -= 1
	self.number_of_bursts = self.clip_size
	self.fire()


func _on_rearm_timer_timeout() -> void:
	print("Rearmed 1 clip.")
	if self.number_of_clips < self.max_clips:
		self.number_of_clips += 1
		self.rearm()
