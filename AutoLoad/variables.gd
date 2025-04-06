extends Node

var current_topic: String = "oop"

func _launch(ref: CharacterBody2D, strength: float, direction: Vector2) -> void:
	ref.velocity.x += direction.x  * strength
	
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
func get_text_about_topic(topic: String) -> Dictionary:
	var data: Dictionary = Variables.load_json("res://Assets/Json_data/education_data.json")
	if topic in data and "text" in data[topic]:
		var content: Dictionary = data[topic]
		return content
	
	# Return an empty dictionary if no questions are found
	return {}

func get_random_question_from_topic(topic: String) -> Dictionary:
	var data := load_json("res://Assets/Json_data/education_data.json")
	# Ensure the topic exists and has questions
	if topic in data and "questions" in data[topic]:
		var questions = data[topic]["questions"]
		
		if questions.size() > 0:
			return questions[randi() % questions.size()]  # Pick a random question
	# Return an empty dictionary if no questions are found
	return {}
	
func shoot_bullets(fromBody: Node2D, toBody: Node2D, bullets: Node2D, bullet_start_location: Marker2D, from_companion: bool = false) -> void:
	const BULLET = preload("res://Characters/Enemy/scene/bullet.tscn")
	var Angle = atan2(toBody.global_position.y - fromBody.global_position.y, toBody.global_position.x - fromBody.global_position.x)
	var bullet: Bullet = BULLET.instantiate()
	if not from_companion:
		bullets.add_child(bullet)
	else:
		bullets.call_deferred("add_child", bullet)
	bullet.from_companion = from_companion
	bullet.shoot(bullet_start_location.global_position, Angle)
