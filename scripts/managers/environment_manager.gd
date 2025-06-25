extends Node

## Constants
const MeshCommonTools:Script = preload("uid://df6pe6unvfqg6")

## Nodes
@export var static_effects:Node

## Internal data
var data:Dictionary[Entity, MeshInstance3D] = {}

func add_mesh_path(entity:Entity, path:PackedVector3Array) -> void:
	if self.data.has(entity):
		self.data[entity].free()
		self.data.erase(entity)
	if path.size() <= 0:
		return
	var mesh:MeshInstance3D = MeshCommonTools.create_polyline(path, Color.RED)
	self.data[entity] = mesh
	self.static_effects.add_child(mesh)
	mesh.owner = self.static_effects
