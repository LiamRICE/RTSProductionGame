extends Camera3D


@onready var camera:Node3D = $"../../.."
@onready var yaw:Node3D = $"../.."
@onready var pitch:Node3D = $".."

# Camera Parameters
@export var PAN_SPEED :float = 2
@export var PAN_RESPONSIVENESS :float = 10
@export var ROT_SPEED :float = 2
@export var ROT_SENSITIVITY:float = 1
@export var YAW_RESPONSIVENESS :float = 10
@export var ZOOM_SPEED :float = 300

# Constants
const MAX_HEIGHT :float = 10
const MIN_HEIGHT :float = 3

# Internal Variables
var goal_transform :Transform3D = Transform3D.IDENTITY
var last_mouse_position:Vector2 = Vector2.ZERO
var mouse_position_delta:Vector2 = Vector2.ZERO
var is_rotating:bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pitch.global_rotation = Vector3(-TAU/8, 0, 0)
	yaw.global_rotation = Vector3(0, TAU/8, 0)
	
	self.goal_transform.origin = Vector3(0, (MIN_HEIGHT + MAX_HEIGHT)/2, 0)
	self.goal_transform.basis = camera.transform.basis
	
	camera.global_transform = goal_transform


# Reads input events fired by the engine (eg. mouse motion)
func _input(event:InputEvent) -> void:
	if event is InputEventMouseMotion:
		if self.is_rotating:
			self.mouse_position_delta -= event.relative * self.ROT_SENSITIVITY


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Pan the camera in 2D over the map
	var dir :Vector2 = Input.get_vector("left", "right", "up", "down") * PAN_SPEED * delta * camera.global_transform.origin.y
	var dir_3D :Vector3 = Vector3(dir.x, 0, dir.y)
	
	goal_transform.origin += dir_3D.rotated(Vector3.UP, yaw.global_rotation.y)
	
	# Rotate camera
	## Check if the camera is rotating
	if Input.is_action_just_pressed("rotate_modifier"):
		self.is_rotating = true
		self.last_mouse_position = self.get_viewport().get_mouse_position()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif Input.is_action_just_released("rotate_modifier"):
		self.is_rotating = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		Input.warp_mouse(self.last_mouse_position)
	var rotate_order:float = Input.get_axis("rotate_right", "rotate_left")
	
	## Execute the rotation
	self.goal_transform.basis = self.goal_transform.basis.rotated(Vector3.UP, rotate_order * self.ROT_SPEED * delta + self.mouse_position_delta.x * self.ROT_SPEED * delta).orthonormalized()
	self.mouse_position_delta = Vector2.ZERO
	
	# Zoom the camera in and out
	var zoom_order:float = Input.get_axis("zoom_in", "zoom_out")
	if Input.is_action_just_pressed("zoom_out") and not goal_transform.origin.y >= MAX_HEIGHT:
		goal_transform.origin += Vector3(0, ZOOM_SPEED, 0).rotated(Vector3.LEFT, pitch.global_rotation.x).rotated(Vector3.UP, yaw.global_rotation.y)
	if Input.is_action_just_pressed("zoom_in") and not goal_transform.origin.y <= MIN_HEIGHT:
		goal_transform.origin -= Vector3(0, ZOOM_SPEED, 0).rotated(Vector3.LEFT, pitch.rotation.x).rotated(Vector3.UP, yaw.global_rotation.y)
	
	camera.global_transform.origin = camera.global_transform.origin.lerp(goal_transform.origin, PAN_RESPONSIVENESS * delta)
	yaw.basis = yaw.basis.slerp(goal_transform.basis, YAW_RESPONSIVENESS * delta).orthonormalized()


# Projects the 3D world space coordinate into the camera's 2D screen space
func project_to_screen(point:Vector3) -> Vector2:
	return unproject_position(point)
