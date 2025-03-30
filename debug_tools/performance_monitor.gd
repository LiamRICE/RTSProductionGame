extends Control

## Nodes
@onready var fps_display:Label = $PanelContainer/VBoxContainer/FPSCounter
@onready var display_ms:Label = $PanelContainer/VBoxContainer/FrameTimeCounter
@onready var draw_calls_display:Label = $PanelContainer/VBoxContainer/DrawCalls
@onready var vram_usage:Label = $PanelContainer/VBoxContainer/VRAMUsage
@onready var fow_display:Label = $PanelContainer/VBoxContainer/FOW_Update
@onready var fow_vis = $PanelContainer/VBoxContainer/FOW_vis

func _process(delta:float) -> void:
	var FPS:float = Performance.get_monitor(Performance.TIME_FPS)
	var frame_time:String = str(delta*1000).left(5)
	var draw_calls:int = Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	var vram:float = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1000000.0
	var FOW_time:float = Performance.get_custom_monitor("Fog of War/Position Update Time")
	var FOW_vis:float = Performance.get_custom_monitor("Fog of War/Visibility Update Time")
	
	self.fps_display.text = "Performance = " + str(FPS) + " FPS"
	self.display_ms.text = "Frame time : " + frame_time + " ms"
	self.draw_calls_display.text = "Draw calls : " + str(draw_calls)
	self.vram_usage.text = "VRAM Used : " + str(snappedf(vram, 0.01)) + " MiB"
	self.fow_display.text = "FOW update time = " + str(FOW_time) + " µs"
	self.fow_vis.text = "FOW visibility update = " + str(FOW_vis) + " µs"
