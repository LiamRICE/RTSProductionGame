extends Node


static func default_setting(setting:int):
	# Set default values (low settings)
	# Occlusion
	var occlusion_quality:int = 0
	# Textures
	var anisotropic_filtering_level:int = 0
	var decal_filter:int = 0
	var light_filter:int = 0
	# Shadows
	var directional_shadow_size:int = 256
	var directional_shadow_quality:int = 0
	var positional_shadow_size:int = 256
	var positional_shadow_quality:int = 0
	# Lighting
	var half_resolution_lights:bool = true
	var voxel_illumination:int = 0
	var ray_count:int = 0
	var frames_to_converge:int = 0
	var frames_to_update:int = 2
	# Camera
	var bokeh_shape:int = 0
	var bokeh_quality:int = 0
	# Environment
	var ssao:int = 0
	var ssil:int = 0
	var glow_upscale:int = 0
	var ssr:int = 0
	var subsurface_scattering:int = 0
	var volumetric_fog:int = 0
	# AA
	var msaa_2d:int = 0
	var msaa_3d:int = 0
	var ssaa:int = 0
	var use_taa:bool = false
	# Scaling
	var scaling_3d:int = 0
	# Set higher settings quality
	if setting == 1:
		# Occlusion
		occlusion_quality = 0
		# Textures
		anisotropic_filtering_level = 1
		decal_filter = 4
		light_filter = 4
		# Shadows
		directional_shadow_size = 512
		directional_shadow_quality = 1
		positional_shadow_size = 512
		positional_shadow_quality = 1
		# Lighting
		half_resolution_lights = true
		voxel_illumination = 0
		ray_count = 0
		frames_to_converge = 1
		frames_to_update = 1
		# Camera
		bokeh_shape = 0
		bokeh_quality = 0
		# Environment
		ssao = 0
		ssil = 0
		glow_upscale = 0
		ssr = 0
		subsurface_scattering = 0
		volumetric_fog = 0
		# AA
		msaa_2d = 0
		msaa_3d = 0
		ssaa = 1
		use_taa = false
		# Scaling
		scaling_3d = 0
	elif setting == 2:
		# Occlusion
		occlusion_quality = 2
		# Textures
		anisotropic_filtering_level = 2
		decal_filter = 4
		light_filter = 4
		# Shadows
		directional_shadow_size = 1024
		directional_shadow_quality = 2
		positional_shadow_size = 1024
		positional_shadow_quality = 2
		# Lighting
		half_resolution_lights = false
		voxel_illumination = 0
		ray_count = 1
		frames_to_converge = 1
		frames_to_update = 1
		# Camera
		bokeh_shape = 2
		bokeh_quality = 3
		# Environment
		ssao = 4
		ssil = 4
		glow_upscale = 1
		ssr = 3
		subsurface_scattering = 3
		volumetric_fog = 1
		# AA
		msaa_2d = 1
		msaa_3d = 1
		ssaa = 0
		use_taa = false
		# Scaling
		scaling_3d = 1
	elif setting == 3:
		# Occlusion
		occlusion_quality = 2
		# Textures
		anisotropic_filtering_level = 3
		decal_filter = 4
		light_filter = 4
		# Shadows
		directional_shadow_size = 2048
		directional_shadow_quality = 3
		positional_shadow_size = 2048
		positional_shadow_quality = 3
		# Lighting
		half_resolution_lights = false
		voxel_illumination = 1
		ray_count = 2
		frames_to_converge = 2
		frames_to_update = 1
		# Camera
		bokeh_shape = 2
		bokeh_quality = 3
		# Environment
		ssao = 2
		ssil = 2
		glow_upscale = 1
		ssr = 3
		subsurface_scattering = 3
		volumetric_fog = 1
		# AA
		msaa_2d = 1
		msaa_3d = 1
		ssaa = 0
		use_taa = false
		# Scaling
		scaling_3d = 1
	elif setting == 4:
		# Occlusion
		occlusion_quality = 2
		# Textures
		anisotropic_filtering_level = 3
		decal_filter = 5
		light_filter = 5
		# Shadows
		directional_shadow_size = 4096
		directional_shadow_quality = 4
		positional_shadow_size = 4096
		positional_shadow_quality = 4
		# Lighting
		half_resolution_lights = false
		voxel_illumination = 1
		ray_count = 3
		frames_to_converge = 2
		frames_to_update = 0
		# Camera
		bokeh_shape = 2
		bokeh_quality = 3
		# Environment
		ssao = 3
		ssil = 3
		glow_upscale = 1
		ssr = 3
		subsurface_scattering = 3
		volumetric_fog = 1
		# AA
		msaa_2d = 2
		msaa_3d = 2
		ssaa = 0
		use_taa = true
		# Scaling
		scaling_3d = 2
	elif setting == 5:
		# Occlusion
		occlusion_quality = 2
		# Textures
		anisotropic_filtering_level = 4
		decal_filter = 5
		light_filter = 5
		# Shadows
		directional_shadow_size = 8192
		directional_shadow_quality = 5
		positional_shadow_size = 8192
		positional_shadow_quality = 5
		# Lighting
		half_resolution_lights = false
		voxel_illumination = 1
		ray_count = 5
		frames_to_converge = 3
		frames_to_update = 0
		# Camera
		bokeh_shape = 2
		bokeh_quality = 3
		# Environment
		ssao = 4
		ssil = 4
		glow_upscale = 1
		ssr = 3
		subsurface_scattering = 3
		volumetric_fog = 1
		# AA
		msaa_2d = 3
		msaa_3d = 3
		ssaa = 0
		use_taa = true
		# Scaling
		scaling_3d = 2
	
	# Set settings
	# Occlusion
	ProjectSettings.set_setting("rendering/occlusion_culling/bvh_build_quality", occlusion_quality)
	# Textures
	ProjectSettings.set_setting("rendering/textures/default_filters/anisotropic_filtering_level", anisotropic_filtering_level)
	ProjectSettings.set_setting("rendering/textures/decals/filter", decal_filter)
	ProjectSettings.set_setting("rendering/textures/light_projectors/filter", light_filter)
	# Shadows
	ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/size", directional_shadow_size)
	ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality", directional_shadow_quality)
	ProjectSettings.set_setting("rendering/lights_and_shadows/positional_shadow/atlas_size", positional_shadow_size)
	ProjectSettings.set_setting("rendering/lights_and_shadows/positional_shadow/soft_shadow_filter_quality", positional_shadow_quality)
	# Lighting
	ProjectSettings.set_setting("rendering/global_illumination/gi/use_half_resolution", half_resolution_lights)
	ProjectSettings.set_setting("rendering/global_illumination/voxel_gi/quality", voxel_illumination)
	ProjectSettings.set_setting("rendering/global_illumination/sdfgi/probe_ray_count", ray_count)
	ProjectSettings.set_setting("rendering/global_illumination/sdfgi/frames_to_converge", frames_to_converge)
	ProjectSettings.set_setting("rendering/global_illumination/sdfgi/frames_to_update_lights", frames_to_update)
	# Camera
	ProjectSettings.set_setting("renderendering/camera/depth_of_field/depth_of_field_bokeh_shapering", bokeh_shape)
	ProjectSettings.set_setting("rendering/camera/depth_of_field/depth_of_field_bokeh_quality", bokeh_quality)
	# Environment
	ProjectSettings.set_setting("rendering/environment/ssao/quality", ssao)
	ProjectSettings.set_setting("rendering/environment/ssil/quality", ssil)
	ProjectSettings.set_setting("rendering/environment/glow/upscale_mode", glow_upscale)
	ProjectSettings.set_setting("rendering/environment/screen_space_reflection/roughness_quality", ssr)
	ProjectSettings.set_setting("rendering/environment/subsurface_scattering/subsurface_scattering_quality", subsurface_scattering)
	ProjectSettings.set_setting("rendering/environment/volumetric_fog/use_filter", volumetric_fog)
	# AA
	ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d", msaa_2d)
	ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", msaa_3d)
	ProjectSettings.set_setting("rendering/anti_aliasing/quality/screen_space_aa", ssaa)
	ProjectSettings.set_setting("rendering/anti_aliasing/quality/use_taa", use_taa)
	# Scaling
	ProjectSettings.set_setting("rendering/scaling_3d/mode", scaling_3d)
	
	# Save settings
	#ProjectSettings.save_custom("player_settings.godot")
	ProjectSettings.save()
