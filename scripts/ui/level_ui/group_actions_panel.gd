extends VBoxContainer

## Loading script classes
const UIStateUtils := preload("uid://cs16g08ckh1rw")
const SelectedUnitsPanel:Script = preload("uid://snd2kowlbx4r")
const ActionsInterface:Script = preload("uid://r3l8d5sfkbuw")
const Selection:Script = preload("uid://cj0c8liafc0fd")

## Child Controls
@export var selected_units_panel:SelectedUnitsPanel
@export var actions_interface:ActionsInterface

func _ready() -> void:
	self.selected_units_panel.sub_selection_changed.connect(self.actions_interface._on_sub_selection_changed)

func _on_player_interface_selection_changed(selection:Selection, selection_type:UIStateUtils.SelectionType):
	self.selected_units_panel._on_player_interface_selection_changed(selection, selection_type)
