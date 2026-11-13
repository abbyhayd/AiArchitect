extends CanvasLayer

func _on_evergreen_zoo_button_pressed():
	ScenarioManager.load_scenario("EvergreenCityZoo")
	get_tree().change_scene_to_file("res://scenarios/evergreen_zoo/zoo_brief.tscn")
