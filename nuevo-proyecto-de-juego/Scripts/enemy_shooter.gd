extends CharacterBody2D

@export var shoot_interval: float = 1.5
@export var bullet_scene: PackedScene
@export var bullet_speed: float = 300

var player_in_range: bool = false
var player_ref = null
var can_shoot: bool = true

@onready var cannon_sprite: AnimatedSprite2D = $Sprite2D
@onready var shoot_point: Node2D = $ShootPoint

var shoot_timer: Timer
var cooldown_timer: Timer

func _ready():
	cannon_sprite.play("Cannon Idle")

	# Timer de disparo
	shoot_timer = Timer.new()
	shoot_timer.one_shot = true
	shoot_timer.wait_time = 0.2
	add_child(shoot_timer)
	shoot_timer.connect("timeout", Callable(self, "_on_shoot_timer_timeout"))

	# Timer de cooldown
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = shoot_interval
	add_child(cooldown_timer)
	cooldown_timer.connect("timeout", Callable(self, "_on_cooldown_timer_timeout"))

func _on_range_area_body_entered(body):
	if body.name == "Player":
		player_in_range = true
		player_ref = body

func _on_range_area_body_exited(body):
	if body.name == "Player":
		player_in_range = false
		player_ref = null
		cannon_sprite.play("Cannon Idle")

func _process(delta):
	if player_in_range and player_ref:
		cannon_sprite.flip_h = player_ref.global_position.x > global_position.x

	if player_in_range and can_shoot:
		can_shoot = false
		cannon_sprite.play("Cannon Fire")
		shoot_timer.start()
		cooldown_timer.start()
	elif not player_in_range:
		cannon_sprite.play("Cannon Idle")

func _on_shoot_timer_timeout():
	if bullet_scene == null or player_ref == null:
		return

	# Instanciar el bullet
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = shoot_point.global_position
	bullet.direction = (player_ref.global_position - shoot_point.global_position).normalized()
	bullet.speed = bullet_speed

	# Asegurarse que la animación del bullet se inicia
	if bullet.has_node("AnimatedSprite2D"):
		bullet.get_node("AnimatedSprite2D").play("Idle")

func _on_cooldown_timer_timeout():
	can_shoot = true
	if not player_in_range:
		cannon_sprite.play("Cannon Idle")
