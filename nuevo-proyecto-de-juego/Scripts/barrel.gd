extends Node2D

@onready var sprite: AnimatedSprite2D = $Area2D/AnimatedSprite2D
@onready var solid_collision: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var hit_area: Area2D = $Area2D

@export var max_hits: int = 3
var current_hits: int = 0
var is_broken: bool = false


func _ready():
	sprite.play("Idle")

	# Señal del Área que detecta el golpe del jugador
	var c = Callable(self, "_on_hit_area_body_entered")
	if not hit_area.is_connected("body_entered", c):
		hit_area.body_entered.connect(c)


func _on_hit_area_body_entered(body):
	if is_broken:
		return
	
	# El jugador debe estar atacando
	if body.name == "Player" and body.is_attacking:
		hit()


func hit():
	if is_broken:
		return

	current_hits += 1

	if current_hits < max_hits:
		sprite.play("Hit")
	else:
		break_barrel()


func break_barrel():
	is_broken = true
	
	# Hacer el barril atravesable
	solid_collision.disabled = true

	sprite.play("Break")

	# Esperar fin de animación Break
	var c = Callable(self, "_on_anim_finished")
	if not sprite.is_connected("animation_finished", c):
		sprite.animation_finished.connect(c)


func _on_anim_finished():
	if sprite.animation == "Break":
		queue_free()
