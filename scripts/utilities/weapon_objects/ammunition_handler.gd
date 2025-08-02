class_name AmmunitionHandler extends Node

@export var ammunition_type:AmmunitionType

var num_clips:int
var num_shots:int


""" NODE METHODS """

func _ready() -> void:
	self.init()


""" EXTERNAL METHODS """

static func create(ammunition_type:AmmunitionType) -> AmmunitionHandler:
	var handler = AmmunitionHandler.new()
	handler.ammunition_type = ammunition_type
	handler.init()
	return handler


func fire(num_shots:int) -> int:
	if num_shots > self.num_shots:
		self.num_shots = 0
	else:
		self.num_shots -= num_shots
	return self.num_shots


func get_damage() -> float:
	return self.ammunition_type.damage


func reload() -> bool:
	if self.num_clips > 0:
		self.num_clips -= 1
		self.num_shots = self.ammunition_type.shots_in_clip
		return true
	else:
		return false


func rearm() -> bool:
	if self.num_clips < self.ammunition_type.num_clips:
		self.num_clips += 1
	if self.num_clips >= self.ammunition_type.num_clips:
		return true
	else:
		return false


""" INTERNAL METHODS """

func init() -> void:
	if self.ammunition_type != null:
		self.num_clips = self.ammunition_type.num_clips
		self.num_shots = self.ammunition_type.shots_in_clip
