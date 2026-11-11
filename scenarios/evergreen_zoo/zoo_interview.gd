extends CanvasLayer

@export var stakeholder_scene : PackedScene

func _ready():
	load_stakeholders()

func load_stakeholders():
	var index = 0
	for stakeholder in Global.current_scenario_data["client"]["stakeholders"]:
		var new_stakeholder = stakeholder_scene.instantiate()
		var stakeholder_parent = %StakeholderMarkers.get_children()[index]
		if "Left" in stakeholder_parent.name:
			new_stakeholder.flipped = true
			
		new_stakeholder.initalize_stakeholder(
			"res://scenarios/evergreen_zoo/assets/characters/%s.png" % stakeholder["icon"], 
			stakeholder["role"],
			stakeholder["shortQuestion"],
			stakeholder["question"],
			stakeholder["answer"]
			)
		stakeholder_parent.add_child(new_stakeholder)
		index += 1
