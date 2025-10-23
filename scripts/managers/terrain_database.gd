extends Node

## Properties
var level_index:int
var level_terrain:Terrain3D
var level_heightmap:Image

## Methods
func query_height(global_position:Vector3) -> float:
	if self.level_terrain != null:
		var value:float = self.level_terrain.data.get_height(global_position)
		if not is_nan(value):
			return value
		else:
			return 0.0
	else:
		return 0.0

func batch_query_height(global_position_array:PackedVector3Array) -> PackedFloat32Array:
	var return_array:PackedFloat32Array = PackedFloat32Array()
	return_array.resize(global_position_array.size())
	for index:int in range(global_position_array.size()):
		var result:int = self.level_terrain.data.get_height(global_position_array[index])
		return_array[index] = result if not result == NAN else 0
	return return_array

func update_level_data(_level_index:int, _level_terrain:Terrain3D, _level_heightmap:Image) -> void:
	self.level_index = _level_index
	self.level_terrain = _level_terrain
	self.level_heightmap = _level_heightmap
