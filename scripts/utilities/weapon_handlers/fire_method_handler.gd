class_name FireMethodHandler extends Node

var fire_method_resource : FireMethodResource

static func load(fire_method_resource : FireMethodResource) -> FireMethodHandler:
	var fire_method_handler := FireMethodHandler.new()
	fire_method_handler.fire_method_resource = fire_method_resource
	return fire_method_handler
