extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		get_tree().paused = not visible
		visible = not visible


func _on_resume_pressed() -> void:
	print("something")
	visible = false
	get_tree().paused = false


func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://Game/Menu/Menu.tscn")
