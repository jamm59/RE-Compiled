extends CanvasLayer
class_name MCQ

@onready var question_label: RichTextLabel = $Control/Panel/VBoxContainer/PanelContainer/VBoxContainer/QuestionPanel/QuestionLabel
@onready var buttons: Array[Button] = [$Control/Panel/VBoxContainer/PanelContainer/VBoxContainer/AnswerPanel/MarginContainer/HBoxContainer/AnswerButton, $Control/Panel/VBoxContainer/PanelContainer/VBoxContainer/AnswerPanel/MarginContainer/HBoxContainer/AnswerButton2, $Control/Panel/VBoxContainer/PanelContainer/VBoxContainer/AnswerPanel/MarginContainer/HBoxContainer/AnswerButton3, $Control/Panel/VBoxContainer/PanelContainer/VBoxContainer/AnswerPanel/MarginContainer/HBoxContainer/AnswerButton4]
@onready var progress_bar: ProgressBar = $Control/Panel/VBoxContainer/MarginContainer/HBoxContainer/ProgressBar
@onready var count_down_label: RichTextLabel = $Control/Panel/VBoxContainer/MarginContainer/HBoxContainer/MarginContainer/CountDownLabel
@onready var camera_2d: Camera2D


signal answer_correct


var tween: Tween
var shake_amount: float = 5.0
var timer: float = 15.0
var tryAgain: bool = false
var cameraShake: bool = false

func _ready() -> void:
	visible = false
	
func activate() -> void:
	visible = true
	tryAgain = true
	progressTimer()
	get_tree().paused = true
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

func _process(delta: float) -> void:
	count_down_label.text =  "[font_size=20][b]" + "%2.1f" % timer + "[/b][/font_size]"
	for button: Button in buttons:
		if button.button_pressed:
			handle_button_press(button)
			
	if cameraShake and camera_2d:
		camera_2d.set_offset(Vector2( \
		randf_range(-2.0, 2.0) * shake_amount, \
		randf_range(-2.0, 2.0) * shake_amount \
		))
			
func handle_button_press(button: Button) -> void:
	if button.text == "Carbon":
		answer_correct.emit()
		tryAgain = false
		delete_self()
	else:
		tryAgain = true
		cameraShake = true
		await get_tree().create_timer(1).timeout
		cameraShake = false
		
func progressTimer() -> void:
	var time: float = 15
	tween = get_tree().create_tween()
	tween.set_parallel()
	tween.tween_property(progress_bar, "value", 0, time)
	tween.tween_property(self, "timer", 0, time)
	await tween.finished
	if not tryAgain:
		delete_self()
		return
		
	progress_bar.value = 100
	timer = 15.0
	self.progressTimer()
	
func delete_self() -> void:
	get_tree().paused = false
	if tween:
		tween.kill()
		await get_tree().create_timer(1).timeout
		queue_free()
