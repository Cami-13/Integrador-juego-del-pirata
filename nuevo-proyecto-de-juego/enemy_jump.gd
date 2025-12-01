extends CharacterBody2D

@export var gravity: float = 500.0
@export var jump_speed: float = 300.0
@export var jump_interval: float = 2.0 

var jump_timer: float = 0.0

func _ready():
	jump_timer = jump_interval

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	jump_timer -= delta
	if jump_timer <= 0 and is_on_floor():
		velocity.y = -jump_speed
		jump_timer = jump_interval

	move_and_slide()

func _on_area_2d_body_entered(body):
	if body.name == "Player" and body.has_method("lose_life_from_direction"):
		var dir_to_player = (global_position - body.global_position).normalized()
		body.lose_life_from_direction(dir_to_player)
