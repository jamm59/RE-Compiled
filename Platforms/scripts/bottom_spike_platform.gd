extends Node2D
class_name SpikeArea

@onready var Spikes: Array[Sprite2D] = [$"SpikeParent/Spike-1", $"SpikeParent/Spike-2", $"SpikeParent/Spike-3", $"SpikeParent/Spike-4", $"SpikeParent/Spike-5", $"SpikeParent/Spike-6"]


func animateSpikeAttack(spike: Sprite2D) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(spike, "position", Vector2(spike.position.x, spike.position.y - 50), 0.1)
		

func _on_spike_area_body_entered(body: Node2D) -> void:
	if body is Player:
		var closestSpike: Sprite2D = null
		var shortestDistance: float = INF
		for spike: Sprite2D in Spikes:
			var distance: float = body.global_position.distance_to(spike.global_position)
			if shortestDistance > distance:
				shortestDistance = distance
				closestSpike = spike
		animateSpikeAttack(closestSpike)
		
