extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	if animated_sprite_2d:
		animated_sprite_2d.play("Idle")  

func _on_body_entered(body):
	if body.name == "Player":
		# El jugador ahora tiene la llave
		body.has_key = true
		print("¡Has obtenido una llave!")
		
		# Mostrar la llave en el HUD
		if body.has_node("../CanvasLayer/KeyIcon"):
			var key_icon = body.get_node("../CanvasLayer/KeyIcon")
			key_icon.visible = true

		queue_free()  # La llave desaparece del mundo
