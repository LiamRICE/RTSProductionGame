extends Node

# TODO - Remove debug timing variables
## Debug variables
const TimingTool:Script = preload("uid://c63jpqrvvcvpa")
var geom_parse:TimingTool = TimingTool.new("Source Geometry Parsing")
var nav_calc:TimingTool = TimingTool.new("Navigation Mesh Baking")
var geom_parse_time:float = 0
var nav_calc_time:float = 0

## Include classes
const MeshCommonTools:Script = preload("uid://df6pe6unvfqg6")

## World Ticker
@export var world_timer:Timer

## Heightmap
@export_group("Heightmap Physics Settings")
@export var heightmap:Texture2D
@export var physics_heightmap_resolution:Vector2i = Vector2i(512, 512)
var heightmap_image:Image


## Navigation Data
@export_group("Navigation")
var source_geometry_data:NavigationMeshSourceGeometryData3D
var navigation_map:RID
var navigation_cell_size:float = ProjectSettings.get_setting("navigation/3d/default_cell_size")
var navigation_cell_height:float = ProjectSettings.get_setting("navigation/3d/default_cell_height")

@export var terrain3D:Terrain3D
@export var terrain3D_size:Vector2i = Vector2i(8192, 8192)
@export var navigation_chunk_size:Vector2i = Vector2i(1024, 1024) ## The size of each navigation region. Must be a power of two.
@export_flags_3d_physics var physics_layers_used_in_bake:int = 8
@export_flags_3d_navigation var navigation_layers:int = 1
var navigation_chunks:Array[NavigationChunk] = [] ## Dictionary of chunks. Each chunk is 
var obstacles:Dictionary[Entity, NavigationObstacle3D]

## Navigation state
var is_baking:bool = false
var has_bake_update_queued:bool = false


func _ready() -> void:
	## Register monitors for performance
	Performance.add_custom_monitor("Navigation/Navigation Bake Time", self._get_nav_bake_time)
	Performance.add_custom_monitor("Navigation/Geometry Parse Time", self._get_nav_parse_time)
	
	## Entity updates
	EventBus.on_entity_destroyed.connect(self._on_entity_destroyed)
	EventBus.on_new_obstacle_created.connect(self._on_new_obstacle_instantiated)
	
	## Database initialisation
	if not self.heightmap == null:
		self.heightmap_image = self.heightmap.get_image()
	else:
		printerr("No heightmap specified. No HeightMapShape will be built.")
	TerrainDatabase.update_level_data(0, self.terrain3D, self.heightmap_image)
	
	## Initialise physics for raycasting terrain intersections
	if $TerrainPhysicsBody/TerrainCollisionShape.shape == null:
		self._bake_heightmap_shape()
	
	self._initialise_navigation()

func _on_entity_destroyed(entity:Entity) -> void:
	print("Entity destroyed")
	if self.obstacles.has(entity):
		self.obstacles[entity].free()
		self.obstacles.erase(entity)
	self.source_geometry_data.clear_projected_obstructions()

func _on_new_obstacle_instantiated(entity:Entity, obstacle:NavigationObstacle3D) -> void:
	self.obstacles[entity] = obstacle
	obstacle.reparent($NavigationObjects)
	obstacle.global_position.y = 0.0
	if not obstacle.is_in_group("navigation_geometry_parse"):
		obstacle.add_to_group("navigation_geometry_parse")
	self.register_navigation_obstacle(entity)

##-------------##
##-- PHYSICS --##
##-------------##


func _bake_heightmap_shape() -> void:
	var low_resolution_heightmap:Image = self.heightmap_image.duplicate()
	low_resolution_heightmap.resize(self.physics_heightmap_resolution.x, self.physics_heightmap_resolution.y, Image.INTERPOLATE_BILINEAR)
	low_resolution_heightmap.convert(Image.FORMAT_RF)
	
	var uniform_scale:float = float(self.terrain3D_size.x) / float(self.physics_heightmap_resolution.x)
	
	var height_map_shape:HeightMapShape3D = HeightMapShape3D.new()
	height_map_shape.update_map_data_from_image(low_resolution_heightmap, 0, 25)
	print(25 * uniform_scale)
	
	$TerrainPhysicsBody/TerrainCollisionShape.shape = height_map_shape
	$TerrainPhysicsBody/TerrainCollisionShape.scale = Vector3(uniform_scale, uniform_scale, uniform_scale)


##----------------##
##-- NAVIGATION --##
##----------------##


