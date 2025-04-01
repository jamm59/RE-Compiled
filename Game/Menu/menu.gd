extends Control
@onready var play_sceen: PanelContainer = $PlaySceen
@onready var menu_screen: PanelContainer = $MenuScreen


func _ready() -> void:
	play_sceen.visible = false
	menu_screen.visible = true

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_back_pressed() -> void:
	play_sceen.visible = false
	menu_screen.visible = true


func _on_play_pressed() -> void:
	play_sceen.visible = true
	menu_screen.visible = false


func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://Game/Level 0/Game.tscn")


func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Game/story_line.tscn")
