extends CharacterBody2D

@export var shoot_interval := 1.5    
@export var bullet_scene: PackedScene 
@export var bullet_speed := 200

var player_in_range = false
var player_ref = null
var can_shoot = true

@onready var cannon_sprite: AnimatedSprite2D = $Sprite2D
@onready var shoot_point: Node2D = $ShootPoint
var shoot_timer: Timer
var cooldown_timer: Timer

func _ready():
	if cannon_sprite:
		cannon_sprite.play("Cannon Idle")
	# Crear y configurar timers
	shoot_timer = Timer.new()
	shoot_timer.one_shot = true
	shoot_timer.wait_time = 0.2  # Espera antes de disparar (para animación)
	add_child(shoot_timer)
	shoot_timer.connect("timeout", Callable(self, "_on_shoot_timer_timeout"))

	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = shoot_interval  # Intervalo entre disparos
	add_child(cooldown_timer)
	cooldown_timer.connect("timeout", Callable(self, "_on_cooldown_timer_timeout"))

func _on_range_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = true
		player_ref = body

func _on_range_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = false
		player_ref = null
		if cannon_sprite:
			cannon_sprite.play("Cannon Idle")

func _process(delta):
	if player_in_range and player_ref != null:
		# Mantener dirección izquierda por defecto
		if player_ref.global_position.x > global_position.x:
			# Solo voltear si el jugador está a la derecha
			cannon_sprite.flip_h = true
		else:
			# Mantener mirando a la izquierda por defecto
			cannon_sprite.flip_h = false

	if player_in_range and can_shoot:
		can_shoot = false
		if cannon_sprite:
			cannon_sprite.play("Cannon Fire")
		shoot_timer.start()      # Espera antes de disparar
		cooldown_timer.start()   # Inicia cooldown
	elif cannon_sprite and not player_in_range:
		cannon_sprite.play("Cannon Idle")


func _on_shoot_timer_timeout():
	if bullet_scene == null or player_ref == null:
		print("Error: bullet_scene no asignado o player_ref es null")
		return
	var bullet = bullet_scene.instantiate()
	# Añadimos al root de la escena para asegurar visibilidad
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = shoot_point.global_position

	var dir = (player_ref.global_position - global_position).normalized()
	bullet.direction = dir
	bullet.speed = bullet_speed

func _on_cooldown_timer_timeout():
	can_shoot = true
	if cannon_sprite and not player_in_range:
		cannon_sprite.play("Cannon Idle")
