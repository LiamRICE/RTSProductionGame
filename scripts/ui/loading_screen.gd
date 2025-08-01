extends CanvasLayer

# signals
signal scene_loaded

# texts
var text_arrays = ["Nuking the Server", "Loading spyware", "Processing procurement misallocations"]

# scene to be loaded
var next_scene:String = ""

# visual elements
@onready var text_label = $VBoxContainer/RichTextLabel
@onready var progress_bar = $VBoxContainer/ProgressBar
@onready var timer = $MessageTimer


func load_scene():
	if next_scene != "":
		ResourceLoader.load_threaded_request(next_scene)


func _process(delta: float) -> void:
	var progress = []
	if next_scene != "":
		ResourceLoader.load_threaded_get_status(next_scene, progress)
		progress_bar.value = progress[0]*100
		
		if progress[0] == 1:
			scene_loaded.emit()
			var packed_scene = ResourceLoader.load_threaded_get(next_scene)
			get_tree().change_scene_to_packed(packed_scene)


func set_load_scene(path:String):
	next_scene = path
	load_scene()


func _on_message_timer_timeout() -> void:
	var i:int = randi_range(0, len(text_arrays)-1)
	text_label.text = text_arrays[i]
