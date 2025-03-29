extends Node

## Enums
enum Mode{MICROSECONDS, MILLISECONDS}

## Tracking variables
var process_name:String
var time:float
var mode:Mode = Mode.MICROSECONDS

## Methods


func _init(process_name:String, mode:Mode = Mode.MICROSECONDS) -> void:
	self.process_name = process_name
	self.mode = mode

func debug_timer_start() -> void:
	match self.mode:
		Mode.MICROSECONDS:
			time = Time.get_ticks_usec()
		Mode.MILLISECONDS:
			time = Time.get_ticks_msec()

func debug_timer_stop() -> float:
	match self.mode:
		Mode.MICROSECONDS:
			time = Time.get_ticks_usec() - time
			#print("Process ", process_name, " completed in ", time, " µs.")
		Mode.MILLISECONDS:
			time = Time.get_ticks_msec() - time
			#print("Process ", process_name, " completed in ", time, " ms.")
	return time
