@tool
extends GridMap

## Signals
signal map_generation_completed(size:Vector2i)

## Image to use for map generation
@export var map_texture:Texture2D
@export var randomise_map:bool = false
@export var map_seed:int = 0
@export_tool_button("Generate Map") var _generate_map_method:Callable = self._generate_map
@export_tool_button("Reset Map") var _reset_map_method:Callable = self.clear

@export_group("Map Properties")
@export var size:Vector2i = Vector2(128, 128) ## Size of the map. Must be a power of two or divisible by a power of two (eg. 16, 32, etc...)
@export var height:int = 5 ## The number of different height levels in the map.

## Internal properties
var rng:RandomNumberGenerator
var quantized_image:Image

""" TERRAIN MAP METHODS """

func _ready() -> void:
	## Initialise RNG
	self.rng = RandomNumberGenerator.new()
	self.rng.seed = 0

func initialise_terrain_map() -> void:
	self._generate_map()

""" PROCEDURAL GENERATION METHODS """

func _generate_map() -> void:
	## Clear previous cells
	self.clear()
	
	## Image to be created for CPU map generation
	var image:Image
	
	if self.randomise_map:
		print("Randomising new map")
		self.map_texture = NoiseTexture2D.new()
		self.map_texture.set_width(self.size.x + 1)
		self.map_texture.set_height(self.size.y + 1)
		self.map_texture.noise = preload("uid://clms0jcq7hsmf")
		self.map_texture.noise.seed = self.map_seed
		
		print("waiting for texture to generate")
		await self.map_texture.changed
		print("texture generated")
		image = self.map_texture.get_image()
	
	## Fetch the image contained in the texture for quantization and manipulation
	else:
		print("Map is preloaded image")
		self.size = self.map_texture.get_size() - Vector2.ONE
		image = self.map_texture.get_image()
	
	## Quantize the image
	self._quantize_image(image, self.height)
	
	## Image is saved in R8 format
	self.quantized_image = image
	self.map_texture = ImageTexture.create_from_image(image)
	
	## Quantized image is used to set the terrain type of each cell in a gridmap
	self._generate_gridmap_cells(self, image, self.height)
	
	## DEBUG visualize quantized data
	var material:StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_texture = self.map_texture
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	$MeshInstance3D.mesh.material = material
	
	## Notify map generation complete
	self.map_generation_completed.emit(self.size)

## Takes an input image and quantizes it down to the specified number of levels
func _quantize_image(image:Image, levels:int) -> void:
	for x in range(image.get_width()):
		for y in range(image.get_height()):
			var color:Color = image.get_pixel(x, y)
			var color_vector:Vector3 = snapped(Vector3(color.r, color.g, color.b), Vector3.ONE / (levels - 1))
			image.set_pixel(x, y, Color(color_vector.x, color_vector.y, color_vector.z))

## Takes an input gridmap, a quantized image and a number of levels and assigns cells to the gridmap
func _generate_gridmap_cells(gridmap:GridMap, image:Image, levels:int) -> void:
	for x in range(size.x):
		var x_pos:int = -(size.x / 2) + x ## Calculate x position in gridmap space
		for z in range(size.y):
			var z_pos:int = -(size.y / 2) + z ## Calculate z position in gridmap space
			var vertex_heights:Vector4i = Vector4i(roundi(image.get_pixel(x, z).r * (levels - 1)),
											roundi(image.get_pixel(x, z+1).r * (levels - 1)),
											roundi(image.get_pixel(x+1, z+1).r * (levels - 1)),
											roundi(image.get_pixel(x+1, z).r * (levels - 1)))
			## TODO - Set the cell depending on adjacent cells/heights
			self._select_cell(gridmap, vertex_heights, Vector2i(x_pos, z_pos))

## Takes the heights of the 4 neighbouring vertices
## Returns a Vector3i containing the cell, the orientation, and the height
func _select_cell(gridmap:GridMap, vertex_heights:Vector4i, cell_position:Vector2i) -> void:
	var y_pos:int = max(vertex_heights.w, vertex_heights.x, vertex_heights.y, vertex_heights.z)
	vertex_heights = vertex_heights - Vector4i(y_pos, y_pos, y_pos, y_pos) + Vector4i.ONE
	
	var cell_item:int = 0
	var cell_orientation:int = 0
	match vertex_heights.length_squared():
		4:
			pass ## TODO add cell variation ?
		1:
			cell_item = 11
			if vertex_heights.w == 1:
				cell_orientation = self.get_orthogonal_index_from_basis(Basis(Vector3.RIGHT, Vector3.UP, Vector3.BACK))
			elif vertex_heights.x == 1:
				cell_orientation = self.get_orthogonal_index_from_basis(Basis(Vector3.FORWARD, Vector3.UP, Vector3.RIGHT))
			elif vertex_heights.y == 1:
				cell_orientation = self.get_orthogonal_index_from_basis(Basis(Vector3.LEFT, Vector3.UP, Vector3.FORWARD))
			elif vertex_heights.z == 1:
				cell_orientation = self.get_orthogonal_index_from_basis(Basis(Vector3.BACK, Vector3.UP, Vector3.LEFT))
		2:
			if rng.randf() > 0.7 and gridmap.get_cell_item(Vector3i(cell_position.x - 1, y_pos, cell_position.y)) != 6 and gridmap.get_cell_item(Vector3i(cell_position.x, y_pos, cell_position.y - 1)) != 6:
				cell_item = 6
			else:
				cell_item = 10
			if vertex_heights.w == 1 and vertex_heights.x == 1:
				cell_orientation = self.get_orthogonal_index_from_basis(Basis(Vector3.RIGHT, Vector3.UP, Vector3.BACK))
			elif vertex_heights.x == 1 and vertex_heights.y == 1:
				cell_orientation = self.get_orthogonal_index_from_basis(Basis(Vector3.FORWARD, Vector3.UP, Vector3.RIGHT))
			elif vertex_heights.y == 1 and vertex_heights.z == 1:
				cell_orientation = self.get_orthogonal_index_from_basis(Basis(Vector3.LEFT, Vector3.UP, Vector3.FORWARD))
			elif vertex_heights.z == 1 and vertex_heights.w == 1:
				cell_orientation = self.get_orthogonal_index_from_basis(Basis(Vector3.BACK, Vector3.UP, Vector3.LEFT))
		3:
			cell_item = 12
			if vertex_heights.w == 0:
				cell_orientation = self.get_orthogonal_index_from_basis(Basis(Vector3.LEFT, Vector3.UP, Vector3.FORWARD))
			elif vertex_heights.x == 0:
				cell_orientation = self.get_orthogonal_index_from_basis(Basis(Vector3.BACK, Vector3.UP, Vector3.LEFT))
			elif vertex_heights.y == 0:
				cell_orientation = self.get_orthogonal_index_from_basis(Basis(Vector3.RIGHT, Vector3.UP, Vector3.BACK))
			elif vertex_heights.z == 0:
				cell_orientation = self.get_orthogonal_index_from_basis(Basis(Vector3.FORWARD, Vector3.UP, Vector3.RIGHT))
	
	## Set the cell to be the determined item and orientation at the current position
	self.set_cell_item(Vector3i(cell_position.x, y_pos, cell_position.y), cell_item, cell_orientation)
	return Vector3i(0, 0, y_pos)
