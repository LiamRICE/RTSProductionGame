class_name ScoutSnipers extends Unit

const UnitCard:Script = preload("uid://45nawhpn2sjv")

@onready var _unit_card:UnitCard = %UnitCard

var cover_gain_rate_per_sec:float = 0.01

func _ready():
	## Execute parent _ready function
	super._ready()
	self.received_damage.connect(self._on_received_damage)
	self._unit_card.initialise(self)


func _physics_process(delta) -> void:
	super._physics_process(delta)
	
	# increase cover when unit is stationary
	if self.active_order is not MoveOrder:
		if self.cover_accuracy_reduction < 0.1:
			self.cover_accuracy_reduction += self.cover_gain_rate_per_sec * delta
		else:
			self.cover_accuracy_reduction = 0.1
		if self.cover_damage_reduction < 0.25:
			self.cover_damage_reduction += self.cover_gain_rate_per_sec * delta
		else:
			self.cover_damage_reduction = 0.25
		self._unit_card.set_cover(cover_damage_reduction)
	else:
		if cover_damage_reduction > 0:
			self.cover_accuracy_reduction = 0
			self.cover_damage_reduction = 0
			self._unit_card.set_cover(cover_damage_reduction)


func _on_received_damage(health:int) -> void:
	self._unit_card.set_hp(health)
