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

	# ✔ CAMBIAR EL CHECKPOINT AL COFRE
	player.set_checkpoint(global_position + Vector2(0, -16))

	# ✔ AVISA AL PLAYER QUE EL COFRE YA ES EL NUEVO SPAWN
	player.chest_touched = true

	# -----------------------------------------
	# ✔ DESACTIVAR TIMER INICIAL *PARA SIEMPRE*
	# -----------------------------------------
	player.timer_initial_active = false
	if player.timer_initial_label:
		player.timer_initial_label.visible = false
	player.timer_initial_left = player.timer_initial_time  # opcional: limpiar valor
	# El timer inicial ya no vuelve más

	# ✔ ACTIVAR TIMER BONUS DESDE EL COFRE
	player.start_post_chest_timer()
