extends Node2D

var FILE_PATH = "res://data/zoo.json"
var data

func _ready():
	data = load_json_file(FILE_PATH)
	
	


func load_json_file(file_path: String):
	if FileAccess.file_exists(file_path):
		# Read the entire file content into a string
		var json_as_text = FileAccess.get_file_as_string(file_path)
		
		# Parse the text directly into a Godot Dictionary or Array
		var data = JSON.parse_string(json_as_text)
		
		if data != null:
			return data
		else:
			print("Failed to parse JSON.")
	else:
		print("File does not exist at path: ", file_path)
	return null
