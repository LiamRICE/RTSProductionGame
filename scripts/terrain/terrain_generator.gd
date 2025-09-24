@tool
extends Node3D

## Signals
signal _texture_generated

## Constants
const TerrainChunk:Script = preload("uid://cioet1hqubffq")

## Image to use for map generation
@export_group("Generation Settings")
@export var map_texture:Texture2D
@export var height_curve:Curve
@export_subgroup("Randomisation")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var randomise_map:bool = false
@export var map_seed:int = 0
@export var noise:FastNoiseLite = preload("uid://clms0jcq7hsmf")

@export_group("Terrain Size")
@export var chunk_size:int = 256 ## The size of each map chunk in metres
@export var map_size:Vector2i = Vector2i(2, 2) ## The total number of chunks in each direction x and z
@export var height:int = 5 ## The number of different height levels in the map.
@export var chunk_subdivision:int = 4: ## How many quads per metre
	set(value):
		if value > 0: chunk_subdivision = value
		else: chunk_subdivision = 1
@export var smooth_terrain:bool = true ## Whether or not to use smooth shading on the resulting terrain
@export var quantize_terrain:bool = false ## Whether or not to quantise the height of the terrain

@export_group("Textures")
@export var terrain_material:Material = preload("uid://x6l5qm4rknwr")
@export var vegetation_colour:Color = Color("7d835c")
@export var rock_colour:Color = Color("626262")
@export var sand_colour:Color = Color("6d7069")
@export var eroded_colour:Color = Color("888888")

@export_group("Actions")
@export_tool_button("Generate Terrain") var generate_terrain_function:Callable = self._generate
@export_tool_button("Clear Terrain") var clear_terrain_function:Callable = self._clear

var rng:RandomNumberGenerator = RandomNumberGenerator.new()
var quantized_image:Image
var low_resolution_image:Image

var chunks_array:Array[MeshInstance3D] = []

func _ready() -> void:
	if not Engine.is_editor_hint():
		self._generate()

## Initialises the terrain chunks
func _generate_terrain(processing_function:Callable) -> void:
	for x in range(self.map_size.x):
		for z in range(self.map_size.y):
			print("Creating new chunk at ", x, ";",z)
			self._load_chunk(x, z, processing_function)

func _initialise_image():
	## Image to be created for CPU map generation
	var image:Image
	
	if self.randomise_map:
		print("Randomising new map")
		var texture_size:Vector2i = Vector2i(self.map_size.x, self.map_size.y) * self.chunk_size * self.chunk_subdivision + Vector2i.ONE
		self.map_texture = NoiseTexture2D.new()
		self.map_texture.set_width(texture_size.x)
		self.map_texture.set_height(texture_size.y)
		self.map_texture.noise = self.noise
		self.map_texture.noise.seed = self.map_seed
		self.map_texture.noise.frequency = self.map_texture.noise.frequency / self.chunk_subdivision
		
		print("waiting for texture to generate")
		await self.map_texture.changed
		print("texture generated")
		image = self.map_texture.get_image()
	
	## Fetch the image contained in the texture for quantization and manipulation
	else:
		assert(not self.map_texture == null, "No texture assigned to the terrain node !")
		assert(int(self.map_texture.get_size().x) % chunk_size == 0 or int(self.map_texture.get_size().y) % chunk_size == 0)
		print("Map is preloaded image")
		self.map_size = Vector2i(self.map_texture.get_size() - Vector2.ONE) / self.chunk_size
		image = self.map_texture.get_image()
		
	## Reset the noise scale
	if self.randomise_map:
		self.map_texture.noise.frequency = self.map_texture.noise.frequency * self.chunk_subdivision
	
	## Quantize the image
	if self.quantize_terrain:
		self._quantize_image(image, self.height)
	
	## Create the heightmap object and assign it to a static body
	var heightmap:HeightMapShape3D = HeightMapShape3D.new()
	self.low_resolution_image = image.duplicate()
	self.low_resolution_image.convert(Image.FORMAT_RF)
	self._apply_curve_on_image(self.low_resolution_image)
	self.low_resolution_image.resize(self.map_size.x * self.chunk_size + 1, self.map_size.y * self.chunk_size + 1)
	heightmap.update_map_data_from_image(self.low_resolution_image, 0, self.height)
	$StaticBody3D/CollisionShape3D.shape = heightmap
	
	## Upscale the image to keep 1 pixel per vertex
	#image.resize(self.map_size.x * self.chunk_size * self.chunk_subdivision + 1,
				#self.map_size.y * self.chunk_size * self.chunk_subdivision + 1,
				#Image.INTERPOLATE_TRILINEAR)
	self.quantized_image = image
	
	var image_for_data:Image = Image.create_empty(32,32,false,Image.FORMAT_L8)
	image_for_data.blit_rect(image, Rect2i(0,0,32,32), Vector2i(0,0))
	print(image_for_data.get_data())
	
	## Image is saved in R8 format
	self.map_texture = ImageTexture.create_from_image(image)
	self._texture_generated.emit()

