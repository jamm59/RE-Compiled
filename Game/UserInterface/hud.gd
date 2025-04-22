extends CanvasLayer
class_name PlayerHUD

@onready var health: ProgressBar = $TopPanel/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Health
@onready var stamina: ProgressBar = $TopPanel/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer2/Stamina
@onready var coins: Label = $TopPanel/MarginContainer/HBoxContainer/VBoxContainer2/HBoxContainer/Coins
@onready var status: Label = $TopPanel/MarginContainer/HBoxContainer/VBoxContainer2/RangeLimit/status
