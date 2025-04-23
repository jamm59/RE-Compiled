extends Control

@onready var play_sceen: PanelContainer = $PlaySceen
@onready var menu_screen: PanelContainer = $MenuScreen
@onready var option_screen: PanelContainer = $OptionScreen
@onready var control_screen: PanelContainer = $ControlScreen

@onready var allScreens: Array[PanelContainer] = [$PlaySceen, $MenuScreen, $OptionScreen, $ControlScreen]

@onready var _continue: Button = $PlaySceen/VBoxContainer/VBoxContainer/Continue

var gs: GameStateSave = GameStateSave.new()

func _ready() -> void:
	# Show the menu screen by default and hide others
	_show_screen(menu_screen)
	
	# Load game state and configure "Continue" button
	var start_new_game: bool = gs.load_start_game()
	if not start_new_game:
		_continue.disabled = false

func _show_screen(screen_to_show: PanelContainer) -> void:
	for screen in allScreens:
		screen.visible = false
	screen_to_show.visible = true

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_back_pressed() -> void:
	_show_screen(menu_screen)

func _on_play_pressed() -> void:
	_show_screen(play_sceen)

func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://Game/Level 0/Game.tscn")

func _on_new_game_pressed() -> void:
	gs.reset_game_save()
	get_tree().change_scene_to_file("res://Game/story_line.tscn")

func _on_options_pressed() -> void:
	_show_screen(option_screen)

func _on_controls_pressed() -> void:
	_show_screen(control_screen)
