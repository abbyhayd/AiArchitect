extends Control

@export var meter_scene : PackedScene

func _ready():
	%ClientText.text = "The Client: " + Global.current_scenario_data["client"]["name"]
	%BriefText.text = Global.current_scenario_data["client"]["brief"]
	
	load_meters()

func load_meters():
	for meter in Global.current_scenario_meters:
		var new_meter = meter_scene.instantiate()
		new_meter.set_meter(meter, Global.current_scenario_meters[meter]["value"])
		%MeterGrid.add_child(new_meter)
