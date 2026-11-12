extends Control

var tween : Tween
var flipped #true means on left side
var hovered = false
var answer_shown = false
var long_answer
signal question_asked(question, answer)

func _ready():
	pivot_offset = size / 2
	if flipped:
		%IdleBubble.position.x =(%Picture.position.x * 2.0) - %IdleBubble.position.x
		%IdleBubble.flip_h = true
		
		%HoverBubble.position.x =(%Picture.position.x * 2.0) - %HoverBubble.position.x - %HoverBubble.size.x/4
		%HoverBubble.flip_h = true
		
		%AnswerBubble.position.x =(%Picture.position.x * 2.0) - %AnswerBubble.position.x - %AnswerBubble.size.x/8
		%AnswerBubble.flip_h = true
		
func _process(_delta):
	if Input.is_action_just_pressed("left_click") and hovered and not answer_shown and not Global.all_interview_questions_asked:
		%IdleBubble.visible = false
		%HoverBubble.visible = false
		%AnswerBubble.visible = true
		answer_shown = true
		question_asked.emit(%HoverText.text, long_answer)
		
	
func initalize_stakeholder(picture_path, title, short_q, long_q, short_ans, long_ans):
	%Picture.texture = load(picture_path)
	%Title.text = title
	%IdleText.text = short_q
	%HoverText.text = long_q
	%AnswerText.text = short_ans
	long_answer = long_ans
	

func _on_mouse_entered():
	if not answer_shown:
		%IdleBubble.visible = false
		%HoverBubble.visible = true
	hovered = true
	reset_tween()
	tween.tween_property(%Picture, "scale", Vector2(1.1, 1.1), 0.05)
	
func _on_mouse_exited():
	if not answer_shown:
		%IdleBubble.visible = true
		%HoverBubble.visible = false
	hovered = false
	reset_tween()
	tween.tween_property(%Picture, "scale", Vector2.ONE, 0.05)

func reset_tween():
	if tween:
		tween.kill()
	tween = create_tween()
