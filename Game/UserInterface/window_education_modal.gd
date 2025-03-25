extends Window
class_name EducationWindowModal



@onready var educationText: MarkdownLabel = $CanvasLayer/Panel/MarginContainer/MarkdownLabel
@onready var http_request: HTTPRequest = $HTTPRequest

var titleText: String = "[font_size=30][center][b]More Information[/b][/center][/font_size]\n\n"
var text: String = ""
	
enum EducationTopics {OOP, Binary, LogicGates, Networking}

var typingFinished: bool = false

func _ready() -> void:
	educationText.text = titleText
	#textTypingAnimation(text)
	#makeRequest()

func textTypingAnimation(text: String) -> void:
	for s: String in text:
		await get_tree().create_timer(0.001).timeout
		educationText.text += s
	typingFinished = true
		
func clear() -> void:
	await get_tree().create_timer(0.5).timeout
	educationText.text = ""
	
	
func showEducationInformation(topic: EducationTopics) -> void:
	#visible = true
	match topic:
		EducationTopics.OOP: 
			textTypingAnimation(text)
		EducationTopics.Binary: 
			textTypingAnimation(text)
		EducationTopics.LogicGates: 
			textTypingAnimation(text)
		EducationTopics.Networking:
			textTypingAnimation(text)
			
			
func makeRequest() -> void:
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
		"prompt": "<|begin_of_text|><|start_header_id|>system<|end_header_id|>\n\nYou are an assistant AI.<|eot_id|><|start_header_id|>user<|end_header_id|>\n\nExplain Object-Oriented Programming at a basic level, starting from blueprints and classes. Keep it concise. Cover the four main components. Make sure to output as godot richtextlabel bbcode mode<|eot_id|><|start_header_id|>assistant<|end_header_id|>\n\n",
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
	print(response_code)
	if response_code == 200:
		var response_text: String = body.get_string_from_utf8()
		var response_json = JSON.parse_string(response_text)
		var output: String = response_json["choices"][0]["text"]
		for char: String in output:
			await get_tree().create_timer(0.001).timeout
			educationText.markdown_text += char
	else:
		print("Error loading or Offline")
