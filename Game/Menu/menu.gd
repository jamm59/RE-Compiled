extends Control
@onready var play_sceen: PanelContainer = $PlaySceen
@onready var menu_screen: PanelContainer = $MenuScreen
@onready var _continue: Button = $PlaySceen/VBoxContainer/VBoxContainer/Continue

var gs: GameStateSave = GameStateSave.new()

func _ready() -> void:
	play_sceen.visible = false
	menu_screen.visible = true
	var start_new_game: bool = gs.load_start_game()
	if not start_new_game:
		_continue.disabled = false
		
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
	gs.reset_game_save()
	get_tree().change_scene_to_file("res://Game/story_line.tscn")


func _on_controls_pressed() -> void:
	pass # Replace with function body.
