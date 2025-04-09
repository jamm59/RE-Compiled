extends CanvasLayer

@onready var pause_container: VBoxContainer = $Panel/PanelContainer/VBoxContainer/PauseContainer
@onready var controls_container: VBoxContainer = $Panel/PanelContainer/VBoxContainer/ControlsContainer
@onready var title: Label = $Panel/PanelContainer/VBoxContainer/Title


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	controls_container.visible = false
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		get_tree().paused = not visible
		visible = not visible

func _on_resume_pressed() -> void:
	visible = false
	get_tree().paused = false

func _on_exit_pressed() -> void:
	Dialogic.end_timeline(true)
	visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Game/Menu/Menu.tscn")

func _on_check_point_pressed() -> void:
	await get_tree().create_timer(1).timeout
	visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Game/Level 0/Game.tscn")
	#SignalManager.emit_signal("last_checkpoint")

func _on_controls_pressed() -> void:
	controls_container.visible = true
	pause_container.visible = false
	title.text = "Keyboard Controls"
	
func _on_back_pressed() -> void:
	controls_container.visible = false
	pause_container.visible = true
	title.text = "Game Paused"
