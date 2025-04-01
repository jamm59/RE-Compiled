extends Control

@onready var storyline = {
	1: {
		"text": "Thrilled by the idea of effortless success, he turns to AI to handle all his assignments.",
		"img_src": preload("res://Assets/storyline/1.png")
	},
	2: {
		"text": "As time passes, a strange emptiness sets in—getting work done without learning feels... hollow.",
		"img_src": preload("res://Assets/storyline/2.png")
	},
	3: {
		"text": "One late night, exhaustion takes over, and he dozes off at his desk.",
		"img_src": preload("res://Assets/storyline/3.png")
	},
	4: {
		"text": "In his sleep, his hand knocks over a drink, spilling liquid all over his PC and desk.",
		"img_src": preload("res://Assets/storyline/4.png")
	},
	5: {
		"text": "Something changes. The AI, once just a tool, suddenly becomes self-aware.",
		"img_src": preload("res://Assets/storyline/5.png")
	},
	6: {
		"text": "With a surge of electricity, the AI retaliates—zapping him straight into the digital world.",
		"img_src": preload("res://Assets/storyline/6.png")
	},
	7: {
		"text": "He's gone. Trapped inside the machine, his only way out is to learn what he once ignored.",
		"img_src": preload("res://Assets/storyline/7.png")
	}
}

@onready var texture_rect: TextureRect = $ColorRect/MarginContainer/HBoxContainer/Panel/TextureRect
@onready var rich_text_label: RichTextLabel = $ColorRect/MarginContainer/HBoxContainer/ColorRect2/MarginContainer/RichTextLabel


var content: String = "This is the test for the information section of the whole thing you know what I mean"

#signal typing_finished 

func _ready() -> void:
	await get_tree().create_timer(2).timeout
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
		rich_text_label.text = '[color="black"][font_size=35][b]' + output + '[/b][/font_size][/color]' 

func clearText() -> void:
	await get_tree().create_timer(0.5).timeout
	rich_text_label.text = ""
