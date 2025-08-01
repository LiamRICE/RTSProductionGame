extends CanvasLayer

# import scripts
const SettingsUtils:Script = preload("uid://dma7wmfdtuxlx")
const LoadingUtils:Script = preload("uid://bcivgan8styu")

# define signals
signal return_from_settings


var data_dict:Dictionary

# define internal components
@onready var game_container:VBoxContainer = %VerticalGameContainer
@onready var graphics_container:VBoxContainer = %VerticalGraphicsContainer
@onready var sound_container:VBoxContainer = %VerticalSoundContainer
@onready var settings_tab_container:TabContainer = %SettingsTabContainer

func get_width() -> int:
	var size = settings_tab_container.size.x - 8
	return size * 0.4


func set_midpoint(width:int):
	var game_children = game_container.get_children()
	var graphics_children = graphics_container.get_children()
	var sound_children = sound_container.get_children()
	var children = [game_children, graphics_children, sound_children]
	for child in children:
		for component in child:
			if "split_offset" in component:
				component.split_offset = width


func set_options(setting:String, options_button:OptionButton, values:Array[int], labels:Array[String]):
	print("Setting ", setting)
	options_button.clear()
	# set options
	for i in min(len(values), len(labels)):
		options_button.add_item(labels[i], values[i])
	# get the ID of the currently set item in settings
	var setting_id = ProjectSettings.get_setting(setting)
	for i in range(len(values)):
		if values[i] == setting_id:
			options_button.select(i)


func set_options_bool(setting:String, options_toggle:CheckButton):
	print("Setting ", setting)
	var setting_value:bool = ProjectSettings.get_setting(setting)
	options_toggle.button_pressed = setting_value


