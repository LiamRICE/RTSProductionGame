extends CanvasLayer

# define signals
signal return_from_settings

# define constants
const SAVE_PATH = "user/"
const SAVE_FILE = "settings.json"

var data_dict:Dictionary

# define internal components
@onready var game_container:VBoxContainer = %VerticalGameContainer
@onready var graphics_container:VBoxContainer = %VerticalGraphicsContainer
@onready var sound_container:VBoxContainer = %VerticalSoundContainer
@onready var settings_tab_container:TabContainer = %SettingsTabContainer

func get_width() -> int:
	var size = settings_tab_container.size.x - 8
	return size / 2


func set_midpoint(width:int):
	var game_children = game_container.get_children()
	var graphics_children = graphics_container.get_children()
	var sound_children = sound_container.get_children()
	var children = [game_children, graphics_children, sound_children]
	for child in children:
		for component in child:
			if "split_offset" in component:
				component.split_offset = width


func _ready() -> void:
	set_midpoint(get_width())
	load_json()
	$VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer/GraphicsSettingsOptionButton.select(data_dict.get("graphics_preset"))


func _on_return_button_pressed() -> void:
	return_from_settings.emit()


func default_setting(setting:int):
	if setting == 0:
		ProjectSettings.set_setting("rendering/occlusion_culling/bvh_build_quality", 0)
		ProjectSettings.set_setting("rendering/textures/canvas_textures/default_texture_filter", 0)
		ProjectSettings.set_setting("rendering/textures/default_filters/anisotropic_filtering_level", 0)
		ProjectSettings.set_setting("rendering/textures/decals/filter", 0)
		ProjectSettings.set_setting("rendering/textures/light_projectors/filter", 0)
		ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/size", 256)
		ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality", 0)
		ProjectSettings.set_setting("rendering/lights_and_shadows/positional_shadow/soft_shadow_filter_quality", 0)
		ProjectSettings.set_setting("rendering/lights_and_shadows/positional_shadow/atlas_size", 512)
		ProjectSettings.set_setting("rendering/global_illumination/gi/use_half_resolution", true)
		ProjectSettings.set_setting("rendering/global_illumination/voxel_gi/quality", 0)
		ProjectSettings.set_setting("rendering/global_illumination/sdfgi/probe_ray_count", 0)
		ProjectSettings.set_setting("rendering/global_illumination/sdfgi/frames_to_converge", 0)
		ProjectSettings.set_setting("rendering/global_illumination/sdfgi/frames_to_update_lights", 2)
		ProjectSettings.set_setting("renderendering/camera/depth_of_field/depth_of_field_bokeh_shapering", 0)
		ProjectSettings.set_setting("rendering/camera/depth_of_field/depth_of_field_bokeh_quality", 0)
		ProjectSettings.set_setting("rendering/environment/ssao/quality", 0)
		ProjectSettings.set_setting("rendering/environment/ssil/quality", 0)
		ProjectSettings.set_setting("rendering/environment/glow/upscale_mode", 0)
		ProjectSettings.set_setting("rendering/environment/screen_space_reflection/roughness_quality", 0)
		ProjectSettings.set_setting("rendering/environment/subsurface_scattering/subsurface_scattering_quality", 0)
		ProjectSettings.set_setting("rendering/environment/volumetric_fog/use_filter", 0)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d", 0)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", 0)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/screen_space_aa", 0)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/use_taa", false)
		ProjectSettings.set_setting("rendering/scaling_3d/mode", 0)
		ProjectSettings.set_setting("rendering", 0)
		ProjectSettings.set_setting("rendering", 0)
	if setting == 1:
		ProjectSettings.set_setting("rendering/occlusion_culling/bvh_build_quality", 0)
		ProjectSettings.set_setting("rendering/textures/canvas_textures/default_texture_filter", 0)
		ProjectSettings.set_setting("rendering/textures/default_filters/anisotropic_filtering_level", 1)
		ProjectSettings.set_setting("rendering/textures/decals/filter", 1)
		ProjectSettings.set_setting("rendering/textures/light_projectors/filter", 1)
		ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/size", 512)
		ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality", 1)
		ProjectSettings.set_setting("rendering/lights_and_shadows/positional_shadow/soft_shadow_filter_quality", 1)
		ProjectSettings.set_setting("rendering/lights_and_shadows/positional_shadow/atlas_size", 1024)
		ProjectSettings.set_setting("rendering/global_illumination/gi/use_half_resolution", true)
		ProjectSettings.set_setting("rendering/global_illumination/voxel_gi/quality", 0)
		ProjectSettings.set_setting("rendering/global_illumination/sdfgi/probe_ray_count", 0)
		ProjectSettings.set_setting("rendering/global_illumination/sdfgi/frames_to_converge", 0)
		ProjectSettings.set_setting("rendering/global_illumination/sdfgi/frames_to_update_lights", 1)
		ProjectSettings.set_setting("renderendering/camera/depth_of_field/depth_of_field_bokeh_shapering", 0)
		ProjectSettings.set_setting("rendering/camera/depth_of_field/depth_of_field_bokeh_quality", 0)
		ProjectSettings.set_setting("rendering/environment/ssao/quality", 0)
		ProjectSettings.set_setting("rendering/environment/ssil/quality", 0)
		ProjectSettings.set_setting("rendering/environment/glow/upscale_mode", 0)
		ProjectSettings.set_setting("rendering/environment/screen_space_reflection/roughness_quality", 0)
		ProjectSettings.set_setting("rendering/environment/subsurface_scattering/subsurface_scattering_quality", 0)
		ProjectSettings.set_setting("rendering/environment/volumetric_fog/use_filter", 0)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d", 0)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", 0)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/screen_space_aa", 0)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/use_taa", false)
		ProjectSettings.set_setting("rendering/scaling_3d/mode", 0)
	if setting == 2:
		ProjectSettings.set_setting("rendering/occlusion_culling/bvh_build_quality", 1)
		ProjectSettings.set_setting("rendering/textures/canvas_textures/default_texture_filter", 1)
		ProjectSettings.set_setting("rendering/textures/default_filters/anisotropic_filtering_level", 2)
		ProjectSettings.set_setting("rendering/textures/decals/filter", 2)
		ProjectSettings.set_setting("rendering/textures/light_projectors/filter", 2)
		ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/size", 1024)
		ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality", 2)
		ProjectSettings.set_setting("rendering/lights_and_shadows/positional_shadow/soft_shadow_filter_quality", 2)
		ProjectSettings.set_setting("rendering/lights_and_shadows/positional_shadow/atlas_size", 2048)
		ProjectSettings.set_setting("rendering/global_illumination/gi/use_half_resolution", false)
		ProjectSettings.set_setting("rendering/global_illumination/voxel_gi/quality", 0)
		ProjectSettings.set_setting("rendering/global_illumination/sdfgi/probe_ray_count", 1)
		ProjectSettings.set_setting("rendering/global_illumination/sdfgi/frames_to_converge", 1)
		ProjectSettings.set_setting("rendering/global_illumination/sdfgi/frames_to_update_lights", 0)
		ProjectSettings.set_setting("renderendering/camera/depth_of_field/depth_of_field_bokeh_shapering", 1)
		ProjectSettings.set_setting("rendering/camera/depth_of_field/depth_of_field_bokeh_quality", 1)
		ProjectSettings.set_setting("rendering/environment/ssao/quality", 1)
		ProjectSettings.set_setting("rendering/environment/ssil/quality", 1)
		ProjectSettings.set_setting("rendering/environment/glow/upscale_mode", 1)
		ProjectSettings.set_setting("rendering/environment/screen_space_reflection/roughness_quality", 1)
		ProjectSettings.set_setting("rendering/environment/subsurface_scattering/subsurface_scattering_quality", 1)
		ProjectSettings.set_setting("rendering/environment/volumetric_fog/use_filter", 0)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d", 1)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", 1)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/screen_space_aa", 0)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/use_taa", false)
		ProjectSettings.set_setting("rendering/scaling_3d/mode", 1)
	if setting == 3:
		ProjectSettings.set_setting("rendering/occlusion_culling/bvh_build_quality", 1)
		ProjectSettings.set_setting("rendering/textures/canvas_textures/default_texture_filter", 2)
		ProjectSettings.set_setting("rendering/textures/default_filters/anisotropic_filtering_level", 3)
		ProjectSettings.set_setting("rendering/textures/decals/filter", 3)
		ProjectSettings.set_setting("rendering/textures/light_projectors/filter", 3)
		ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/size", 2048)
		ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality", 3)
		ProjectSettings.set_setting("rendering/lights_and_shadows/positional_shadow/soft_shadow_filter_quality", 3)
		ProjectSettings.set_setting("rendering/lights_and_shadows/positional_shadow/atlas_size", 2048)
		ProjectSettings.set_setting("rendering/global_illumination/gi/use_half_resolution", false)
		ProjectSettings.set_setting("rendering/global_illumination/voxel_gi/quality", 1)
		ProjectSettings.set_setting("rendering/global_illumination/sdfgi/probe_ray_count", 2)
		ProjectSettings.set_setting("rendering/global_illumination/sdfgi/frames_to_converge", 2)
		ProjectSettings.set_setting("rendering/global_illumination/sdfgi/frames_to_update_lights", 0)
		ProjectSettings.set_setting("renderendering/camera/depth_of_field/depth_of_field_bokeh_shapering", 1)
		ProjectSettings.set_setting("rendering/camera/depth_of_field/depth_of_field_bokeh_quality", 2)
		ProjectSettings.set_setting("rendering/environment/ssao/quality", 2)
		ProjectSettings.set_setting("rendering/environment/ssil/quality", 2)
		ProjectSettings.set_setting("rendering/environment/glow/upscale_mode", 1)
		ProjectSettings.set_setting("rendering/environment/screen_space_reflection/roughness_quality", 1)
		ProjectSettings.set_setting("rendering/environment/subsurface_scattering/subsurface_scattering_quality", 1)
		ProjectSettings.set_setting("rendering/environment/volumetric_fog/use_filter", 0)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d", 2)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", 2)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/screen_space_aa", 1)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/use_taa", false)
		ProjectSettings.set_setting("rendering/scaling_3d/mode", 1)
	if setting == 4:
		ProjectSettings.set_setting("rendering/occlusion_culling/bvh_build_quality", 2)
		ProjectSettings.set_setting("rendering/textures/canvas_textures/default_texture_filter", 3)
		ProjectSettings.set_setting("rendering/textures/default_filters/anisotropic_filtering_level", 3)
		ProjectSettings.set_setting("rendering/textures/decals/filter", 4)
		ProjectSettings.set_setting("rendering/textures/light_projectors/filter", 4)
		ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/size", 4096)
		ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality", 4)
		ProjectSettings.set_setting("rendering/lights_and_shadows/positional_shadow/soft_shadow_filter_quality", 4)
		ProjectSettings.set_setting("rendering/lights_and_shadows/positional_shadow/atlas_size", 4096)
		ProjectSettings.set_setting("rendering/global_illumination/gi/use_half_resolution", false)
		ProjectSettings.set_setting("rendering/global_illumination/voxel_gi/quality", 1)
		ProjectSettings.set_setting("rendering/global_illumination/sdfgi/probe_ray_count", 3)
		ProjectSettings.set_setting("rendering/global_illumination/sdfgi/frames_to_converge", 3)
		ProjectSettings.set_setting("rendering/global_illumination/sdfgi/frames_to_update_lights", 0)
		ProjectSettings.set_setting("renderendering/camera/depth_of_field/depth_of_field_bokeh_shapering", 2)
		ProjectSettings.set_setting("rendering/camera/depth_of_field/depth_of_field_bokeh_quality", 2)
		ProjectSettings.set_setting("rendering/environment/ssao/quality", 3)
		ProjectSettings.set_setting("rendering/environment/ssil/quality", 3)
		ProjectSettings.set_setting("rendering/environment/glow/upscale_mode", 1)
		ProjectSettings.set_setting("rendering/environment/screen_space_reflection/roughness_quality", 2)
		ProjectSettings.set_setting("rendering/environment/subsurface_scattering/subsurface_scattering_quality", 2)
		ProjectSettings.set_setting("rendering/environment/volumetric_fog/use_filter", 1)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d", 2)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", 2)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/screen_space_aa", 1)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/use_taa", true)
		ProjectSettings.set_setting("rendering/scaling_3d/mode", 2)
	if setting == 5:
		ProjectSettings.set_setting("rendering/occlusion_culling/bvh_build_quality", 2)
		ProjectSettings.set_setting("rendering/textures/canvas_textures/default_texture_filter", 3)
		ProjectSettings.set_setting("rendering/textures/default_filters/anisotropic_filtering_level", 4)
		ProjectSettings.set_setting("rendering/textures/decals/filter", 5)
		ProjectSettings.set_setting("rendering/textures/light_projectors/filter", 5)
		ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/size", 8192)
		ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality", 5)
		ProjectSettings.set_setting("rendering/lights_and_shadows/positional_shadow/soft_shadow_filter_quality", 5)
		ProjectSettings.set_setting("rendering/lights_and_shadows/positional_shadow/atlas_size", 8192)
		ProjectSettings.set_setting("rendering/global_illumination/gi/use_half_resolution", false)
		ProjectSettings.set_setting("rendering/global_illumination/voxel_gi/quality", 1)
		ProjectSettings.set_setting("rendering/global_illumination/sdfgi/probe_ray_count", 5)
		ProjectSettings.set_setting("rendering/global_illumination/sdfgi/frames_to_converge", 5)
		ProjectSettings.set_setting("rendering/global_illumination/sdfgi/frames_to_update_lights", 0)
		ProjectSettings.set_setting("renderendering/camera/depth_of_field/depth_of_field_bokeh_shapering", 2)
		ProjectSettings.set_setting("rendering/camera/depth_of_field/depth_of_field_bokeh_quality", 3)
		ProjectSettings.set_setting("rendering/environment/ssao/quality", 4)
		ProjectSettings.set_setting("rendering/environment/ssil/quality", 4)
		ProjectSettings.set_setting("rendering/environment/glow/upscale_mode", 1)
		ProjectSettings.set_setting("rendering/environment/screen_space_reflection/roughness_quality", 3)
		ProjectSettings.set_setting("rendering/environment/subsurface_scattering/subsurface_scattering_quality", 3)
		ProjectSettings.set_setting("rendering/environment/volumetric_fog/use_filter", 1)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d", 3)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", 3)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/screen_space_aa", 1)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/use_taa", true)
		ProjectSettings.set_setting("rendering/scaling_3d/mode", 2)
	#ProjectSettings.save_custom("player_settings.godot")
	ProjectSettings.save()


func _on_confirm_button_pressed() -> void:
	save_json()
	default_setting($VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer/GraphicsSettingsOptionButton.get_selected_id())


func save_json():
	data_dict = {
		"graphics_preset":$VBoxContainer/SettingsTabContainer/Graphics/VerticalGraphicsContainer/SplitContainer/GraphicsSettingsOptionButton.get_selected_id()
	}
	print("Saving data to JSON file :", data_dict)
	if not DirAccess.dir_exists_absolute(SAVE_PATH):
		DirAccess.make_dir_absolute(SAVE_PATH)
	var file = FileAccess.open(SAVE_PATH+SAVE_FILE, FileAccess.WRITE)
	var json_text = JSON.stringify(data_dict, "\t")
	file.store_string(json_text)


func load_json():
	print("Loading data from from JSON file")
  
	if FileAccess.file_exists(SAVE_PATH+SAVE_FILE):
		var file = FileAccess.open(SAVE_PATH+SAVE_FILE, FileAccess.READ)

		var json_string = file.get_as_text()
		var json = JSON.new()
		var result = json.parse(json_string)
		if result != OK:
			print("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())
			return

		data_dict = json.data
	else:
		print("No save file to load!")
