extends CanvasLayer
class_name MCQ

@onready var question_label: RichTextLabel = $Control/Panel/VBoxContainer/PanelContainer/VBoxContainer/QuestionPanel/QuestionLabel
@onready var buttons: Array[Button] = [$Control/Panel/VBoxContainer/PanelContainer/VBoxContainer/AnswerPanel/MarginContainer/HBoxContainer/AnswerButton, $Control/Panel/VBoxContainer/PanelContainer/VBoxContainer/AnswerPanel/MarginContainer/HBoxContainer/AnswerButton2, $Control/Panel/VBoxContainer/PanelContainer/VBoxContainer/AnswerPanel/MarginContainer/HBoxContainer/AnswerButton3, $Control/Panel/VBoxContainer/PanelContainer/VBoxContainer/AnswerPanel/MarginContainer/HBoxContainer/AnswerButton4]
@onready var progress_bar: ProgressBar = $Control/Panel/VBoxContainer/MarginContainer/HBoxContainer/ProgressBar
@onready var count_down_label: RichTextLabel = $Control/Panel/VBoxContainer/MarginContainer/HBoxContainer/MarginContainer/CountDownLabel

var timer: float = 15.0
var tryAgain: bool = true
var tween: Tween
func _ready() -> void:
	progressTimer()
	
	#for
	#
func _process(delta: float) -> void:
	count_down_label.text =  "[font_size=20][b]" + "%2.1f" % timer + "[/b][/font_size]"
	for button: Button in buttons:
		if button.button_pressed:
			handle_button_press(button)
			
func handle_button_press(button: Button) -> void:
	if button.text == "Carbon":
		tryAgain = false
		if tween:
			tween.kill()
			await get_tree().create_timer(1).timeout
			queue_free()
	else:
		tryAgain = true
		
func progressTimer() -> void:
	var time: float = 15
	tween = get_tree().create_tween()
	tween.set_parallel()
	tween.tween_property(progress_bar, "value", 0, time)
	tween.tween_property(self, "timer", 0, time)
	await tween.finished
	if not tryAgain:
		queue_free()
		return
		
	progress_bar.value = 100
	timer = 15.0
	self.progressTimer()
	
