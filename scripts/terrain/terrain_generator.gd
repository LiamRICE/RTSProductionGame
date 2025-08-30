extends Node3D

## Signals
signal _texture_generated

## Constants
const TerrainChunk:Script = preload("uid://cioet1hqubffq")
const TerrainFeaturesGenerator:Script = preload("uid://olyaxbr30ktx")

## Image to use for map generation
@export_group("Generation Settings")
@export var map_texture:Texture2D
@export var randomise_map:bool = false
@export var map_seed:int = 0

@export_group("Terrain Size")
@export var chunk_size:int = 256 ## The size of each map chunk in metres
@export var map_size:Vector2i = Vector2i(2, 2) ## The total number of chunks in each direction x and z
@export var height:int = 5 ## The number of different height levels in the map.
@export var chunk_subdivision:int = 4: ## How many quads per metre
	set(value):
		if value > 0: chunk_subdivision = value
		else: chunk_subdivision = 1
@export var smooth_terrain:bool = true ## Whether or not to use smooth shading on the resulting terrain

@export_group("Visuals")
@export var terrain_material:Material = preload("uid://x6l5qm4rknwr")

var rng:RandomNumberGenerator = RandomNumberGenerator.new()
var noise:FastNoiseLite = preload("uid://clms0jcq7hsmf")
var quantized_image:Image
var low_resolution_image:Image

var chunks_array:Array[MeshInstance3D] = []

func _ready() -> void:
	self.rng.seed = self.map_seed
	self.chunks_array.resize(self.map_size.x * self.map_size.y)
	
	self._initialise_image()
	RenderingServer.global_shader_parameter_set("world_size", self.map_size)
	await self._texture_generated
	
	self._generate_terrain(self._process_chunk_vertices)
	
	var image:Image = TerrainFeaturesGenerator.generate_features(self.low_resolution_image, self.chunk_subdivision, 10, 0.15, 0.0, self.map_seed)
	var splatmap:ImageTexture = ImageTexture.create_from_image(image)
	$FeaturesMap.texture = splatmap
	$Heightmap.texture = self.low_resolution_image
	
	self.terrain_material.set_shader_parameter("splatmap", splatmap)

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
		self.map_texture = NoiseTexture2D.new()
		self.map_texture.set_width(self.map_size.x * self.chunk_size + 1)
		self.map_texture.set_height(self.map_size.y * self.chunk_size + 1)
		self.map_texture.noise = preload("uid://clms0jcq7hsmf")
		self.map_texture.noise.seed = self.map_seed
		
		print("waiting for texture to generate")
		await self.map_texture.changed
		print("texture generated")
		image = self.map_texture.get_image()
	
	## Fetch the image contained in the texture for quantization and manipulation
	else:
		assert(not self.map_texture == null)
		print("Map is preloaded image")
		self.map_size = Vector2i(self.map_texture.get_size() - Vector2.ONE) / self.chunk_size
		image = self.map_texture.get_image()
	
	## Quantize the image
	self._quantize_image(image, self.height)
	
	## Create the heightmap object and assign it to a static body
	var heightmap:HeightMapShape3D = HeightMapShape3D.new()
	self.low_resolution_image = image.duplicate()
	self.low_resolution_image.convert(Image.FORMAT_RF)
	heightmap.update_map_data_from_image(self.low_resolution_image, 0, self.height * 0.5)
	$StaticBody3D/CollisionShape3D.shape = heightmap
	
	## Upscale the image to keep 1 pixel per vertex
	image.resize(self.map_size.x * self.chunk_size * self.chunk_subdivision + 1,
				self.map_size.y * self.chunk_size * self.chunk_subdivision + 1,
				Image.INTERPOLATE_TRILINEAR)
	self.quantized_image = image
	
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
	self.add_child(chunk_instance)
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
		noise_value * self.height * 0.5,
		vertex.z
	)
