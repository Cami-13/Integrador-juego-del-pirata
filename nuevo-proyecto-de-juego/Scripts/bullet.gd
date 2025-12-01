extends Area2D

@export var speed: float = 300
var direction: Vector2 = Vector2.ZERO

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.name == "Player" and body.has_method("lose_life_from_direction"):
		var attack_dir = (global_position - body.global_position).normalized()
		body.lose_life_from_direction(attack_dir)
		queue_free()
