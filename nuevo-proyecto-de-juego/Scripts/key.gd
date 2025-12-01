extends Area2D

func _on_body_entered(body):
	if body.name == "Player":
		body.has_key = true
		print("¡Has obtenido una llave!")
		queue_free()
