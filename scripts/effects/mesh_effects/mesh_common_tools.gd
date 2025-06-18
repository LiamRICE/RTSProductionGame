extends RefCounted

## Shader resources
const line_shader:Shader = preload("uid://rlwinoypm2ck")


static func create_line(start:Vector3, end:Vector3, colour:Color = Color.WHITE_SMOKE) -> MeshInstance3D:
	var mesh_instance:MeshInstance3D = MeshInstance3D.new()
	var immediate_mesh:ImmediateMesh = ImmediateMesh.new()
	var material:ShaderMaterial = ShaderMaterial.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(start)
	immediate_mesh.surface_add_vertex(end)
	immediate_mesh.surface_end()
	
	material.shader = line_shader
	mesh_instance.set_instance_shader_parameter("colour", colour)
	mesh_instance.set_instance_shader_parameter("start", start)
	mesh_instance.set_instance_shader_parameter("end", end)
	
	return mesh_instance

static func create_polyline(points:Array[Vector3], colours:Array[Color] = [Color.WHITE_SMOKE]) -> Array[MeshInstance3D]:
	if colours.size() == 0:
		colours = [Color.WHITE_SMOKE]
	
	var meshes:Array[MeshInstance3D] = []
	meshes.resize(points.size() - 1)
	for i in range(points.size() - 1):
		meshes[i] = create_line(points[i], points[i+1], colours[mini(i, colours.size() - 1)])
	return meshes
