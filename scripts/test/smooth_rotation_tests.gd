@tool
extends Node3D

const Dynamics:Script = preload("uid://2qt0fxo8oqaa")
const Dynamics2:Script = preload("uid://c5buxdts8tg1k")

@export var basis_to_interpolate_to:Node3D
@export var interpolated_object:Node3D
@export var use_slerp:bool = true

var interpolation_method:Dynamics
var interp_w:Dynamics2

func _ready() -> void:
	var quat:Quaternion = self.interpolated_object.quaternion
	self.interpolation_method = Dynamics.new(0.5, 1.0, 0.0, quat)
	self.interp_w = Dynamics2.new(0.5, 1.0, 0.0, Vector4(quat.x, quat.y, quat.z, quat.w))

func _physics_process(delta:float) -> void:
	if use_slerp:
		self.interpolated_object.quaternion = self.interpolated_object.quaternion.slerp(self.basis_to_interpolate_to.quaternion, 0.1)
	else:
		self.interpolated_object.quaternion = self.interpolation_method.update(delta, self.basis_to_interpolate_to.quaternion)
		#var quat:Quaternion = self.basis_to_interpolate_to.quaternion
		#var vec4:Vector4 = self.interp_w.update(delta, Vector4(quat.x, quat.y, quat.z, quat.w))
		#self.interpolated_object.quaternion = Quaternion(vec4.x, vec4.y, vec4.z, vec4.w)
