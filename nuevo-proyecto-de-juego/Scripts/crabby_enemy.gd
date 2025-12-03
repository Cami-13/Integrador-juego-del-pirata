extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var gravity = 3.0
var speed = 100.0
var moving_left = true

func _ready():
	if animated_sprite_2d:
		animated_sprite_2d.play("Run")

func _physics_process(delta):
	apply_gravity()
	move_character()
	turn()

func apply_gravity():
	velocity.y += gravity

func move_character():
	# corrección: uso de expresión condicional de GDScript
	velocity.x = -speed if moving_left else speed
	move_and_slide()

func turn():
	if not $RayCast2D.is_colliding():
		moving_left = !moving_left
		scale.x *= -1

func _on_area_2d_body_entered(body):
	# MUERE POR ATAQUE DEL JUGADOR
	if body.name == "AttackArea" and body.monitoring:
		queue_free()
		return

	# NO DAÑA DESPUÉS DEL COFRE
	if body.is_in_group("Player") and body.chest_touched:
		return

	# DAÑO NORMAL
	if body.is_in_group("Player") and body.has_method("lose_life_from_direction"):
		var dir = (body.global_position - global_position).normalized()
		body.lose_life_from_direction(dir)
