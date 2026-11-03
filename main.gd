extends Node2D


func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenario_select.tscn")
