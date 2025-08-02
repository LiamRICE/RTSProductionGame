extends RefCounted

var contents:Array[Entity]

func _init(contents:Array[Entity] = []) -> void:
	self.contents = contents
