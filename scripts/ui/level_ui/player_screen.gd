extends HBoxContainer

@onready var resource_counters:Array = self.get_children()

func set_resources(resource_array:Array):
	var num = mini(len(resource_counters), len(resource_array))
	for i in range(num):
		resource_counters[i].set_resource_amount(resource_array[i])


func set_gatherers(gatherers_array:Array):
	var num = mini(len(resource_counters), len(gatherers_array))
	for i in range(num):
		resource_counters[i].set_resource_gatherers_amount(gatherers_array[i])
