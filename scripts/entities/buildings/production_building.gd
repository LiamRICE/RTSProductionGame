class_name ProductionBuilding extends Building

## Signals
signal unit_constructed(unit:Unit, position:Vector3, move_order:Vector3)

## Production building nodes
@export var building_units:Array[ENTITY_ID]
@export var production_timer:Timer
@export var unit_spawn_point:Marker3D
@export var rally_point:Marker3D

## Production building properties
var player_manager:PlayerManager

## Production building internal parameters
var production_queue:Array[ENTITY_ID]

## Production building state
var is_producing:bool

## ProductionBuilding Methods

func _ready() -> void:
	super._ready()
	# initialise player_manager
	_init_player_manager()

# Required for spending resources
func _init_player_manager():
	self.player_manager = get_tree().get_root().get_node("GameManager/LevelManager/PlayerManager")
	if self.player_manager == null:
		printerr("Error! No player manager found! Check the SceneTree for 'GameManager/LevelManager/PlayerManager'.")

## Starts a timer for the production of a new unit
func queue_unit(unit:int) -> void:
	## Unit's properties and statistics
	var unit_resource:EntityResource = EntityDatabase.get_resource(self.building_units[unit])
	if self.player_manager.spend_resources(unit_resource.production_cost):
		print(unit_resource.production_cost, unit_resource.production_time)
		self.production_queue.append(self.building_units[unit])
		print("Queuing " + unit_resource.name + "...") ## DEBUG
		if not self.is_producing:
			self.start_production()
			self.is_producing = true
	else:
		print("Not enough resources to buy ", EntityDatabase.get_entity_name(self.building_units[unit]), "!")

## Starts the production of the unit at index 0 in the production queue
func start_production() -> void:
	var e_id:ENTITY_ID = self.production_queue[0]
	print("Starting production with time ", EntityDatabase.get_production_time(e_id))
	self.production_timer.start(EntityDatabase.get_production_time(e_id))

## Called when the timer for the unit production is completed
func _on_production_timer_timeout():
	print("Production complete.")
	## New unit to instantiate
	var e_id:ENTITY_ID = self.production_queue.pop_front()
	var new_unit:Unit = EntityDatabase.get_entity(e_id).instantiate()
	new_unit.allegiance = self.allegiance
	# If there is another unit in the queue, start the production for it
	if self.production_queue.size() > 0:
		start_production()
	else:
		self.is_producing = false
	self.unit_constructed.emit(new_unit, unit_spawn_point.global_position, rally_point.global_position)