## Initialise navigation map
func _initialise_navigation() -> void:
	## Update navigation server
	self.source_geometry_data = NavigationMeshSourceGeometryData3D.new()
	if NavigationServer3D.get_maps().size() > 0:
		self.navigation_map = NavigationServer3D.get_maps()[0]
	else:
		self.navigation_map = NavigationServer3D.map_create()
		NavigationServer3D.map_set_cell_size(self.navigation_map, self.navigation_cell_size)
		NavigationServer3D.map_set_cell_height(self.navigation_map, self.navigation_cell_height)
	
	## Create the navigation chunks
	self.navigation_chunks.resize((self.terrain3D_size.x / self.navigation_chunk_size.x) * (self.terrain3D_size.y / self.navigation_chunk_size.y))
	print(self.navigation_chunk_size)
	assert(self.navigation_chunks.size() <= 1024, "Too many Navigation Chunks. Reduce navigation chunk size.")
	NavigationChunk.source_geometry_data = self.source_geometry_data ## Set the static variable source_geometry_data
	var index:int = 0
	for x in range(-self.terrain3D_size.x / 2 + self.navigation_chunk_size.x / 2, self.terrain3D_size.x / 2 + self.navigation_chunk_size.x / 2, self.navigation_chunk_size.x):
		for z in range(-self.terrain3D_size.y / 2 + self.navigation_chunk_size.y / 2, self.terrain3D_size.y / 2 + self.navigation_chunk_size.y / 2, self.navigation_chunk_size.y):
			var chunk:NavigationChunk = NavigationChunk.new(Vector3(x, 0, z), self.navigation_map, self.navigation_chunk_size, self.navigation_cell_size, self.navigation_cell_height, $DebugNavRegions)
			chunk.bake_completed.connect(self._bake_completed)
			self.navigation_chunks[index] = chunk
			index += 1
	
	## Start the navigation baking
	self._parse_navigation_source_geometry()

## Starts the baking process for the navigation map. Uses the navigation mesh source geometry data and sends it to the navigation server for baking.
## Queues a bake if one is already underway
func update_navigation_map(location:Vector3 = Vector3.ZERO):
	self.geom_parse_time = geom_parse.debug_timer_stop() ## DEBUG
	print("Baking navigation")
	self._bake_navigation(location)

## Registers the building as a navigation obstacle and queues a rebake of the navigation mesh. Must be called after placing the building in it's final location.
func register_navigation_obstacle(obstacle:Entity) -> void:
	assert(obstacle is Building or obstacle is Resources)
	print("Registering new obstacle") ## DEBUG
	self.geom_parse.debug_timer_start() ## DEBUG
	var vertices:PackedVector3Array = PackedVector3Array(obstacle.navigation_obstacle.vertices)
	for index in range(vertices.size()):
		vertices.set(index, vertices[index] + obstacle.navigation_obstacle.global_position)#Vector3(obstacle.navigation_obstacle.global_position.x, 0.0, obstacle.navigation_obstacle.global_position.z))
	#self.source_geometry_data.add_projected_obstruction(vertices, 0.0,
														#obstacle.navigation_obstacle.height * 32,
														#obstacle.navigation_obstacle.carve_navigation_mesh)
	NavigationServer3D.parse_source_geometry_data(self.navigation_chunks[0].navigation_mesh, self.source_geometry_data, $NavigationObjects)
	self.update_navigation_map(obstacle.global_position)

func remove_navigation_obstacle(entity:Entity) -> void:
	print("Removing Obstacle")
	self.obstacles[entity].free()
	self.obstacles.erase(entity)
	## Rebake the source geometry data
	NavigationServer3D.parse_source_geometry_data(self.navigation_chunks[0].navigation_mesh, self.source_geometry_data, $NavigationObjects)
	self.update_navigation_map(entity.global_position)
	#self._parse_navigation_source_geometry()
	

## Parses the navigation source geometry (the terrain map) and then queues a navigation mesh bake
func _parse_navigation_source_geometry() -> void:
	print("Parsing navigation source geometry")
	self.geom_parse.debug_timer_start() ## DEBUG
	NavigationServer3D.parse_source_geometry_data(self.navigation_chunks[0].navigation_mesh, self.source_geometry_data, $NavigationObjects, self.update_navigation_map)

## Once the scene tree has been parsed, bake the navigation mesh
func _bake_navigation(location:Vector3 = Vector3.ZERO) -> void:
	self.nav_calc.debug_timer_start() ## DEBUG
	if location == Vector3.ZERO:
		print("All chunks baking...") ## DEBUG
		for chunk in self.navigation_chunks:
			chunk.update_navigation_map()
	else:
		## Find which chunks are affected by the navigation rebake
		var positions_array:Array[Vector2i] = []
		for x in range(-4, 5, 8):
			for y in range(-4, 5, 8):
				var loc:Vector2i = _position_to_navigation_chunk_position(location + Vector3(x, 0, y))
				if not positions_array.has(loc): positions_array.append(loc)
		## Update these chunks
		for pos in positions_array:
			print("Updating positions : ", pos, " for location ", location)
			print(self.navigation_chunks[pos.x * (self.terrain3D_size.x / self.navigation_chunk_size.x) + pos.y].position)
			self.navigation_chunks[pos.x * (self.terrain3D_size.x / self.navigation_chunk_size.x) + pos.y].update_navigation_map()

