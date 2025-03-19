class_name ProductionBuilding extends Building

## Signals
signal unit_constructed(unit:Unit, position:Vector3, move_order:Vector3)

## Production building nodes
@export var building_units:Array[PackedScene]
@export var production_timer:Timer
@export var unit_spawn_point:Marker3D
@export var rally_point:Marker3D

## Production building properties

## Production building internal parameters
var production_queue:Array[Unit]

## Production building state
var is_producing:bool

## ProductionBuilding Methods

## Starts a timer for the production of a new unit
func queue_unit(unit:int) -> void:
	var new_unit:Unit = self.building_units[unit].instantiate()
	new_unit.allegiance = self.allegiance
	self.production_queue.append(new_unit)
	if not self.is_producing:
		self.start_production()
		self.is_producing = true

## Starts the production of the unit at index 0 in the production queue
func start_production() -> void:
	self.production_timer.start(self.production_queue[0].production_cost)

## Called when the timer for the unit production is completed
func _on_production_timer_timeout():
	var unit:Unit = self.production_queue.pop_front() as Unit
	unit.allegiance = self.allegiance
	# If there is another unit in the queue, start the production for it
	if self.production_queue.size() > 0:
		start_production()
	else:
		self.is_producing = false
	self.unit_constructed.emit(unit, unit_spawn_point.global_position, rally_point.global_position)
	
