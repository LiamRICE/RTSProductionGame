extends Node

# TODO - Remove debug timing variables
## Debug variables
const TimingTool:Script = preload("uid://c63jpqrvvcvpa")
var geom_parse:TimingTool = TimingTool.new("Source Geometry Parsing")
var nav_calc:TimingTool = TimingTool.new("Navigation Mesh Baking")
var geom_parse_time:float = 0
var nav_calc_time:float = 0
var fow_update_time:TimingTool = TimingTool.new("Fog of War Objects Update")
var fow_visibility_update:TimingTool = TimingTool.new("Fog of War Visibility Update")
var fow_position_update_time:float = 0
var fow_visibility_time:float = 0

## Include classes
const FogOfWarTexture:Script = preload("uid://hjkey36jrmgt")
const FogOfWarMesh:Script = preload("uid://cwlxvuyy3e330")
const MapGenerator:Script = preload("uid://dxvkb5diu86pt")
const MeshCommonTools:Script = preload("uid://df6pe6unvfqg6")

## Terrain Generation
@export var map_generator:MapGenerator

## World Ticker
@export var world_timer:Timer

## Fog Of War Data
var fog_of_war_texture:FogOfWarTexture
@export var fog_of_war_mesh:FogOfWarMesh

## Navigation Data
@export_group("Navigation")
var source_geometry_data:NavigationMeshSourceGeometryData3D
var navigation_map:RID
var navigation_cell_size:float = 0.1
var navigation_cell_height:float = 0.1
#var debug_navigation_shader:Shader = preload("uid://cjf4rhl5exh5t")

@export var navigation_chunk_size:Vector2i = Vector2i(32, 32) ## The size of each navigation region. Must be a power of two.
@export_flags_3d_navigation var navigation_layers:int = 1
var navigation_chunks:Array[NavigationChunk] = [] ## Dictionary of chunks. Each chunk is 

## Navigation state
var is_baking:bool = false
var has_bake_update_queued:bool = false

func _ready() -> void:
	## Register monitors for performance
	Performance.add_custom_monitor("Fog of War/Position Update Time", self._get_fow_position_update_time)
	Performance.add_custom_monitor("Fog of War/Visibility Update Time", self._get_fow_visibility_update_time)
	Performance.add_custom_monitor("Navigation/Navigation Bake Time", self._get_nav_bake_time)
	Performance.add_custom_monitor("Navigation/Geometry Parse Time", self._get_nav_parse_time)
	
	## Generate the terrain
	self.map_generator.map_generation_completed.connect(self._initialise_fog_of_war)
	self.map_generator.initialise_terrain_map()
	
	## Initialise world timer
	self.world_timer.timeout.connect(fog_of_war_update)
	
	## Fog of war
	self.fog_of_war_texture = self.fog_of_war_mesh.fog_of_war_texture
	self.fog_of_war_texture.fog_of_war_updated.connect(self._update_visibility)

##----------------##
##-- FOG OF WAR --##
##----------------##

func _initialise_fog_of_war(texture_size:Vector2i) -> void:
	texture_size = (texture_size + Vector2i.ONE) * GameSettings.fog_of_war_resolution
	self.fog_of_war_mesh._initialise_fog_of_war(texture_size)
	
	## Initialise navigation after the first frame has been processed
	self.call_deferred("_initialise_navigation")

func fog_of_war_update() -> void:
	self.fow_update_time.debug_timer_start()
	for entity in self.get_tree().get_nodes_in_group("fog_of_war_propagators"):
		entity.fog_of_war_sprite.position = self.fog_of_war_mesh.world_3d_to_world_2d(entity.position)
	self.fow_position_update_time = self.fow_update_time.debug_timer_stop()
	
	self.fog_of_war_texture.fog_of_war_request_texture_update()

func _update_visibility() -> void:
	self.fow_visibility_update.debug_timer_start()
	for entity in self.get_tree().get_nodes_in_group("units"):
		if not entity.is_in_group("fog_of_war_propagators"):
			entity.update_visibility(self.fog_of_war_mesh.world_3d_to_world_2d(entity.position), self.fog_of_war_texture.fog_of_war_viewport_image)
	self.fow_visibility_time = self.fow_visibility_update.debug_timer_stop()

## Register a sprite as a FoW propagator
func fog_of_war_register_propagator(fow_sprite:Sprite2D, world_position:Vector3) -> void:
	fow_sprite.scale *= GameSettings.fog_of_war_resolution
	var position_2d:Vector2 = self.fog_of_war_mesh.world_3d_to_world_2d(world_position)
	self.fog_of_war_texture.register_entity_sprite(fow_sprite, position_2d)

