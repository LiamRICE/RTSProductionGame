extends RefCounted

var contents:Array[Entity] ## Array of entities contained within this selection

func _init(contents:Array[Entity] = []) -> void:
	self.contents = contents
