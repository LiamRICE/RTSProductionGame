extends Camera3D


@onready var camera:Node3D = $"../../.."
@onready var yaw:Node3D = $"../.."
@onready var pitch:Node3D = $".."

# Camera Parameters
@export var PAN_SPEED :float = 2
@export var PAN_RESPONSIVENESS :float = 10
@export var ROT_SPEED :float = 2
@export var YAW_RESPONSIVENESS :float = 10
@export var ZOOM_SPEED :float = 300

# Constants
const MAX_HEIGHT :float = 10
const MIN_HEIGHT :float = 3

# Internal Variables
var goal_transform :Transform3D = Transform3D.IDENTITY


# Called when the node enters the scene tree for the first time.
func _ready():
	self.goal_transform.origin = Vector3(0, (MIN_HEIGHT + MAX_HEIGHT)/2, 0)
	pitch.global_rotation = Vector3(-TAU/8, 0, 0)
	yaw.global_rotation = Vector3(0, TAU/8, 0)
	
	camera.global_transform = goal_transform


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Pan the camera in 2D over the map
	var dir :Vector2 = Input.get_vector("left", "right", "up", "down") * PAN_SPEED * delta * camera.global_transform.origin.y
	var dir_3D :Vector3 = Vector3(dir.x, 0, dir.y)
	
	goal_transform.origin += dir_3D.rotated(Vector3.UP, yaw.global_rotation.y)
	
	# Rotate camera
	var rotate_order:float = Input.get_axis("rotate_right", "rotate_left")
	goal_transform.basis = goal_transform.basis.rotated(Vector3.UP, rotate_order * ROT_SPEED * delta).orthonormalized()
	
	# Zoom the camera in and out
	if Input.is_action_just_pressed("zoom_out"):
		if not goal_transform.origin.y >= MAX_HEIGHT:
			# TODO - Switch constant zoom to relative speed zoom based on camera height (higher cameras have faster zoom than low down)
			#goal_transform += Vector3(0, ZOOM_SPEED * (goal_transform.y + 1), 0).rotated(Vector3.LEFT, pitch.global_rotation.x)
			goal_transform.origin += Vector3(0, ZOOM_SPEED, 0).rotated(Vector3.LEFT, pitch.global_rotation.x)
	
	if Input.is_action_just_pressed("zoom_in"):
		if not goal_transform.origin.y <= MIN_HEIGHT:
			# TODO - Switch constant zoom to relative speed zoom based on camera height (higher cameras have faster zoom than low down)
			#goal_transform -= Vector3(0, ZOOM_SPEED * (goal_transform.y - 1), 0).rotated(Vector3.LEFT, pitch.global_rotation.x)
			goal_transform.origin -= Vector3(0, ZOOM_SPEED, 0).rotated(Vector3.LEFT, pitch.global_rotation.x)
			#if goal_transform.y <= MIN_HEIGHT:
			#	goal_transform += Vector3(0, MIN_HEIGHT - goal_transform.y, 0).rotated(Vector3.LEFT, pitch.global_rotation.x)
	
	camera.global_transform.origin = camera.global_transform.origin.lerp(goal_transform.origin, PAN_RESPONSIVENESS * delta)
	camera.basis = camera.basis.slerp(goal_transform.basis, YAW_RESPONSIVENESS * delta).orthonormalized()


# Projects the 3D world space coordinate into the camera's 2D screen space
func project_to_screen(point:Vector3) -> Vector2:
	return unproject_position(point)
