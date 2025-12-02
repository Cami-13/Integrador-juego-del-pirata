extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var gravity: float = 500.0
@export var jump_speed: float = 300.0
@export var jump_interval: float = 2.0

var jump_timer: float = 0.0

func _ready():
	jump_timer = jump_interval
	if animated_sprite_2d:
		animated_sprite_2d.play("Idle")  

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	jump_timer -= delta
	if jump_timer <= 0 and is_on_floor():
		velocity.y = -jump_speed
		jump_timer = jump_interval

	move_and_slide()


	if animated_sprite_2d:
		if is_on_floor():
			animated_sprite_2d.play("Idle")
		else:
			animated_sprite_2d.play("Jump")

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player") and body.has_method("lose_life_from_direction"):
		var dir = (body.global_position - global_position).normalized()
		body.lose_life_from_direction(dir)
