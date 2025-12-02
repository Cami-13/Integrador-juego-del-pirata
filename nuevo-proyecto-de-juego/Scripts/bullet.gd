extends Area2D

@export var speed: float = 70
var direction: Vector2 = Vector2.ZERO

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	if sprite:
		sprite.play("Idle")

func _physics_process(delta):
	if sprite.animation != "Explosion":
		position += direction * speed * delta

func _on_body_entered(body) -> void:
	if body.is_in_group("Player") and body.has_method("lose_life_from_direction"):
		# Inflige daño
		var attack_dir = (body.global_position - global_position).normalized()
		body.lose_life_from_direction(attack_dir)

		# Cambia a animación Explosion
		if sprite:
			sprite.play("Explosion")
		
		# Desactiva colisiones
		monitorable = false
		monitoring = false

		# Espera un tiempo fijo antes de eliminar la bala
		var explosion_duration = 0.5  # Ajusta según duración de tu animación
		var t = Timer.new()
		t.one_shot = true
		t.wait_time = explosion_duration
		add_child(t)
		t.start()
		await t.timeout
		queue_free()
