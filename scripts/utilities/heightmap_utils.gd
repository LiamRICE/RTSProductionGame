@tool
extends EditorScript

func _run() -> void:
	var low_resolution_heightmap:Image = load("uid://ps6jj5321do1").get_image()
	low_resolution_heightmap.resize(512, 512, Image.INTERPOLATE_BILINEAR)
	low_resolution_heightmap.convert(Image.FORMAT_RF)
	
	var height_map_shape:HeightMapShape3D = HeightMapShape3D.new()
	height_map_shape.update_map_data_from_image(low_resolution_heightmap, 0, 25)
	
	ResourceSaver.save(height_map_shape, "res://assets/maps/level0/level0_heightmap_shape.tres")