## Removes the sprite from the FoW system and frees it
func fog_of_war_remove_propagator(fow_sprite:Sprite2D) -> void:
	self.fog_of_war_texture.remove_entity_sprite(fow_sprite)

func _get_fow_position_update_time() -> float: ## Performance monitor debug
	return self.fow_position_update_time
func _get_fow_visibility_update_time() -> float:
	return self.fow_visibility_time

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
	self.navigation_chunks.resize((self.map_generator.size.x / self.navigation_chunk_size.x) * (self.map_generator.size.y / self.navigation_chunk_size.y))
	NavigationChunk.source_geometry_data = self.source_geometry_data ## Set the static variable source_geometry_data
	var index:int = 0
	for x in range(-self.map_generator.size.x / 2 + self.navigation_chunk_size.x / 2, self.map_generator.size.x / 2 + self.navigation_chunk_size.x / 2, self.navigation_chunk_size.x):
		for z in range(-self.map_generator.size.y / 2 + self.navigation_chunk_size.y / 2, self.map_generator.size.y / 2 + self.navigation_chunk_size.y / 2, self.navigation_chunk_size.y):
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
func register_navigation_obstacle(obstacle:Building) -> void:
	print("Registering new obstacle") ## DEBUG
	self.geom_parse.debug_timer_start() ## DEBUG
	var vertices:PackedVector3Array = PackedVector3Array(obstacle.navigation_obstacle.vertices)
	for index in range(vertices.size()):
		vertices.set(index, vertices[index] + obstacle.navigation_obstacle.global_position)
	self.source_geometry_data.add_projected_obstruction(vertices,
														obstacle.navigation_obstacle.global_position.y,
														obstacle.navigation_obstacle.height,
														obstacle.navigation_obstacle.carve_navigation_mesh)
	self.update_navigation_map(obstacle.global_position)

## Parses the navigation source geometry (the terrain map) and then queues a navigation mesh bake
func _parse_navigation_source_geometry() -> void:
	print("Parsing navigation source geometry")
	self.geom_parse.debug_timer_start() ## DEBUG
	NavigationServer3D.parse_source_geometry_data(self.navigation_chunks[0].navigation_mesh, self.source_geometry_data, self.get_tree().root, self.update_navigation_map)

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
			self.navigation_chunks[pos.x * (self.map_generator.size.x / self.navigation_chunk_size.x) + pos.y].update_navigation_map()

func _bake_completed() -> void:
	self.nav_calc_time = nav_calc.debug_timer_stop() ## DEBUG

func _position_to_navigation_chunk_position(location:Vector3) -> Vector2i:
	var location_2d:Vector2i = Vector2i(roundi(location.x), roundi(location.z))
	location_2d -= self.navigation_chunk_size / 2
	return (location_2d.snapped(self.navigation_chunk_size) + self.map_generator.size / 2) / self.navigation_chunk_size

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
		self.position = position
		self.region_rid = NavigationServer3D.region_create()
		## Create the navigation mesh and adjust it's settings
		self.navigation_mesh = NavigationMesh.new()
		self.navigation_mesh.set_cell_height(cell_height)
		self.navigation_mesh.set_cell_size(cell_size)
		self.navigation_mesh.set_agent_radius(cell_size * 2)
		self.navigation_mesh.set_parsed_geometry_type(NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS)
		self.navigation_mesh.set_source_geometry_mode(NavigationMesh.SOURCE_GEOMETRY_ROOT_NODE_CHILDREN)
		self.navigation_mesh.set_sample_partition_type(NavigationMesh.SAMPLE_PARTITION_WATERSHED)
		self.navigation_mesh.set_agent_max_climb(cell_size)
		self.navigation_mesh.set_agent_max_slope(30)
		self.navigation_mesh.set_edge_max_length(5)
		self.navigation_mesh.set_edge_max_error(1.5)
		chunk_size = chunk_size + Vector2i(4, 4)
		self.navigation_mesh.set_filter_baking_aabb(AABB(Vector3(-(chunk_size.x / 2), -4, -(chunk_size.y / 2)), Vector3(chunk_size.x, 12, chunk_size.y)))
		self.navigation_mesh.set_filter_baking_aabb_offset(position)
		self.navigation_mesh.set_border_size(2)
		## Set navigation layers
		self.navigation_mesh.set_collision_mask_value(1, true)
		self.navigation_mesh.set_collision_mask_value(2, false)
		self.navigation_mesh.set_collision_mask_value(3, false)
		
		## Set the region in the navigation server
		NavigationServer3D.region_set_map(self.region_rid, navigation_map)
		self.debug_node = debug_vis_node
		self.debug_shader = debug_shader
	
	func update_navigation_map():
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
