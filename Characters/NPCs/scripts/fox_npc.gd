class_name FoxNPC extends NPCBase


func _ready() -> void:
	super()
	animal = $Fox

func _physics_process(delta: float) -> void:
	super(delta)
