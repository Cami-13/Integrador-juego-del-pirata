extends Area2D

@export var gold_amount: int = 10
@export var sword_name: String = "Espada"

var is_open: bool = false


func _on_body_entered(body):
	if is_open:
		return

	if body.name == "Player":
		if body.has_key:
			open_chest(body)
		else:
			print("Necesitas una llave para abrir este cofre.")
			

func open_chest(player):
	is_open = true

	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("open")

	print("¡Cofre abierto!")

	player.add_gold(gold_amount)
	player.add_sword(sword_name)
