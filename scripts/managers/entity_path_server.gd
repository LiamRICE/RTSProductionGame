extends Node

## Navigation map
var _nav_map_rid:RID

## Constants
const MAX_THREADS:int = 4

## Internal variables
var _exit_thread:bool = false
var _thread_pool:Array[Thread] = []
var _requests:Array[Dictionary] = []
var _mutex:Mutex = Mutex.new()

func _ready() -> void:
	print("Starting threaded EntityNavigationServer...")
	await RenderingServer.frame_post_draw
	if not NavigationServer3D.get_maps().is_empty():
		self._nav_map_rid = NavigationServer3D.get_maps()[0]
	
	for i in MAX_THREADS:
		var thread := Thread.new()
		_thread_pool.append(thread)
		thread.start(self._thread_function, Thread.PRIORITY_LOW)

func request_path(order:MoveOrder, start:Vector3, end:Vector3) -> void:
	var request: Dictionary = {
		"order": order,
		"start": start,
		"end": end
	}
	self._mutex.lock()
	self._requests.append(request)
	self._mutex.unlock()

func _thread_function() -> void:
	while true:
		## Check if thread has been asked to exit
		self._mutex.lock()
		var should_exit = self._exit_thread ## Protect with Mutex.
		self._mutex.unlock()
		if should_exit:
			break ## Break out of the infinite loop is so
		
		## Lock any usefull variables, do work, lock variables again and update them
		var request:Dictionary = {}
		
		## Fetch first path request in the queue
		self._mutex.lock()
		if not self._requests.is_empty():
			request = self._requests.pop_front()
		self._mutex.unlock()
		
		## 
		if request.is_empty():
			OS.delay_msec(16)
			continue

		var start:Vector3 = request["start"]
		var end:Vector3 = request["end"]
		var order:MoveOrder = request["order"]

		var path: PackedVector3Array = NavigationServer3D.map_get_path(_nav_map_rid, start, end, true)
		path = NavigationServer3D.simplify_path(path, 0.01)

		call_deferred("_emit_path_ready", order, path)

func _emit_path_ready(order:MoveOrder, path:PackedVector3Array) -> void:
	order._path_received(path)

## Thread must be disposed (or "joined"), for portability.
func _exit_tree() -> void:
	print("Safely closing threads...")
	## Set exit condition to true.
	self._mutex.lock()
	self._exit_thread = true ## Protect with Mutex.
	self._mutex.unlock()
	for _thread in self._thread_pool:
		_thread.wait_to_finish() ## Wait until it exits.
