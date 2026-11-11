extends Control

var tween : Tween
var flipped #true means on left side

func _ready():
	pivot_offset = size / 2
	if flipped:
		%IdleBubble.position.x =(%Picture.position.x * 2.0) - %IdleBubble.position.x
		%IdleBubble.flip_h = true
		
		%HoverBubble.position.x =(%Picture.position.x * 2.0) - %HoverBubble.position.x - %HoverBubble.size.x/2
		%HoverBubble.flip_h = true
		
		%AnswerBubble.position.x =(%Picture.position.x * 2.0) - %AnswerBubble.position.x
		%AnswerBubble.flip_h = true

func initalize_stakeholder(picture_path, title, short_q, long_q, ans):
	%Picture.texture = load(picture_path)
	%Title.text = title
	%IdleText.text = short_q
	%HoverText.text = long_q
	%AnswerText.text = ans

func _on_mouse_entered():
	%IdleBubble.visible = false
	%HoverBubble.visible = true
	reset_tween()
	tween.tween_property(%Picture, "scale", Vector2(1.1, 1.1), 0.05)
	
func _on_mouse_exited():
	%IdleBubble.visible = true
	%HoverBubble.visible = false
	reset_tween()
	tween.tween_property(%Picture, "scale", Vector2.ONE, 0.05)

func reset_tween():
	if tween:
		tween.kill()
	tween = create_tween()
