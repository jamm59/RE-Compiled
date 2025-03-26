extends CanvasLayer
class_name EducationModal 


@onready var displayText: RichTextLabel = $Panel/MarginContainer/RichTextLabel
@onready var markdownText: MarkdownLabel = $Panel/MarginContainer/MarkdownLabel
@onready var http_request: HTTPRequest = $HTTPRequest

var titleText: String = "[font_size=25][center][b]More Information[/b][/center][/font_size]\t\t [font_size=30][center][b]Object Oriented Programming[/b][/center][/font_size]\n\n"
var text: String = "**Hello **"
	
enum EducationTopics {OOP, Binary, LogicGates, Networking}

var typingFinished: bool = false

func _ready() -> void:
	displayText.text = titleText
	SignalManager.connect("more_information_on_topic", _on_get_information_about_topic)
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("MoreInfo"):
		visible = not visible
		get_tree().paused = visible
		
func textTypingAnimation(text: String) -> void:
	for s: String in text:
		await get_tree().create_timer(0.001).timeout
		displayText.text += s
	typingFinished = true
		
func clear() -> void:
	await get_tree().create_timer(0.5).timeout
	displayText.text = ""
	

func load_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		print("Error: Unable to open file at %s" % path)
		return {}
	
	var content = file.get_as_text()
	var parsed_json = JSON.parse_string(content)
	
	if parsed_json == null:
		print("Error: Failed to parse JSON.")
		return {}

	return parsed_json

# Function to retrieve topic information from storage
func get_topic_information_from_storage(topic: String) -> String:
	var data := load_json("res://Assets/Json_data/education_data.json")
	if topic in data:
		return data[topic]
	else:
		return ""

func _on_get_information_about_topic(topic: String) -> void:
	var topicInformation: String = get_topic_information_from_storage(topic)
	if topicInformation:
		textTypingAnimation(topicInformation)
		return 
		
	var prompt: String = "You are an assistant AI inside a digital simulation designed to teach programming concepts interactively. \
						 Your responses will be used in an educational 2D platformer game called 'Re:Compiled.' The game’s world is a computer system, \
						 and the player learns by interacting with elements in the environment. \n\nExplain " + topic + " in a clear and concise manner, \
						using in-game elements as examples where appropriate. Avoid unnecessary introductions or filler words. Structure your response as if \
						guiding the player through the simulation, keeping explanations engaging and relevant to the world they are exploring."
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
