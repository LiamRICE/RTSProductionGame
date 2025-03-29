extends Node

# TODO - Remove debug timing variables
## Debug variables
const TimingTool:Script = preload("uid://c63jpqrvvcvpa")
var geom_parse:TimingTool = TimingTool.new("Source Geometry Parsing")
var nav_calc:TimingTool = TimingTool.new("Navigation Mesh Baking")
var fow_update_time:TimingTool = TimingTool.new("Fog of War Objects Update")
var fow_position_update_time:float = 0

## Include classes
const FogOfWarTexture:Script = preload("res://scripts/effects/fog_of_war/fog_of_war_texture.gd")
const FogOfWarMesh:Script = preload("res://scripts/effects/fog_of_war/fow_mesh.gd")

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
	Performance.add_custom_monitor("Fog of War/Position Update Time", _get_fow_position_update_time)
	
	## Initialise world timer
	world_timer.timeout.connect(fog_of_war_update)
	
	## Fog of war
	_initialise_fog_of_war(Vector2i((22+1), (26+1)) * fog_of_war_resolution)
	
	## Initialise navigation after the first frame has been processed
	call_deferred("_initialise_navigation")

##----------------##
##-- FOG OF WAR --##
##----------------##

func _initialise_fog_of_war(texture_size:Vector2i) -> void:
	fog_of_war_mesh._initialise_fog_of_war(texture_size)

func fog_of_war_update() -> void:
	self.fow_update_time.debug_timer_start()
	for entity in get_tree().get_nodes_in_group("fog_of_war_propagators"):
		entity.fog_of_war_sprite.position = self.fog_of_war_mesh.world_3d_to_world_2d(entity.position)
	fow_position_update_time = self.fow_update_time.debug_timer_stop()
	
	fog_of_war_texture.fog_of_war_request_texture_update()

func fog_of_war_register_propagator(fow_sprite:Sprite2D, world_position:Vector3) -> void:
	fow_sprite.scale *= self.fog_of_war_resolution
	var position_2d:Vector2 = fog_of_war_mesh.world_3d_to_world_2d(world_position)
	self.fog_of_war_texture.register_entity_sprite(fow_sprite, position_2d)

func fog_of_war_remove_propagator(fow_sprite:Sprite2D) -> void:
	self.fog_of_war_texture.remove_entity_sprite(fow_sprite)

func _get_fow_position_update_time() -> float:
	return fow_position_update_time

##----------------##
##-- NAVIGATION --##
##----------------##

## Initialise navigation map
func _initialise_navigation() -> void:
	## Create the navigation mesh and adjust it's settings
	navigation_mesh = NavigationMesh.new()
	navigation_mesh.cell_height = 0.1
	navigation_mesh.cell_size = 0.1
	navigation_mesh.agent_radius = 0.2
	navigation_mesh.set_parsed_geometry_type(NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS)
	navigation_mesh.set_collision_mask_value(1, true)
	navigation_mesh.set_source_geometry_mode(NavigationMesh.SOURCE_GEOMETRY_ROOT_NODE_CHILDREN)
	navigation_mesh.set_agent_max_climb(0.1)
	navigation_mesh.set_agent_max_slope(30)
	
	## Update navigation server
	source_geometry_data = NavigationMeshSourceGeometryData3D.new()
	navigation_map = NavigationServer3D.get_maps()[0]
	navigation_region = NavigationServer3D.region_create()
	NavigationServer3D.region_set_map(navigation_region, navigation_map)
	update_navigation()

## Starts the baking process for the navigation map. Parses the scene tree and hands the parsed data to the navigation server for baking
func update_navigation():
	geom_parse.debug_timer_start() ## DEBUG
	is_baking = true
	NavigationServer3D.parse_source_geometry_data(navigation_mesh, source_geometry_data, get_tree().root, _bake_navigation)

## Once the scene tree has been parsed, bake the navigation mesh
func _bake_navigation() -> void:
	var time = geom_parse.debug_timer_stop()
	print("Process ", geom_parse.process_name, " completed in ", time, " µs.")
	nav_calc.debug_timer_start()
	NavigationServer3D.bake_from_source_geometry_data_async(navigation_mesh, source_geometry_data, _bake_completed)

## When the navigation mesh has been baked, send the conpleted mesh to the navigation region of the world manager
func _bake_completed() -> void:
	var time = nav_calc.debug_timer_stop()
	print("Process ", nav_calc.process_name, " completed in ", time, " µs.")
	NavigationServer3D.region_set_navigation_mesh(navigation_region, navigation_mesh)
	is_baking = false
	if has_bake_update_queued:
		update_navigation()
