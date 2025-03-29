extends Control

## Signals
signal fog_of_war_updated ## Emited when the fog of war texture has changed
signal _dissolve_finished ## Emitted when the image compositing on the FOW texture has been completed

## Nodes for rendering the fog of war and tracking unit positions
@onready var fog_of_war_viewport:SubViewport = $FOWViewport
@onready var fog_of_war_camera:Camera2D = $FOWViewport/FOWCamera
@onready var fog_of_war_sprite:Sprite2D = $FOWViewport/FOWTexture
@onready var fog_of_war_units:Node2D = $FOWViewport/FOWUnits

var fog_of_war_bg_image:Image
var fog_of_war_viewport_texture:ViewportTexture
var fog_of_war_viewport_image:Image

## Creates a new fog of war texture of the specified size
func new_fog_of_war(texture_size:Vector2i) -> void:
	fog_of_war_viewport.size = texture_size
	
	## Explicitly tell the camera to render to the subviewport
	assert(fog_of_war_camera.get_viewport() == self.fog_of_war_viewport)
	
	## Create a new image that is the same size as the FOW texture size
	fog_of_war_bg_image = Image.create(texture_size.x, texture_size.y, false, Image.FORMAT_RGBA8)
	fog_of_war_bg_image.fill(Color(0, 0, 0, 1))
	$FOWViewport/FOWUnits/Sprite2D.scale = Vector2.ONE / $FOWViewport/FOWUnits/Sprite2D.texture.get_size() * 8
	
	combined_fow_sprites_texture_update()

func fog_of_war_request_texture_update() -> void:
	fog_of_war_render() ## Convert the texture from the viewport into an image that can be referenced for visibility checks
	
	## Wait until the dissolve is completed before emiting the updated texture
	await _dissolve_finished
	fog_of_war_updated.emit()

func combined_fow_sprites_texture_update() -> void:
	fog_of_war_sprite.set_texture(ImageTexture.create_from_image(fog_of_war_bg_image))

func fog_of_war_render() -> void:
	fog_of_war_viewport_texture = fog_of_war_viewport.get_texture()
	fog_of_war_viewport_image = fog_of_war_viewport_texture.get_image()
	_dissolve_finished.emit()

## ------------------ ##
## -- HANDLE UNITS -- ##
## ------------------ ##

func register_entity_sprite(sprite:Sprite2D, world_2d_position:Vector2) -> void:
	self.fog_of_war_units.add_child(sprite)
	sprite.position = world_2d_position

func remove_entity_sprite(sprite:Sprite2D) -> void:
	self.fog_of_war_units.remove_child(sprite)
	sprite.queue_free()
