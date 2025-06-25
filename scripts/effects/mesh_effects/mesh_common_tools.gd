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
