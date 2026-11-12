extends CanvasLayer

@export var stakeholder_scene : PackedScene
var num_q_asked = 0

func _ready():
	load_stakeholders()
	
func write_answer(question, answer):
	if num_q_asked+1 >= Global.max_interview_q:
		%Q_and_As.get_children()[num_q_asked].text = question + "\n" + answer
		Global.all_interview_questions_asked = true
		return
	%Q_and_As.get_children()[num_q_asked].text = question + "\n" + answer
	num_q_asked += 1
	
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
			stakeholder["shortAnswer"],
			stakeholder["answer"]
			)
		new_stakeholder.question_asked.connect(write_answer)
		stakeholder_parent.add_child(new_stakeholder)
		index += 1
