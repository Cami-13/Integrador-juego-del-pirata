extends CharacterBody2D

var gravity = 3.0
var speed =100.0
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
	if body.name == "Player" and body.has_method("lose_life"):
		body.lose_life()
