class_name ProductionBuilding extends Building

## Loading script classes
const PlayerManager := preload("res://player_manager.gd")

## Signals
signal unit_constructed(unit:Unit, position:Vector3, move_order:Vector3)

## Production building nodes
@export var building_units:Array[UnitResource]
@export var production_timer:Timer
@export var unit_spawn_point:Marker3D
@export var rally_point:Marker3D

## Production building properties
var player_manager:PlayerManager

## Production building internal parameters
var production_queue:Array[Unit]

## Production building state
var is_producing:bool

## ProductionBuilding Methods

func _ready() -> void:
	# initialise player_manager
	_init_player_manager()

# Required for spending resources
func _init_player_manager():
	self.player_manager = get_tree().get_root().get_node("GameManager/LevelManager/PlayerManager")
	if self.player_manager == null:
		printerr("Warning! No player manager found! Check the SceneTree for 'GameManager/LevelManager/PlayerManager'.")

## Starts a timer for the production of a new unit
func queue_unit(unit:int) -> void:
	var new_unit:Unit = self.building_units[unit].entity_instance.instantiate()
	if self.player_manager.spend_resources(new_unit.resource_cost_amount, new_unit.resource_cost_type):
		print(new_unit.resource_cost_type, " : ", new_unit.resource_cost_amount)
		new_unit.allegiance = self.allegiance
		self.production_queue.append(new_unit)
		print("Queuing Unit...")
		if not self.is_producing:
			self.start_production()
			self.is_producing = true

## Starts the production of the unit at index 0 in the production queue
func start_production() -> void:
	print("Starting production with time ", self.production_queue[0].production_cost)
	self.production_timer.start(self.production_queue[0].production_cost)

## Called when the timer for the unit production is completed
func _on_production_timer_timeout():
	print("Production complete.")
	var unit:Unit = self.production_queue.pop_front() as Unit
	# If there is another unit in the queue, start the production for it
	if self.production_queue.size() > 0:
		start_production()
	else:
		self.is_producing = false
	self.unit_constructed.emit(unit, unit_spawn_point.global_position, rally_point.global_position)
	
