extends CanvasLayer

@export var meter_scene : PackedScene

func _ready():
	%ClientText.text = "The Client: " + ScenarioManager.current_scenario_data["client"]["name"]
	%BriefText.text = ScenarioManager.current_scenario_data["client"]["brief"]
	
	load_meters()

func load_meters():
	for meter in ScenarioManager.current_scenario_meters:
		var new_meter = meter_scene.instantiate()
		new_meter.set_meter(meter, ScenarioManager.current_scenario_meters[meter]["value"])
		%MeterGrid.add_child(new_meter)


func _on_enter_button_pressed():
	get_tree().change_scene_to_file("res://scenarios/evergreen_zoo/zoo_interview.tscn")
