extends Node

static func create_chunk(processor_function:Callable, chunk_size:int, chunk_position:Vector3, unit_subdivision:int = 4, smoothed:bool = true):
	## Create a new surface
	var surface_tool:SurfaceTool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	## Generate grid of positions
	var vertices_per_side:int = chunk_size * unit_subdivision + 1
	var step:float = 1.0 / float(unit_subdivision)
	var vertices:Array[Array] = []
	vertices.resize(vertices_per_side)
	for x in range(vertices_per_side):
		vertices[x] = []
		vertices[x].resize(vertices_per_side)
		for z in range(vertices_per_side):
			var vx = float(x) * step
			var vz = float(z) * step
			vertices[x][z] = processor_function.call(Vector3(vx, 0.0, vz), chunk_position)
	
	## Build quads
	for x in range(vertices_per_side - 1):
		for z in range(vertices_per_side - 1):
			var x0:float = float(x) * step / float(chunk_size)
			var z0:float = float(z) * step / float(chunk_size)
			var x1:float = float(x + 1) * step / float(chunk_size)
			var z1:float = float(z + 1) * step / float(chunk_size)
			
			## Vertex position vector
			var p00:Vector3 = vertices[x][z]
			var p10:Vector3 = vertices[x + 1][z]
			var p01:Vector3 = vertices[x][z + 1]
			var p11:Vector3 = vertices[x + 1][z + 1]
			
			## UVs (normalized between 0..1)
			var uv00:Vector2 = Vector2(x0, z0)
			var uv10:Vector2 = Vector2(x1, z0)
			var uv01:Vector2 = Vector2(x0, z1)
			var uv11:Vector2 = Vector2(x1, z1)
			
			## Assign colors
			## TODO - Add colors for materials/biome masks
			
			# First triangle
			var t1:Plane = Plane(p00, p10, p11)
			var n1:Vector3 = t1.normal
			surface_tool.set_normal(n1); surface_tool.set_uv(uv00); surface_tool.set_tangent(t1); surface_tool.add_vertex(p00)
			surface_tool.set_normal(n1); surface_tool.set_uv(uv10); surface_tool.set_tangent(t1); surface_tool.add_vertex(p10)
			surface_tool.set_normal(n1); surface_tool.set_uv(uv11); surface_tool.set_tangent(t1); surface_tool.add_vertex(p11)
			
			# Second triangle
			var t2:Plane = Plane(p00, p11, p01)
			var n2:Vector3 = t2.normal
			surface_tool.set_normal(n2); surface_tool.set_uv(uv00); surface_tool.set_tangent(t2); surface_tool.add_vertex(p00)
			surface_tool.set_normal(n2); surface_tool.set_uv(uv11); surface_tool.set_tangent(t2); surface_tool.add_vertex(p11)
			surface_tool.set_normal(n2); surface_tool.set_uv(uv01); surface_tool.set_tangent(t2); surface_tool.add_vertex(p01)
	
	## Use the surface tool to generate and smooth normals
	if smoothed: surface_tool.generate_normals()
	surface_tool.generate_tangents()
	
	## Output the generated mesh
	var output_mesh: ArrayMesh = surface_tool.commit()
	return output_mesh
