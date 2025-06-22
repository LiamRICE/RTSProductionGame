extends PanelContainer

## Signals
signal sub_selection_changed(sub_selection:Array[Entity], selection_type:UIStateUtils.SelectionType)

## Loading script classes
const UIStateUtils := preload("uid://cs16g08ckh1rw")

## Child Control
@export var group_name_label:Label
@export var item_list:ItemList

## Properties
@export_group("Properties")
var categories:Dictionary[int, Array]
var selection_type:UIStateUtils.SelectionType = UIStateUtils.SelectionType.NONE
@export var group_name:String:
	set(value):
		group_name_label.text = value
		group_name = value

## Selected Units Panel Methods ##

func _ready() -> void:
	self.item_list.item_selected.connect(_on_item_changed)
	self.item_list.empty_clicked.connect(_on_no_item_selected)

func _on_player_interface_selection_changed(selection: Array[Entity], selection_type: UIStateUtils.SelectionType) -> void:
	self.item_list.clear()
	self.categories.clear()
	self.selection_type = selection_type
	if selection_type == UIStateUtils.SelectionType.NONE:
		sub_selection_changed.emit(Array(), UIStateUtils.SelectionType.NONE)
		return
	
	self.categories = self.categorise(selection)
	for key in self.categories:
		var ui_name:String = EntityDatabase.get_entity_name(key)
		print("adding item ", ui_name)
		self.item_list.add_item(ui_name + " : " + str(categories[key]), null, true)

func _on_item_changed(index:int) -> void:
	print("Selected ", index)
	sub_selection_changed.emit(categories.values()[index], self.selection_type)

func _on_no_item_selected() -> void:
	print("Deselected all")
	sub_selection_changed.emit(Array(), UIStateUtils.SelectionType.NONE)

## Sort units into categories based on their names
func categorise(selection:Array[Entity]) -> Dictionary[int, Array]:
	var categories:Dictionary[int, Array]
	
	for entity in selection:
		if categories.has(entity.entity_id):
			categories[entity.entity_id].append(entity)
		else:
			categories[entity.entity_id] = [entity]
	
	return categories
