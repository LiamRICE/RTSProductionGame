extends Node

# TODO - Remove debug timing variables
## Debug variables
const TimingTool:Script = preload("uid://c63jpqrvvcvpa")
var geom_parse:TimingTool = TimingTool.new("Source Geometry Parsing")
var nav_calc:TimingTool = TimingTool.new("Navigation Mesh Baking")
var fow_update_time:TimingTool = TimingTool.new("Fog of War Objects Update")
var fow_visibility_update:TimingTool = TimingTool.new("Fog of War Visibility Update")
var fow_position_update_time:float = 0
var fow_visibility_time:float = 0

## Include classes
const FogOfWarTexture:Script = preload("uid://hjkey36jrmgt")
const FogOfWarMesh:Script = preload("uid://cwlxvuyy3e330")
const MapGenerator:Script = preload("uid://dxvkb5diu86pt")

## Terrain Generation
@export var map_generator:MapGenerator

## World Ticker
@export var world_timer:Timer

## Fog Of War Data
@export var fog_of_war_texture:FogOfWarTexture
@export var fog_of_war_mesh:FogOfWarMesh
@export var fog_of_war_resolution:int = 4 ## Resolution of the fog of war in pixels per metre

## Navigation Data
var source_geometry_data:NavigationMeshSourceGeometryData3D
var navigation_map:RID
var navigation_region:RID
var navigation_mesh:NavigationMesh

## Navigation state
var is_baking:bool = false
var has_bake_update_queued:bool = false

func _ready() -> void:
	## Register monitors for performance
	Performance.add_custom_monitor("Fog of War/Position Update Time", self._get_fow_position_update_time)
	Performance.add_custom_monitor("Fog of War/Visibility Update Time", self._get_fow_visibility_update_time)
	
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
	texture_size = (texture_size + Vector2i.ONE) * self.fog_of_war_resolution
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

func fog_of_war_register_propagator(fow_sprite:Sprite2D, world_position:Vector3) -> void:
	fow_sprite.scale *= self.fog_of_war_resolution
	var position_2d:Vector2 = self.fog_of_war_mesh.world_3d_to_world_2d(world_position)
	self.fog_of_war_texture.register_entity_sprite(fow_sprite, position_2d)

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
	## Create the navigation mesh and adjust it's settings
	self.navigation_mesh = NavigationMesh.new()
	self.navigation_mesh.cell_height = 0.1
	self.navigation_mesh.cell_size = 0.1
	self.navigation_mesh.agent_radius = 0.2
	self.navigation_mesh.set_parsed_geometry_type(NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS)
	self.navigation_mesh.set_collision_mask_value(1, true)
	self.navigation_mesh.set_collision_mask_value(2, false)
	self.navigation_mesh.set_collision_mask_value(3, false)
	self.navigation_mesh.set_source_geometry_mode(NavigationMesh.SOURCE_GEOMETRY_ROOT_NODE_CHILDREN)
	self.navigation_mesh.set_agent_max_climb(0.1)
	self.navigation_mesh.set_agent_max_slope(30)
	self.navigation_mesh.set_edge_max_length(5)
	self.navigation_mesh.set_edge_max_error(0.8)
	self.navigation_mesh.sample_partition_type = NavigationMesh.SAMPLE_PARTITION_WATERSHED
	
	## Update navigation server
	self.source_geometry_data = NavigationMeshSourceGeometryData3D.new()
	if NavigationServer3D.get_maps().size() > 0:
		self.navigation_map = NavigationServer3D.get_maps()[0]
	else:
		self.navigation_map = NavigationServer3D.map_create()
		NavigationServer3D.map_set_cell_size(self.navigation_map, 0.1)
		NavigationServer3D.map_set_cell_height(self.navigation_map, 0.1)
	self.navigation_region = NavigationServer3D.region_create()
	NavigationServer3D.region_set_map(self.navigation_region, self.navigation_map)
	self.update_navigation()

## Starts the baking process for the navigation map. Parses the scene tree and hands the parsed data to the navigation server for baking
func update_navigation():
	if self.is_baking:
		self.has_bake_update_queued = true
		return
	geom_parse.debug_timer_start() ## DEBUG
	self.is_baking = true
	NavigationServer3D.parse_source_geometry_data(self.navigation_mesh, self.source_geometry_data, self.get_tree().root, self._bake_navigation)

## Once the scene tree has been parsed, bake the navigation mesh
func _bake_navigation() -> void:
	var time = geom_parse.debug_timer_stop()
	print("Process ", geom_parse.process_name, " completed in ", time, " µs.")
	nav_calc.debug_timer_start()
	NavigationServer3D.bake_from_source_geometry_data_async(self.navigation_mesh, self.source_geometry_data, self._bake_completed)

## When the navigation mesh has been baked, send the conpleted mesh to the navigation region of the world manager
func _bake_completed() -> void:
	var time = nav_calc.debug_timer_stop()
	print("Process ", nav_calc.process_name, " completed in ", time, " µs.")
	NavigationServer3D.region_set_navigation_mesh(self.navigation_region, self.navigation_mesh)
	NavigationServer3D.region_set_transform(self.navigation_region, Transform3D(Basis.IDENTITY, Vector3(0, -self.navigation_mesh.agent_radius, 0)))
	NavigationServer3D.set_debug_enabled(true)
	
	## DEBUG - create a dummy region for debugging
	var region:NavigationRegion3D = NavigationRegion3D.new()
	region.navigation_mesh = self.navigation_mesh
	region.enabled = false
	self.add_child(region)
	region.owner = self
	
	## Check if another map bake is queued
	self.is_baking = false
	if self.has_bake_update_queued:
		self.has_bake_update_queued = false
		self.update_navigation()
