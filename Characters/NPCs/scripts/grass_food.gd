class_name GrassFood 
extends StaticBody2D

@onready var food: Array[Sprite2D] = [$Sprite2D, $Sprite2D2, $Sprite2D3]

var foodHealth: float = 10

func _ready() -> void:
	var randFood: Sprite2D = food.pick_random()
	for i:Sprite2D in food:
		if i.name == randFood.name:
			randFood.visible = true
			continue
		i.visible = false
