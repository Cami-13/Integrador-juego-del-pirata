extends CharacterBody2D

@export var move_speed: float = 200.0
@export var jump_speed: float = 400.0

var is_facing_right = true
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var start_position: Vector2
var life: int = 1  

var has_key: bool = false
var gold: int = 0
var inventory_sword: String = ""

# Inmunidad frontal activada al obtener la espada
var frontal_immune: bool = false

func _ready() -> void:
	start_position = global_position

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

# Para enemigos de contacto que envían posición
func lose_life(damage_from_position = null) -> void:
	if frontal_immune and damage_from_position != null:
		var dir_to_damage = (damage_from_position - global_position).normalized()
		if (is_facing_right and dir_to_damage.x > 0) or (not is_facing_right and dir_to_damage.x < 0):
			print("¡Ataque bloqueado por la espada!")
			return

	life -= 1
	global_position = start_position
	velocity = Vector2.ZERO
	life = 1  

# Para balas y ataques dirigidos, usando dirección
func lose_life_from_direction(dir_to_damage: Vector2) -> void:
	if frontal_immune:
		if (is_facing_right and dir_to_damage.x > 0) or (not is_facing_right and dir_to_damage.x < 0):
			print("¡Ataque bloqueado por la espada!")
			return

	life -= 1
	global_position = start_position
	velocity = Vector2.ZERO
	life = 1  

func add_gold(amount: int):
	gold += amount
	print("Oro total:", gold)
	if get_tree().get_root().has_node("Nivel1"):
		get_tree().get_root().get_node("Nivel1").update_gold(gold)

func add_sword(sword_name: String):
	inventory_sword = sword_name
	print("Has obtenido la espada:", sword_name)
	frontal_immune = true
