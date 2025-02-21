extends Control
@export var tutorial_is_active: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	if not tutorial_is_active:
		return
	visible = true

#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#if tutorial_is_active:
		#custom_minimum_size = get_viewport().size
	
