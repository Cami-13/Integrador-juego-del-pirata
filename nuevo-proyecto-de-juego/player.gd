extends CharacterBody2D

@export var move_speed: float = 200.0
@export var jump_speed: float = 300.0
var is_facing_right = true
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_speed

	move_x()
	flip()
	move_and_slide()

func move_x() -> void:
	var input_axis = Input.get_axis("move_left", "move_right")
	velocity.x = input_axis * move_speed

func flip() -> void:
	if (is_facing_right and velocity.x < 0) or (not is_facing_right and velocity.x > 0):
		scale.x = -scale.x
		is_facing_right = not is_facing_right
