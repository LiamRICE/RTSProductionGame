extends RefCounted

## Shader resources
const line_shader:Shader = preload("uid://rlwinoypm2ck")


static func create_line(start:Vector3, end:Vector3, colour:Color = Color.WHITE_SMOKE) -> MeshInstance3D:
	var mesh_instance:MeshInstance3D = MeshInstance3D.new()
	var immediate_mesh:ImmediateMesh = ImmediateMesh.new()
	var material:ORMMaterial3D = ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(start)
	immediate_mesh.surface_add_vertex(end)
	immediate_mesh.surface_end()
	
	material.albedo_color = colour
	
	return mesh_instance

static func create_polyline(points:PackedVector3Array, colour:Color = Color.WHITE_SMOKE, points_offset:Vector3 = Vector3(0.2, 0.2, 0.2)) -> MeshInstance3D:
	var mesh_instance:MeshInstance3D = MeshInstance3D.new()
	var immediate_mesh:ImmediateMesh = ImmediateMesh.new()
	var material:ORMMaterial3D = ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	for i in range(points.size() - 1):
		immediate_mesh.surface_add_vertex(points[i] + points_offset)
		immediate_mesh.surface_add_vertex(points[i+1] + points_offset)
	immediate_mesh.surface_end()
	
	material.albedo_color = colour
	return mesh_instance

static func convert_navigation_mesh_to_mesh(navigation_mesh:NavigationMesh) -> Mesh:
	assert(not navigation_mesh == null)
	
	var debug_mesh := ArrayMesh.new()
	var arrays := []
	
	var vertices := PackedVector3Array()
	var indices := PackedInt32Array()
	var colors := PackedColorArray()
	
	var polys:PackedVector3Array = navigation_mesh.get_vertices()
	var polygon_count:int = navigation_mesh.get_polygon_count()
		
	var vertex_offset:int = 0
	
	for i in polygon_count:
		var polygon:PackedInt32Array = navigation_mesh.get_polygon(i)
		if polygon.size() < 3:
			continue  # Skip degenerate polygons
			
		var center := Vector3.ZERO
		for j in polygon.size():
			if polygon[j] > polys.size():
				print("polygon : ", polygon[j])
				print("polys : ", polys.size())
			var vertex := polys[polygon[j]]
			vertices.append(vertex)
			colors.append(Color(1, 1, 0, 1)) # Yellow for debug
			center += vertex
		center /= polygon.size()
			
		# Triangulate polygon fan-style (convex assumption)
		for j in range(1, polygon.size() - 1):
			indices.append(vertex_offset)
			indices.append(vertex_offset + j)
			indices.append(vertex_offset + j + 1)
		vertex_offset += polygon.size()
	
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	arrays[Mesh.ARRAY_COLOR] = colors
	
	debug_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return debug_mesh
