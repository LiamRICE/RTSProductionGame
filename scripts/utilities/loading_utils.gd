extends Node

# define constants
const SAVE_PATH = "user/"
const SAVE_FILE = "settings.json"


static func save_json(data_dict) -> Dictionary:
	print("Saving data to JSON file :", data_dict)
	if not DirAccess.dir_exists_absolute(SAVE_PATH):
		DirAccess.make_dir_absolute(SAVE_PATH)
	var file = FileAccess.open(SAVE_PATH+SAVE_FILE, FileAccess.WRITE)
	var json_text = JSON.stringify(data_dict, "\t")
	file.store_string(json_text)
	return data_dict


static func load_json() -> Dictionary:
	if FileAccess.file_exists(SAVE_PATH+SAVE_FILE):
		var file = FileAccess.open(SAVE_PATH+SAVE_FILE, FileAccess.READ)

		var json_string = file.get_as_text()
		var json = JSON.new()
		var result = json.parse(json_string)
		if result != OK:
			print("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())
			return {}

		var data_dict = json.data
		return data_dict
	else:
		print("No save file to load!")
		return {}