func _bake_completed() -> void:
	self.nav_calc_time = nav_calc.debug_timer_stop() ## DEBUG

func _position_to_navigation_chunk_position(location:Vector3) -> Vector2i:
	var location_2d:Vector2i = Vector2i(roundi(location.x), roundi(location.z))
	location_2d -= self.navigation_chunk_size / 2
	return (location_2d.snapped(self.navigation_chunk_size) + self.terrain3D_size / 2) / self.navigation_chunk_size

func _get_nav_bake_time() -> float:
	return self.nav_calc_time

func _get_nav_parse_time() -> float:
	return self.geom_parse_time

########################
## NAVIGATION CLASSES ##
########################

class NavigationChunk:
	## Static variables
	static var source_geometry_data:NavigationMeshSourceGeometryData3D
	## Chunk variables
	var position:Vector3
	var region_rid:RID
	var navigation_mesh:NavigationMesh
	## Control variables
	var is_baking:bool = false
	var has_bake_update_queued:bool = false
	## Debug
	var debug_node:Node
	var debug_region:NavigationRegion3D = NavigationRegion3D.new()
	var debug_shader:Shader
	var debug_material:ShaderMaterial = ShaderMaterial.new()
	signal bake_completed
	
	func _init(position:Vector3, navigation_map:RID, chunk_size:Vector2i, cell_size:float, cell_height:float, debug_vis_node:Node = null, debug_shader:Shader = null) -> void:
		var cell_padding:float = cell_size * 4
		self.position = position
		self.region_rid = NavigationServer3D.region_create()
		## Create the navigation mesh and adjust it's settings
		self.navigation_mesh = NavigationMesh.new()
		self.navigation_mesh.set_cell_height(cell_height)
		self.navigation_mesh.set_cell_size(cell_size)
		self.navigation_mesh.set_agent_radius(cell_size * 2)
		self.navigation_mesh.set_parsed_geometry_type(NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS)
		self.navigation_mesh.set_source_geometry_mode(NavigationMesh.SOURCE_GEOMETRY_GROUPS_EXPLICIT)
		self.navigation_mesh.set_source_group_name("navigation_geometry_parse")
		self.navigation_mesh.set_sample_partition_type(NavigationMesh.SAMPLE_PARTITION_WATERSHED)
		self.navigation_mesh.set_agent_max_climb(cell_size)
		self.navigation_mesh.set_agent_max_slope(30)
		self.navigation_mesh.set_agent_height(cell_size)
		self.navigation_mesh.set_edge_max_length(0)
		self.navigation_mesh.set_edge_max_error(1.5)
		chunk_size = chunk_size + Vector2i(cell_padding * 2, cell_padding * 2)
		self.navigation_mesh.set_filter_baking_aabb(AABB(Vector3(-(chunk_size.x / 2), -(cell_padding * 2), -(chunk_size.y / 2)), Vector3(chunk_size.x, cell_padding * 2, chunk_size.y)))
		self.navigation_mesh.set_filter_baking_aabb_offset(position)
		self.navigation_mesh.set_border_size(cell_padding)
		## Set navigation layers
		self.navigation_mesh.set_collision_mask_value(1, true)
		self.navigation_mesh.set_collision_mask_value(2, false)
		self.navigation_mesh.set_collision_mask_value(3, false)
		
		## Set the region in the navigation server
		NavigationServer3D.region_set_map(self.region_rid, navigation_map)
		NavigationServer3D.region_set_transform(self.region_rid, Transform3D(Basis.IDENTITY, Vector3(0, -cell_size, 0)))
		self.debug_node = debug_vis_node
		self.debug_shader = debug_shader
	
	func update_navigation_map() -> void:
		if self.is_baking:
			self.has_bake_update_queued = true
			return
		else:
			self._bake_navigation()
	
	func _bake_navigation() -> void:
		self.is_baking = true
		NavigationServer3D.bake_from_source_geometry_data_async(self.navigation_mesh, self.source_geometry_data, self._bake_completed)
	
	func _bake_completed() -> void:
		NavigationServer3D.region_set_navigation_mesh(self.region_rid, self.navigation_mesh)
		NavigationServer3D.region_set_transform(self.region_rid, Transform3D(Basis.IDENTITY, Vector3(0, -self.navigation_mesh.agent_radius, 0)))
		
		## Check is the debug vis node is added
		if not self.debug_node == null:
			self.debug_region.navigation_mesh = self.navigation_mesh
			if self.debug_region.get_parent() == null:
				self.debug_region.enabled = false
				self.debug_node.add_child(self.debug_region)
				self.debug_region.owner = self.debug_node
		
		self.bake_completed.emit() ## Debug
		
		## Check if another map bake is queued
		self.is_baking = false
		if self.has_bake_update_queued:
			self.has_bake_update_queued = false
			self.update_navigation_map()