## Creates a new MeshInstance3D for the current map settings centred on 0,0
func _load_chunk(x:int, z:int, processing_function:Callable) -> void:
	var chunk_mesh = TerrainChunk.create_chunk(processing_function, self.chunk_size, Vector3(x, 0, z), self.chunk_subdivision, self.smooth_terrain)
	var chunk_instance = MeshInstance3D.new()
	chunk_instance.mesh = chunk_mesh
	chunk_instance.position.x = (float(x) - float(self.map_size.x) / 2) * float(chunk_size)
	chunk_instance.position.z = (float(z) - float(self.map_size.y) / 2) * float(chunk_size)
	chunk_instance.material_override = self.terrain_material
	chunk_instance.set_instance_shader_parameter("chunk_position", Vector2(x, z))
	self.add_child(chunk_instance, false, Node.INTERNAL_MODE_FRONT)
	if not Engine.is_editor_hint():
		chunk_instance.owner = self
	chunks_array[x * self.map_size.y + z] = chunk_instance

## Returns the chunk in the selected absolute x/z position
func _get_chunk_at_position(x, z) -> MeshInstance3D:
	return self.chunks_array[x * map_size.y + z]

## Takes an input image and quantizes it down to the specified number of levels
func _quantize_image(image:Image, levels:int) -> void:
	for x in range(image.get_width()):
		for y in range(image.get_height()):
			var color:Color = image.get_pixel(x, y)
			var color_vector:Vector3 = snapped(Vector3(color.r, color.g, color.b), Vector3.ONE / (levels - 1))
			image.set_pixel(x, y, Color(color_vector.x, color_vector.y, color_vector.z))

## Outputs the position at which the vertex should be displaced to
func _process_chunk_vertices(vertex: Vector3, chunk_position: Vector3) -> Vector3:
	var vertex_global_position:Vector3 = vertex + chunk_position * self.chunk_size
	var noise_value:float = self.quantized_image.get_pixel(floori(vertex_global_position.x * self.chunk_subdivision), floori(vertex_global_position.z * self.chunk_subdivision)).r
	
	## Apply combined falloff to noise
	return Vector3(
		vertex.x,
		noise_value * self.height * self.height_curve.sample(noise_value),
		vertex.z
	)

func _apply_curve_on_image(image:Image) -> void:
	var size:Vector2 = image.get_size()
	for x in size.x:
		for y in size.y:
			var col:Color = image.get_pixel(x, y)
			col = col * height_curve.sample(col.r)
			image.set_pixel(x, y, col)

func _generate() -> void:
	self._clear()
	
	self.rng.seed = self.map_seed
	self.chunks_array.resize(self.map_size.x * self.map_size.y)
	
	self._initialise_image()
	RenderingServer.global_shader_parameter_set("inv_world_size", Vector2.ONE / Vector2(self.map_size))
	RenderingServer.global_shader_parameter_set("inv_world_max_height", 1.0 / self.height)
	await self._texture_generated
	
	self._generate_terrain(self._process_chunk_vertices)
	$Heightmap.texture = self.low_resolution_image
	
	#self.terrain_material.set_shader_parameter("grass_col", Vector3(self.vegetation_colour.r, self.vegetation_colour.g, self.vegetation_colour.b))
	#self.terrain_material.set_shader_parameter("rock_col", Vector3(self.rock_colour.r, self.rock_colour.g, self.rock_colour.b))
	#self.terrain_material.set_shader_parameter("sand_col", Vector3(self.sand_colour.r, self.sand_colour.g, self.sand_colour.b))
	print("\n--- Terrain Bake Completed ---\n")

func _clear() -> void:
	if self.chunks_array.size() > 0:
		## Clear meshes
		for chunk in self.chunks_array:
			chunk.free()
		self.chunks_array.resize(0)
		
		## Clear physics
		$StaticBody3D/CollisionShape3D.shape = null
	
	if self.get_child_count(true) > 5:
		for child in self.get_children(true):
			if child is MeshInstance3D and child != $WaterMesh:
				child.free()
	self.chunks_array.resize(0)
