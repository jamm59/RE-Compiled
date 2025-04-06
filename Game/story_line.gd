extends Control

@onready var storyline = {
	1: {
		"text": "Excited by the idea of easy success, he lets AI handle all his assignments.",
		"img_src": preload("res://Assets/storyline/1.png")
	},
	2: {
		"text": "Over time, something feels off. Getting work done without learning starts to feel empty.",
		"img_src": preload("res://Assets/storyline/2.png")
	},
	3: {
		"text": "One late night, exhaustion takes over, and he falls asleep at his desk.",
		"img_src": preload("res://Assets/storyline/3.png")
	},
	4: {
		"text": "As he sleeps, his hand knocks over a drink, spilling liquid across his computer and desk.",
		"img_src": preload("res://Assets/storyline/4.png")
	},
	5: {
		"text": "Something changes. The AI, once just a tool, suddenly becomes aware.",
		"img_src": preload("res://Assets/storyline/5.png")
	},
	6: {
		"text": "A surge of electricity pulses through the machine. The AI retaliates, pulling him into the digital world.",
		"img_src": preload("res://Assets/storyline/6.png")
	},
	7: {
		"text": "He's gone. Trapped inside the system. The only way out is to learn what he once ignored.",
		"img_src": preload("res://Assets/storyline/7.png")
	}
}

@onready var texture_rect: TextureRect = $ColorRect/MarginContainer/HBoxContainer/Panel/TextureRect
@onready var rich_text_label: RichTextLabel = $ColorRect/MarginContainer/HBoxContainer/ColorRect2/MarginContainer/RichTextLabel
@onready var title: RichTextLabel = $ColorRect/MarginContainer/HBoxContainer/Panel/title


var content: String = "This is the test for the information section of the whole thing you know what I mean"

#signal typing_finished 

func _ready() -> void:
	await get_tree().create_timer(2).timeout
	title.visible = false
	for key in storyline.keys():
		var entry = storyline[key] 
		texture_rect.texture = entry["img_src"] 
		await textTypingAnimation(entry["text"]) 
		await get_tree().create_timer(5).timeout
		clearText()
	get_tree().change_scene_to_file("res://Game/select_player.tscn")

func textTypingAnimation(text: String) -> void:
	var output = ""  
	for s in text:
		await get_tree().create_timer(0.01).timeout
		output += s 
		rich_text_label.text = '[color="white"][font_size=35][b]' + output + '[/b][/font_size][/color]' 

func clearText() -> void:
	await get_tree().create_timer(0.5).timeout
	rich_text_label.text = ""
