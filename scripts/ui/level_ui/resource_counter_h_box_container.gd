class_name ResourceCounterHBoxContainer extends HBoxContainer

@export_category("Info")
@export var icon:Texture2D
@export var icon_name:String = ""

@onready var container:HBoxContainer = $"."
@onready var texture_rect:TextureRect = $MarginContainer/ResourceIconTextureRect
@onready var resource_amount_label:RichTextLabel = $ResourceAmountLabel
@onready var resource_num_gatherers_label:RichTextLabel = $ResourceNumGatherersLabel

func _ready():
	# set the assigned texture
	if icon != null:
		texture_rect.texture = icon
	container.tooltip_text = icon_name


func set_resource_amount(amount:int):
	resource_amount_label.text = "[b]" + str(amount) + "[/b]"


func set_resource_gatherers_amount(amount:int):
	if amount < 10:
		resource_num_gatherers_label.text = "[0" + str(amount) + "]"
	else:
		resource_num_gatherers_label.text = "[" + str(amount) + "]"
