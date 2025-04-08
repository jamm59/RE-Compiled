extends CanvasLayer
class_name EducationModal 

@onready var title_rich_text_label: RichTextLabel = $Panel/MarginContainer/VBoxContainer/TitleRichTextLabel
@onready var displayText: RichTextLabel = $Panel/MarginContainer/VBoxContainer/RichTextLabel
@onready var markdownText: MarkdownLabel = $Panel/MarginContainer/MarkdownLabel
@onready var http_request: HTTPRequest = $HTTPRequest
	
enum EducationTopics {OOP, Binary, LogicGates, Networking}

var typingFinished: bool = false

func _ready() -> void:
	_on_get_information_about_topic(Variables.current_topic)
	SignalManager.connect("more_information_on_topic", _on_get_information_about_topic)
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("MoreInfo"):
		visible = not visible
		get_tree().paused = visible
		
		
func textTypingAnimation(text: String) -> void:
	displayText.text = "[font_size=20]" 
	for s: String in text:
		await get_tree().create_timer(0.001).timeout
		displayText.text += s
	displayText.text += "[/font_size]"
	typingFinished = true
		
func clear() -> void:
	await get_tree().create_timer(0.5).timeout
	displayText.text = ""

func _on_get_information_about_topic(topic: String) -> void:
	var topic_data: Dictionary = Variables.get_text_about_topic(topic)
	if topic_data["text"].length() > 0:
		title_rich_text_label.text = topic_data["title"]
		textTypingAnimation(topic_data["text"])
		return 

	var prompt := "[b]Simulation AI Assistant:[/b]\n\n"
	prompt += "You are an advanced AI inside the digital simulation of 'Re:Compiled,' an educational 2D platformer game. "
	prompt += "Your purpose is to guide the player through complex programming concepts by relating them to in-game elements. "
	prompt += "For instance, enemies, platforms, and NPCs are all objects, demonstrating Object-Oriented Programming principles.\n\n"
	prompt += "[b]Explain '" + topic + "'[/b] in a way that fits within the simulation's world. "
	prompt += "Use in-game analogies and avoid generic explanations. Your response should be engaging, informative, and free from unnecessary introductions or filler words."

	# Request information from the AI
	getTopicInformationRequest(prompt)



func getTopicInformationRequest(prompt: String) -> void:
	var godot_key: String = "44ac8821-5a3b-41ce-a3b0-e8fdf6e901b4"
	# Perform a GET request. The URL below returns JSON as of writing.
	# Set up request parameters
	var url = "https://api.arliai.com/v1/completions"
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + godot_key
	]
	var payload = {
		"model": "Mistral-Nemo-12B-Instruct-2407",
		"prompt": "<|begin_of_text|><|start_header_id|>system<|end_header_id|>\n\n" + prompt +  "<|eot_id|><|start_header_id|>assistant<|end_header_id|>\n\n",
		"repetition_penalty": 1.1,
		"temperature": 0.7,
		"top_p": 0.9,
		"top_k": 40,
		"max_tokens": 1024,
		"stream": false
	}
	
	# Convert payload to JSON string and send the request
	var json_payload = JSON.stringify(payload)
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_payload)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	visible = true
	if response_code == 200:
		var response_text: String = body.get_string_from_utf8()
		var response_json = JSON.parse_string(response_text)
		var results: String = response_json["choices"][0]["text"]
		markdownText.markdown_text = results
		var outputBBCode: String = markdownText.text
		for char: String in outputBBCode:
			await get_tree().create_timer(0.001).timeout
			displayText.text += char
	else:
		print("Error loading or Offline")