func set_saved_settings():
	# read settings file
	var data_dict:Dictionary = LoadingUtils.load_json()
	# set value for each setting
	# Global
	$VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer/GraphicsPresetOptionButton.select(data_dict.get("graphics_preset"))

	# Textures
	set_options("rendering/textures/default_filters/anisotropic_filtering_level", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer2/GraphicsSettingsOptionButton, [0, 1, 2, 3, 4], ["Disabled (Fastest)", "2x (Fast)", "4x (Average)", "8x (Slow)", "16x (Slowest)"])
	$VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer2/RichTextLabel.tooltip_text = "Number of samples taken when rendering textures, higher is slower"
	set_options("rendering/textures/decals/filter", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer3/GraphicsSettingsOptionButton, [0, 1, 2, 3, 4, 5], ["Nearest (Fast)", "Linear (Fast)", "Nearest Mipmap (Fast)", "Linear Mipmap (Fast)", "Nearest Mipmap Anisotropic (Average)", "Linear Mipmap Anisotropic (Average)"])
	$VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer3/RichTextLabel.tooltip_text = "The filtering level for Decals, anisotropic filtering performance is affected by the Anisotropic Filtering Level"
	set_options("rendering/textures/light_projectors/filter", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer4/GraphicsSettingsOptionButton, [0, 1, 2, 3, 4, 5], ["Nearest (Fast)", "Linear (Fast)", "Nearest Mipmap (Fast)", "Linear Mipmap (Fast)", "Nearest Mipmap Anisotropic (Average)", "Linear Mipmap Anisotropic (Average)"])
	$VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer4/RichTextLabel.tooltip_text = "The filtering level for Light Projectors, anisotropic filtering performance is affected by the Anisotropic Filtering Level"
	# Shadows
	set_options("rendering/lights_and_shadows/directional_shadow/size", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer5/GraphicsSettingsOptionButton, [256, 512, 1024, 2048, 4096, 8192], ["256 (Fastest)", "512", "1024", "2048", "4096", "8192 (Slowest)"])
	$VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer5/RichTextLabel.tooltip_text = "The directional shadow texture size, higher values have more shadow detail but will decrease performance"
	set_options("rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer6/GraphicsSettingsOptionButton, [0, 1, 2, 3, 4, 5], ["Hard (Fastest)", "Soft Lowest (Faster)", "Soft Low (Fast)", "Soft Medium (Average)", "Soft High (Slow)", "Soft Ultra (Slowest)"])
	$VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer6/RichTextLabel.tooltip_text = "Determines the quality of the directional shadows and determines the details in the bounce lighting and soft shadows, better soft shadows will decrease performance"
	set_options("rendering/lights_and_shadows/positional_shadow/atlas_size", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer7/GraphicsSettingsOptionButton, [256, 512, 1024, 2048, 4096, 8192], ["256 (Fastest)", "512", "1024", "2048", "4096", "8192 (Slowest)"])
	$VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer7/RichTextLabel.tooltip_text = "The positional shadow texture size, higher values have more shadow detail but will decrease performance"
	set_options("rendering/lights_and_shadows/positional_shadow/soft_shadow_filter_quality", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer8/GraphicsSettingsOptionButton, [0, 1, 2, 3, 4, 5], ["Hard (Fastest)", "Soft Lowest (Faster)", "Soft Low (Fast)", "Soft Medium (Average)", "Soft High (Slow)", "Soft Ultra (Slowest)"])
	$VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer8/RichTextLabel.tooltip_text = "Determines the quality of the positional shadows and determines the details in the bounce lighting and soft shadows, better soft shadows will decrease performance"
	# Lighting
	set_options_bool("rendering/global_illumination/gi/use_half_resolution", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer9/GraphicsSettingsCheckButton)
	$VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer9/RichTextLabel.tooltip_text = "Half resolution reduces global illumination quality but increases performance"
	set_options("rendering/global_illumination/voxel_gi/quality", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer10/GraphicsSettingsOptionButton, [0, 1], ["Low (Fast)", "High (Slow)"])
	$VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer10/RichTextLabel.tooltip_text = "Increases the number of light cones used in global illumniation, which improves lighting but reduces performance"
	set_options("rendering/global_illumination/sdfgi/probe_ray_count", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer11/GraphicsSettingsOptionButton, [0, 1, 2, 3, 4, 5], ["8 (Fastest)", "16", "32", "64", "96", "128 (Slowest)"])
	$VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer11/RichTextLabel.tooltip_text = "Number of rays used for lighting, higher is slower"
	set_options("rendering/global_illumination/sdfgi/frames_to_converge", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer12/GraphicsSettingsOptionButton, [0, 1, 2, 3, 4, 5], ["5 (Low Quality, Better Latency)", "10", "15", "20", "25", "30 (High Quality, Worse Latency)"])
	$VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer12/RichTextLabel.tooltip_text = "Higher value leads to less noisy lights, but takes longer to reach to the right value"
	set_options("rendering/global_illumination/sdfgi/frames_to_update_lights", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer13/GraphicsSettingsOptionButton, [0, 1, 2, 3, 4], ["1 (Slowest)", "2", "4", "8", "16 (Fastest)"])
	$VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer13/RichTextLabel.tooltip_text = "Number of frames between each light drawing, higher values lead to lights not being as fluid in motion but improves performance when large numbers of lights are present"
	# Camera
	set_options("renderendering/camera/depth_of_field/depth_of_field_bokeh_shapering", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer14/GraphicsSettingsOptionButton, [0, 1, 2], ["Box (Fastest)", "Hexagon", "Circle (Slowest)"])
	$VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer14/RichTextLabel.tooltip_text = "Circle bokeh is the most realistic, but reduces performance"
	set_options("rendering/camera/depth_of_field/depth_of_field_bokeh_quality", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer15/GraphicsSettingsOptionButton, [0, 1, 2, 3], ["Very Low (Fastest)", "Low", "Medium", "High (Slowest)"])
	$VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer15/RichTextLabel.tooltip_text = "The quality level of the aforementioned bokeh effects, higher reduces performance"
	# Environment
	set_options("rendering/environment/ssao/quality", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer16/GraphicsSettingsOptionButton, [0, 1, 2, 3, 4], ["Very Low (Fastest)", "Low", "Medium", "High", "Ultra (Slowest)"])
	$VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer16/RichTextLabel.tooltip_text = "Higher will take more samples and result in better quality, but lower performance"
	set_options("rendering/environment/ssil/quality", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer17/GraphicsSettingsOptionButton, [0, 1, 2, 3, 4], ["Very Low (Fastest)", "Low", "Medium", "High", "Ultra (Slowest)"])
	$VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer17/RichTextLabel.tooltip_text = "Higher will take more samples and result in better lighting quality, but lower performance"
	set_options("rendering/environment/glow/upscale_mode", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer18/GraphicsSettingsOptionButton, [0, 1], ["Linear (Fast)", "Bicubic (Slow)"])
	$VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer18/RichTextLabel.tooltip_text = "The upscale mode used for glow, bicubic is smoother but decreases performance"
	set_options("rendering/environment/screen_space_reflection/roughness_quality", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer19/GraphicsSettingsOptionButton, [0, 1, 2, 3], ["Disabled (Fastest)", "Low", "Medium", "High (Slowest)"])
	$VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer19/RichTextLabel.tooltip_text = "Higher quality improves the roughness of reflections, but decreases performance"
	set_options("rendering/environment/subsurface_scattering/subsurface_scattering_quality", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer20/GraphicsSettingsOptionButton, [0, 1, 2, 3], ["Disabled (Fastest)", "Low", "Medium", "High (Slowest)"])
	$VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer20/RichTextLabel.tooltip_text = "Higher quality improves the subsurface scattering quality, but decreases performance"
	set_options_bool("rendering/environment/volumetric_fog/use_filter", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer21/GraphicsSettingsCheckButton)
	$VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer21/RichTextLabel.tooltip_text = "Improves the visuals of fog, but decreases performance"
	# AA
	set_options("rendering/anti_aliasing/quality/msaa_2d", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer22/GraphicsSettingsOptionButton, [0, 1, 2, 3], ["Disabled (Fastest)", "2x", "4x", "8x (Slowest)"])
	$VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer22/RichTextLabel.tooltip_text = "Number of samples used in 2D Multi-Sampling Anti-Aliasing, higher increases visual sharpness but decreases performance"
	set_options("rendering/anti_aliasing/quality/msaa_3d", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer23/GraphicsSettingsOptionButton, [0, 1, 2, 3], ["Disabled (Fastest)", "2x", "4x", "8x (Slowest)"])
	$VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer23/RichTextLabel.tooltip_text = "Number of samples used in 3D Multi-Sampling Anti-Aliasing, higher increases visual sharpness but decreases performance"
	set_options("rendering/anti_aliasing/quality/screen_space_aa", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer24/GraphicsSettingsOptionButton, [0, 1], ["Disabled (Fastest)", "FXAA (Fast)"])
	$VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer24/RichTextLabel.tooltip_text = "Applies FXAA to the screen, improving sharpness. Faster performance than MSAA but lower visual fidelity"
	set_options_bool("rendering/anti_aliasing/quality/use_taa", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer25/GraphicsSettingsCheckButton)
	$VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer25/RichTextLabel.tooltip_text = "If switched on, will use Temporal Anti-Aliasing which can improve temporal consistency, but can result in ghosting in some instances and reduces performance"
	# Scaling
	set_options("rendering/scaling_3d/mode", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer26/GraphicsSettingsOptionButton, [0, 1, 2], ["Bilinear (Fastest)", "FSR 1.0 (Fast)", "FSR 2.2 (Slow)"])
	$VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer26/RichTextLabel.tooltip_text = "Will use FSR for supersampling, can improve visual fidelity but lowers performance"
	# Occlusion
	set_options("rendering/occlusion_culling/bvh_build_quality", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer27/GraphicsSettingsOptionButton, [0, 1, 2], ["Low (Fastest)", "Medium", "High (Slowest)"])
	$VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer27/RichTextLabel.tooltip_text = "Higher values improve the accuracy of occlusion but reduces performance"


func save_current():
	# Textures
	ProjectSettings.set_setting("rendering/textures/default_filters/anisotropic_filtering_level", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer2/GraphicsSettingsOptionButton.get_selected_id())
	ProjectSettings.set_setting("rendering/textures/decals/filter", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer3/GraphicsSettingsOptionButton.get_selected_id())
	ProjectSettings.set_setting("rendering/textures/light_projectors/filter", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer4/GraphicsSettingsOptionButton.get_selected_id())
	# Shadows
	ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/size", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer5/GraphicsSettingsOptionButton.get_selected_id())
	ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer6/GraphicsSettingsOptionButton.get_selected_id())
	ProjectSettings.set_setting("rendering/lights_and_shadows/positional_shadow/atlas_size", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer7/GraphicsSettingsOptionButton.get_selected_id())
	ProjectSettings.set_setting("rendering/lights_and_shadows/positional_shadow/soft_shadow_filter_quality", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer8/GraphicsSettingsOptionButton.get_selected_id())
	# Lighting
	ProjectSettings.set_setting("rendering/global_illumination/gi/use_half_resolution", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer9/GraphicsSettingsCheckButton.button_pressed)
	ProjectSettings.set_setting("rendering/global_illumination/voxel_gi/quality", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer10/GraphicsSettingsOptionButton.get_selected_id())
	ProjectSettings.set_setting("rendering/global_illumination/sdfgi/probe_ray_count", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer11/GraphicsSettingsOptionButton.get_selected_id())
	ProjectSettings.set_setting("rendering/global_illumination/sdfgi/frames_to_converge", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer12/GraphicsSettingsOptionButton.get_selected_id())
	ProjectSettings.set_setting("rendering/global_illumination/sdfgi/frames_to_update_lights", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer13/GraphicsSettingsOptionButton.get_selected_id())
	# Camera
	ProjectSettings.set_setting("renderendering/camera/depth_of_field/depth_of_field_bokeh_shapering", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer14/GraphicsSettingsOptionButton.get_selected_id())
	ProjectSettings.set_setting("rendering/camera/depth_of_field/depth_of_field_bokeh_quality", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer15/GraphicsSettingsOptionButton.get_selected_id())
	# Environment
	ProjectSettings.set_setting("rendering/environment/ssao/quality", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer16/GraphicsSettingsOptionButton.get_selected_id())
	ProjectSettings.set_setting("rendering/environment/ssil/quality", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer17/GraphicsSettingsOptionButton.get_selected_id())
	ProjectSettings.set_setting("rendering/environment/glow/upscale_mode", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer18/GraphicsSettingsOptionButton.get_selected_id())
	ProjectSettings.set_setting("rendering/environment/screen_space_reflection/roughness_quality", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer19/GraphicsSettingsOptionButton.get_selected_id())
	ProjectSettings.set_setting("rendering/environment/subsurface_scattering/subsurface_scattering_quality", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer20/GraphicsSettingsOptionButton.get_selected_id())
	ProjectSettings.set_setting("rendering/environment/volumetric_fog/use_filter", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer21/GraphicsSettingsCheckButton.button_pressed)
	# AA
	ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer22/GraphicsSettingsOptionButton.get_selected_id())
	ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer23/GraphicsSettingsOptionButton.get_selected_id())
	ProjectSettings.set_setting("rendering/anti_aliasing/quality/screen_space_aa", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer24/GraphicsSettingsOptionButton.get_selected_id())
	ProjectSettings.set_setting("rendering/anti_aliasing/quality/use_taa", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer25/GraphicsSettingsCheckButton.button_pressed)
	# Scaling
	ProjectSettings.set_setting("rendering/scaling_3d/mode", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer26/GraphicsSettingsOptionButton.get_selected_id())
	# Occlusion
	ProjectSettings.set_setting("rendering/occlusion_culling/bvh_build_quality", $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer27/GraphicsSettingsOptionButton.get_selected_id())
	# Save Settings
	#ProjectSettings.save_custom("player_settings.godot")
	ProjectSettings.save()


func _ready() -> void:
	set_midpoint(get_width())
	set_saved_settings()


func _on_return_button_pressed() -> void:
	return_from_settings.emit()


func _on_confirm_button_pressed() -> void:
	var data_dict:Dictionary = {
		"graphics_preset":$VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer/GraphicsPresetOptionButton.get_selected_id()
	}
	LoadingUtils.save_json(data_dict)
	var preset:int = $VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer/GraphicsPresetOptionButton.get_selected_id()
	if preset == 6:
		save_current()
	else:
		SettingsUtils.default_setting(preset)
		set_saved_settings()


func _on_graphics_settings_option_button_item_selected(index: int) -> void:
	$VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer/GraphicsPresetOptionButton.selected = 6


func _on_graphics_settings_check_button_pressed() -> void:
	$VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer/GraphicsPresetOptionButton.selected = 6


func _on_graphics_preset_option_button_item_selected(index: int) -> void:
	pass # Replace with function body.
