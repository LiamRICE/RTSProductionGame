extends MeshInstance3D

## Constants
const FogOfWarTexture:Script = preload("uid://hjkey36jrmgt")

@export var terrain_node:GridMap
@export var fog_of_war_texture:FogOfWarTexture
var texture_size:Vector2i
var terrain_size:Vector2
var terrain_centre:Vector3


## Creates a new fog of war texture and connects the fog_of_war_updated signal to the update function
func _initialise_fog_of_war(new_texture_size:Vector2i) -> void:
	## Initialise the fog of war mesh
	if terrain_node == null:
		push_error("No terrain node assigned to the fog of war mesh.")
		return
	
	var data:PackedByteArray = self._parse_terrain_node()
	self._create_mesh(data)
	
	## Initialise the fog of war texture
	self.texture_size = new_texture_size
	fog_of_war_texture.new_fog_of_war(new_texture_size)
	fog_of_war_texture.fog_of_war_updated.connect(_update_fog_of_war)

func _parse_terrain_node() -> PackedByteArray:
	var max_x:float = 0
	var min_x:float = 0
	var max_z:float = 0
	var min_z:float = 0
	
	## Fing the extents of the current gridmap based terrain
	for cell in self.terrain_node.get_used_cells():
		var pos:Vector3 = self.terrain_node.map_to_local(cell)
		max_x = max(max_x, pos.x)
		max_z = max(max_z, pos.z)
		min_x = min(min_x, pos.x)
		min_z = min(min_z, pos.z)
	
	self.terrain_size = Vector2(max_x - min_x + 1, max_z - min_z + 1) + Vector2(2, 2)
	self.terrain_centre = Vector3((max_x - min_x) / 2 + min_x, 0, (max_z - min_z) / 2 + min_z)
	self.position = terrain_centre
	self.position.y += 0.165
	var cell_minimums:Vector3 = self.terrain_node.local_to_map(Vector3(min_x, 0, min_z))
	
	print("Terrain size : ", terrain_size) ## DEBUG
	
	## Populate heightmap data into an array
	var data_array:Array[float] = []
	data_array.resize(self.terrain_size.x * self.terrain_size.y)
	for cell in self.terrain_node.get_used_cells():
		var pos:Vector2 = Vector2(cell.x - cell_minimums.x, cell.z - cell_minimums.z)
		var index:int = _map_to_index(pos)
		data_array[index] = self.terrain_node.map_to_local(cell).y
	
	## Fill in heightmap edges
	for y in range(0, self.terrain_size.y - 2):
		var index_y_min:int = _map_to_index(Vector2(-1, y))
		var index_y_max:int = index_y_min + self.terrain_size.x - 1
		## Fill x=0 side
		data_array[index_y_min] = data_array[index_y_min + 1]
		## Fill x=x_max side
		data_array[index_y_max] = data_array[index_y_max - 1]
	for x in range(-1, self.terrain_size.x - 1):
		var index_x_min:int = _map_to_index(Vector2(x, -1))
		var index_x_max:int = _map_to_index(Vector2(x, self.terrain_size.y - 2))
		## Fill y=0 side
		data_array[index_x_min] = data_array[index_x_min + self.terrain_size.x]
		## Fill y=y_max side
		data_array[index_x_max] = data_array[index_x_max - self.terrain_size.x]
	
	## Convert data array to PackedByteArray
	var data:PackedByteArray = PackedFloat32Array(data_array).to_byte_array()
	return data

func _create_mesh(data:PackedByteArray) -> void:
	## Create material
	const FOW_FOG_SHADER:Shader = preload("res://scripts/effects/fog_of_war/fow_fog_shader.gdshader")
	var material:ShaderMaterial = ShaderMaterial.new()
	material.shader = FOW_FOG_SHADER
	
	## Create the planemesh
	var planemesh:PlaneMesh = PlaneMesh.new()
	planemesh.size = terrain_size - Vector2(1, 1)
	planemesh.subdivide_width = terrain_size.x - 2 # X subdivisions
	planemesh.subdivide_depth = terrain_size.y - 2 # Z subdivisions
	planemesh.material = material
	
	## Create the image texture heightmap and send it to the fog of war shader
	var image:Image = Image.create_from_data(terrain_size.x, terrain_size.y, false, Image.FORMAT_RF, data)
	var image_texture:ImageTexture = ImageTexture.create_from_image(image)
	material.set_shader_parameter("heightmap", image_texture)
	
	## Set the mesh as the meshinstance's mesh
	self.mesh = planemesh

## Stores the current FOW texture for the minimap and updates the FOW texture in the material shader
func _update_fog_of_war() -> void:
	#print("Updating FOW texture")
	#var FOW_Texture = fog_of_war_scene.fog_of_war_viewport_texture
	self.mesh.material.set_shader_parameter("fow_texture", fog_of_war_texture.fog_of_war_viewport_texture)

## --------------------------- ##
## -- POSITION TRANSFORMERS -- ##
## --------------------------- ##

## Takes the map position if the grid started at 0,0 and returns the index in a 1D array with 1 unit of padding on all sides
func _map_to_index(absolute_map_location:Vector2) -> int:
	return absolute_map_location.x + 1 + (absolute_map_location.y + 1) * (self.terrain_size.x)

func _index_to_map(index:int) -> Vector2:
	var absolute_position:Vector2 = Vector2()
	absolute_position.x = index % roundi(self.terrain_size.x) - 1
	absolute_position.y = index / roundi(self.terrain_size.x) - 1
	return absolute_position

## Converts from 3D world space to UV texture space for fog of war
func _world_3d_to_UV(world_3d_coordinate:Vector3) -> Vector2:
	var absolute_coordinate:Vector3 = world_3d_coordinate - self.terrain_centre + Vector3((self.terrain_size.x - 1) * 0.5, 0, (self.terrain_size.y - 1) * 0.5)
	var unit_centered_coordinate:Vector2 = Vector2(absolute_coordinate.x, absolute_coordinate.z) / ((self.terrain_size - Vector2(1, 1)))
	return unit_centered_coordinate

## Converts from UV texture space to 3D world space for fog of war
func _UV_to_world_3d(unit_centered_coordinate:Vector2) -> Vector3:
	var centered_coordinate:Vector2 = unit_centered_coordinate * ((self.terrain_size - Vector2(1, 1)))
	var world_3d_coordinate:Vector3 = Vector3(centered_coordinate.x, 0, centered_coordinate.y) + self.terrain_centre - Vector3((self.terrain_size.x - 1) / 2, 0, (self.terrain_size.y - 1) / 2)
	return world_3d_coordinate

func _UV_to_world_2d(unit_centered_coordinate:Vector2) -> Vector2:
	var world_2d_coordinate:Vector2 = unit_centered_coordinate * Vector2(self.texture_size)
	return world_2d_coordinate

func _world_2d_to_UV(world_2d_coordinate:Vector2) -> Vector2:
	var uv_coordinate:Vector2 = world_2d_coordinate / Vector2(self.texture_size)
	return uv_coordinate

func world_3d_to_world_2d(world_position:Vector3) -> Vector2:
	return _UV_to_world_2d(_world_3d_to_UV(world_position))

func world_2d_to_world_3d(viewport_position:Vector2) -> Vector3:
	return _UV_to_world_3d(_world_2d_to_UV(viewport_position))
