extends Area2D

@export var gold_amount: int = 10
@export var sword_name: String = "Espada"

var is_open: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	if sprite:
		sprite.play("Idle Close")

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

	# ------- ANIMACIÓN DE APERTURA --------
	if sprite and sprite.sprite_frames:
		sprite.play("Open")

		var frames_count = sprite.sprite_frames.get_frame_count("Open")
		var anim_speed = sprite.sprite_frames.get_animation_speed("Open")

		var anim_length := 0.1
		if anim_speed > 0:
			anim_length = float(frames_count) / float(anim_speed)

		await get_tree().create_timer(anim_length).timeout
		sprite.play("Idle Open")

	# ------- ACTIVAR ESPADA -------	
	player.add_sword(sword_name)

	# ------- SUBIR VELOCIDAD -------
	player.move_speed += 50
	print("Velocidad aumentada! Nueva velocidad:", player.move_speed)

	# ------- ORO / CHECKPOINT / TIMERS -------
	player.add_gold(gold_amount)

	player.set_checkpoint(global_position + Vector2(0, -16))
	player.chest_touched = true
	player.timer_initial_active = false

	if player.timer_initial_label:
		player.timer_initial_label.visible = false

	player.timer_initial_left = player.timer_initial_time
	player.start_post_chest_timer()

	# Ocultar llave del HUD
	if player.has_key and player.has_node("../CanvasLayer/KeyIcon"):
		var key_icon = player.get_node("../CanvasLayer/KeyIcon")
		key_icon.visible = false
		player.has_key = false
