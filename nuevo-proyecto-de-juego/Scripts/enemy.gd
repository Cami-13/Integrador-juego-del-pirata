extends CharacterBody2D

@onready var player_node: CharacterBody2D = get_parent(). get_node("player")


var gravity = 3.0
var speed = 100.0
var moving_left = true

func _physics_process(delta):
	apply_gravity()
	move_character()
	turn()

func apply_gravity():
	velocity.y += gravity

func move_character():
	if moving_left:
		velocity.x = -speed
	else:
		velocity.x = speed

	move_and_slide()

func turn():
	if not $RayCast2D.is_colliding():
		moving_left = !moving_left
		scale.x *= -1

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player") and body.has_method("lose_life"):
		var dir = (body.global_position - global_position).normalized()
		body.lose_life_from_direction(dir)
	if body == player_node:
		var dir = (body.global_position - global_position).normalized()
		body.lose_life_from_direction(dir)
