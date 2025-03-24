extends Node

## Debug variables
var time:float

## Navigation Data
var source_geometry_data:NavigationMeshSourceGeometryData3D
var navigation_map:RID
var navigation_region:RID
var navigation_mesh:NavigationMesh

## Navigation state
var is_baking:bool = false
var has_bake_update_queued:bool = false

func _ready() -> void:
	call_deferred("_initialise_navigation")

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

func update_navigation():
	time = Time.get_ticks_usec()
	is_baking = true
	NavigationServer3D.parse_source_geometry_data(navigation_mesh, source_geometry_data, get_tree().root, _bake_navigation)

func _bake_navigation() -> void:
	print("Source geometry parsed in ", Time.get_ticks_usec() - time, " µs.")
	NavigationServer3D.bake_from_source_geometry_data_async(navigation_mesh, source_geometry_data, _bake_completed)

func _bake_completed() -> void:
	time = Time.get_ticks_usec() - time
	print("Navigation baked in ", time, " µs.")
	NavigationServer3D.region_set_navigation_mesh(navigation_region, navigation_mesh)
	is_baking = false
	if has_bake_update_queued:
		update_navigation()
