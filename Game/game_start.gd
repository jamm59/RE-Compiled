extends Control


@onready var sub_viewport_1: SubViewport = $CanvasLayer/HBoxContainer/SubViewportContainer/SubViewport
@onready var sub_viewport_2: SubViewport = $CanvasLayer/HBoxContainer/SubViewportContainer2/SubViewport

var displayMoreInformation: bool = false

func percentageOf(value: float, targetPercent: float) -> float:
	return (targetPercent / 100) * value

func handleRezieSubviewPorts(toggleMode=false) -> bool:
	var screenSize = Vector2(0,0)
	screenSize.x = get_viewport_rect().size.x # Get Width
	screenSize.y = get_viewport_rect().size.y # Get Height
	if not toggleMode:
		sub_viewport_1.size = Vector2(percentageOf(screenSize.x, 70), screenSize.y)
		sub_viewport_2.size = Vector2(percentageOf(screenSize.x, 30), screenSize.y)
	else:
		sub_viewport_1.size = Vector2(percentageOf(screenSize.x, 100), screenSize.y)
		sub_viewport_2.size = Vector2(percentageOf(screenSize.x, 0), screenSize.y)
	return toggleMode
	
func _ready() -> void:
	handleRezieSubviewPorts()
	connect("resized", _handle_screen_resize)

func _handle_screen_resize():
	handleRezieSubviewPorts()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("MoreInfo"):
		displayMoreInformation = handleRezieSubviewPorts(not displayMoreInformation)
