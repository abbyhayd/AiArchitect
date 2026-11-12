extends Node

var scenario_paths = {
	"EvergreenCityZoo" : "res://data/zoo.json"
}

var current_scenario_data
var current_scenario_meters = {}
var current_room

var max_interview_q
var interview_questions_asked = {}
var all_interview_questions_asked

var room_reached

func load_scenario(scenario_name):
	if scenario_name not in scenario_paths:
		push_error("Scenario doesn't exist.")
		return
	current_scenario_data = load_json_file(scenario_paths[scenario_name])
	max_interview_q = current_scenario_data["client"]["discovery"]["maxQuestions"]
	load_scenario_meters()

func load_scenario_meters():
	for meter in current_scenario_data["meters"]:
		current_scenario_meters[meter["name"]] = {
			"start": meter["start"],
			"value": meter["start"],
			"target": meter["target"],
			"priority": meter["priority"]
		}

func reset_scenario():
	pass

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
