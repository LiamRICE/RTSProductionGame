extends PanelContainer

## Signals
signal sub_selection_changed(sub_selection:Selection, selection_type:UIStateUtils.SelectionType)

## Loading script classes
const UIStateUtils := preload("uid://cs16g08ckh1rw")
const Selection:Script = preload("uid://cj0c8liafc0fd")

## Child Control
@export var group_name_label:Label
@export var item_list:ItemList

## Properties
@export_group("Properties")
var categories:Dictionary[int, Selection]
var selection_type:UIStateUtils.SelectionType = UIStateUtils.SelectionType.NONE
@export var group_name:String:
	set(value):
		group_name_label.text = value
		group_name = value

## Selected Units Panel Methods ##

func _ready() -> void:
	self.item_list.item_selected.connect(_on_item_changed)
	self.item_list.empty_clicked.connect(_on_no_item_selected)

func _on_player_interface_selection_changed(selection:Selection, selection_type:UIStateUtils.SelectionType) -> void:
	self.item_list.clear()
	self.categories.clear()
	self.selection_type = selection_type
	if selection_type == self.UIStateUtils.SelectionType.NONE:
		self.sub_selection_changed.emit(self.Selection.new(), self.UIStateUtils.SelectionType.NONE)
		return
	
	self.categories = self.categorise(selection)
	for key in self.categories:
		var ui_info:Array = EntityDatabase.get_ui_info(key)
		self.item_list.add_item(ui_info[0] + " : " + str(self.categories[key].contents.size()), ui_info[3], true)
	
	## Auto select first category
	self.item_list.select(0, true)
	self.item_list.item_selected.emit(0)

func _on_item_changed(index:int) -> void:
	self.sub_selection_changed.emit(self.categories.values()[index], self.selection_type)

func _on_no_item_selected(_at_position:Vector2, _mouse_button_index:int) -> void:
	self.item_list.deselect_all()
	self.sub_selection_changed.emit(self.Selection.new(), self.UIStateUtils.SelectionType.NONE)

## Sort units into categories based on their names
func categorise(selection:Selection) -> Dictionary[int, Selection]:
	var categories:Dictionary[int, Selection]
	
	for entity in selection.contents:
		if categories.has(entity.entity_id):
			categories[entity.entity_id].contents.append(entity)
		else:
			var contents:Array[Entity] = [entity]
			categories[entity.entity_id] = Selection.new(contents)
	return categories
