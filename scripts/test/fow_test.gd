extends Node3D

@onready var sub_viewport:SubViewport = $Control/SubViewport
@onready var fow_texture:Sprite2D = $Control/SubViewport/FOW_texture
@onready var node_2d:Node2D = $Control/SubViewport/Node2D
@onready var mesh_instance_3d:MeshInstance3D = $MeshInstance3D

var fog_of_war_viewport_texture:ImageTexture

func _ready() -> void:
	fow_texture.texture = ImageTexture.create_from_image(Image.create_empty(128, 128, false, Image.FORMAT_RGBA8))
	await RenderingServer.frame_post_draw
	call_deferred("save_viewport_rendered_texture")

func save_viewport_rendered_texture() -> void:
	mesh_instance_3d.mesh.material.set_shader_parameter("fow_texture", sub_viewport.get_texture())

func _physics_process(delta):
	var texture:ViewportTexture = sub_viewport.get_texture()
	var image_texture:ImageTexture = ImageTexture.create_from_image(texture.get_image())
	mesh_instance_3d.mesh.material.set_shader_parameter("fow_texture", image_texture)
