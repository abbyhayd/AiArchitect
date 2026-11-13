extends Control

@export var meter_scene : PackedScene
var interview_questions_asked = {}

func _ready():
	#%ClientText.text = "The Client: " + ScenarioManager.current_scenario_data["client"]["name"]
	#%BriefText.text = ScenarioManager.current_scenario_data["client"]["brief"]
	
	load_meters()
	
func _process(_delta):
	load_interview_questions()
	
func load_interview_questions():
	var index = 0
	for question in interview_questions_asked:
		%Q_and_As.get_children()[index].text = question + "\n" + interview_questions_asked[question]
		index += 1

func load_meters():
	for meter in ScenarioManager.current_scenario_meters:
		var new_meter = meter_scene.instantiate()
		new_meter.set_meter(meter, ScenarioManager.current_scenario_meters[meter]["value"])
		%MeterGrid.add_child(new_meter)
