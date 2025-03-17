extends DeerNPC


func _ready() -> void:
	super()
	animal = $Elk
	
func _physics_process(delta: float) -> void:
	super(delta)
