extends Control

	
func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://Game/Level 0/Game.tscn")
