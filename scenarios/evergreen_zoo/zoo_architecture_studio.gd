extends CanvasLayer

@export var decision : PackedScene

func _ready():
	var index = 0
	for question in ScenarioManager.architecture_questions:
		var new_v_scroll = ScrollContainer.new()
		new_v_scroll.name = question["prompt"]
		
		var new_v_box = VBoxContainer.new()
		new_v_box.add_theme_constant_override("separation", 340)
		
		new_v_scroll.add_child(new_v_box)
		%TabContainer.add_child(new_v_scroll)
		
		for option in ScenarioManager.architecture_decisions[index]:
			var new_decision = decision.instantiate()
			new_decision.initialize(
				option["label"],
				option["cost"],
				option["helperText"]
			)
			new_v_box.add_child(new_decision)
		index += 1
