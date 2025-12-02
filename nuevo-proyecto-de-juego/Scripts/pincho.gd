extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("lose_life_from_direction"):
		var dir = (body.global_position - global_position).normalized()
		body.lose_life_from_direction(dir)
