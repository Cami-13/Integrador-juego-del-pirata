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
var frontal_immune: bool = false

var is_dead: bool = false
var can_move: bool = true

@export var timer_initial_time: float = 35.0
var timer_initial_left: float = timer_initial_time
var timer_initial_active: bool = true
@onready var timer_initial_label: Label = $"../CanvasLayer/TimerInitialLabel"

@export var timer_post_time: float = 20.0
var timer_post_left: float = timer_post_time
var timer_post_active: bool = false
@onready var timer_post_label: Label = $"../CanvasLayer/TimerPostLabel"

@onready var gold_label: Label = $"../CanvasLayer/GoldLabel"
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite

var chest_checkpoint: Vector2
var chest_touched: bool = false

# Knockback state
var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

# Defaults para knockback (modificá si querés)
@export var default_knockback_horizontal: float = 380.0
@export var default_knockback_vertical: float = 260.0
@export var default_knockback_duration: float = 0.25


# --------------------------
# ANIMACIONES
# --------------------------
func update_animations():
	if is_dead:
		return

	if not is_on_floor():
		if velocity.y < 0:
			animated_sprite.play("Jump")
		else:
			animated_sprite.play("Fall")
		return

	if velocity.x != 0:
		animated_sprite.play("Run")
	else:
		animated_sprite.play("Idle")


# --------------------------
# READY
# --------------------------
func _ready() -> void:
	start_position = global_position
	timer_initial_left = timer_initial_time
	timer_initial_active = true
	call_deferred("update_timer_initial_label")
	timer_post_label.visible = false  
	update_gold_label()


# --------------------------
# PHYSICS
# --------------------------
func _physics_process(delta: float) -> void:
	# Si estamos en knockback, aplicamos ese vector y contamos tiempo
	if knockback_timer > 0.0:
		# knockback mantiene su valor durante knockback_timer
		velocity.x = knockback.x
		velocity.y = knockback.y
		knockback_timer -= delta
		if knockback_timer <= 0.0:
			# fin del knockback: limpiamos y permitimos movimiento
			knockback = Vector2.ZERO
			can_move = true
	else:
		# flujo normal de movimiento
		_movement(delta)

	# aplicar gravedad si corresponde (si no se está aplicando ya en _movement)
	if not is_on_floor():
		# si el knockback ya puso velocity.y, sumamos gravedad normalmente
		velocity.y += gravity * delta

	# finalmente mover el cuerpo
	move_and_slide()

	# si está muerto no procesamos inputs ni timers
	if is_dead:
		return

	update_animations()

	# TIMERS
	if timer_initial_active:
		timer_initial_left -= delta
		if timer_initial_left <= 0:
			_on_timer_initial_timeout()
		update_timer_initial_label()

	if timer_post_active:
		timer_post_left -= delta
		if timer_post_left <= 0:
			_on_timer_post_timeout()
		update_timer_post_label()


# --------------------------
# MOVIMIENTO (input + salto)
# --------------------------
func _movement(delta: float) -> void:
	# salto
	if Input.is_action_just_pressed("jump") and is_on_floor() and can_move:
		velocity.y = -jump_speed

	# movimiento horizontal (solo si can_move)
	if can_move:
		move_x()

	# flip aparte para reflejar sprite
	flip()


func move_x() -> void:
	# si no puede moverse, no sobreescribimos velocity.x
	if not can_move:
		return

	var input_axis = Input.get_axis("move_left", "move_right")
	velocity.x = input_axis * move_speed


func flip() -> void:
	if (is_facing_right and velocity.x < 0) or (not is_facing_right and velocity.x > 0):
		scale.x = -scale.x
		is_facing_right = !is_facing_right


# --------------------------
# KNOCKBACK (EMPUJÓN REAL) - firma flexible
# direction: vector que apunta AWAY del enemigo (es decir, debe ser (player - enemy).normalized())
# horizontal_force, vertical_force: magnitudes
# duration: tiempo que dura el knockback (segundos)
# --------------------------
func apply_knockback(direction: Vector2, horizontal_force: float = default_knockback_horizontal, vertical_force: float = default_knockback_vertical, duration: float = default_knockback_duration) -> void:
	if direction == Vector2.ZERO:
		return

	# bloquear movimiento de entrada
	can_move = false

	var dir_norm = direction.normalized()
	# knockback horizontal según la dirección x del vector
	var kb_x = dir_norm.x * horizontal_force
	# vertical será hacia arriba (negativo)
	var kb_y = -abs(vertical_force)

	knockback = Vector2(kb_x, kb_y)
	knockback_timer = duration


# --------------------------
# MUERTE
# --------------------------
func play_dead_hit():
	can_move = false
	is_dead = true
	velocity = Vector2.ZERO
	animated_sprite.play("Dead Hit")
	await animated_sprite.animation_finished
	respawn_player()

func play_dead_ground():
	can_move = false
	is_dead = true
	velocity = Vector2.ZERO
	animated_sprite.play("Dead Ground")
	await animated_sprite.animation_finished
	respawn_player()


# --------------------------
# RESPAWN
# --------------------------
func respawn_player():
	if chest_checkpoint != Vector2.ZERO:
		global_position = chest_checkpoint
	else:
		global_position = start_position

	is_dead = false
	can_move = true


# --------------------------
# PERDER VIDA
# --------------------------
func lose_life(damage_from_position = null) -> void:
	if is_dead:
		return

	if frontal_immune and damage_from_position != null:
		var dir_to_damage = (damage_from_position - global_position).normalized()
		if (is_facing_right and dir_to_damage.x > 0) or (not is_facing_right and dir_to_damage.x < 0):
			return

	life -= 1

	if damage_from_position != null:
		# calculamos dirección desde ENEMIGO hacia PLAYER
		var dir = (global_position - damage_from_position).normalized()
		# Nota: si tus enemigos llaman body.lose_life(global_position),
		# entonces damage_from_position = enemy.global_position y dir será (player - enemy) NEGADO,
		# por eso preferimos que el enemigo envíe: (player.global_position - enemy.global_position).normalized()
		# Para robustez, aquí invertimos si queda en cero o mal orientado:
		# Usamos dirección que apunta AWAY del enemigo:
		dir = (global_position - damage_from_position).normalized()
		# Aplicar knockback con valores por defecto
		apply_knockback(dir)

	if life <= 0:
		play_dead_ground()
	else:
		play_dead_hit()


func lose_life_from_direction(dir_to_damage: Vector2):
	if is_dead:
		return

	if frontal_immune:
		if (is_facing_right and dir_to_damage.x > 0) or (not is_facing_right and dir_to_damage.x < 0):
			return

	life -= 1

	# Aquí asumimos que dir_to_damage es la dirección CORRECTA del ENEMIGO->PLAYER
	# (por ejemplo: enemy envía (player.global_position - enemy.global_position).normalized())
	apply_knockback(dir_to_damage)

	if life <= 0:
		play_dead_ground()
	else:
		play_dead_hit()


# --------------------------
# ORO / ESPADA
# --------------------------
func add_gold(amount: int):
	gold += amount
	update_gold_label()

func add_sword(sword_name: String):
	inventory_sword = sword_name
	frontal_immune = true

func update_gold_label():
	if gold_label:
		gold_label.text = "Oro: " + str(gold)


# --------------------------
# CHECKPOINT / COFRE
# --------------------------
func set_checkpoint(new_position: Vector2) -> void:
	chest_checkpoint = new_position

func on_chest_opened():
	chest_touched = true
	timer_initial_active = false
	timer_initial_label.visible = false


# --------------------------
# TIMERS
# --------------------------
func update_timer_initial_label():
	if not timer_initial_active:
		timer_initial_label.visible = false
		return

	timer_initial_label.visible = true
	timer_initial_label.text = "Tiempo: " + str(ceil(timer_initial_left)) + "s"

func _on_timer_initial_timeout():
	if not timer_initial_active:
		return

	if chest_checkpoint != Vector2.ZERO:
		global_position = chest_checkpoint
	else:
		global_position = start_position

	velocity = Vector2.ZERO
	timer_initial_left = timer_initial_time
	update_timer_initial_label()

func start_post_chest_timer():
	timer_post_left = timer_post_time
	timer_post_active = true
	timer_post_label.visible = true

func update_timer_post_label():
	timer_post_label.text = "Bonus: " + str(ceil(timer_post_left)) + "s"

func _on_timer_post_timeout() -> void:
	# respawnea en checkpoint cuando se acabe el post-timer
	if chest_checkpoint != Vector2.ZERO:
		global_position = chest_checkpoint
	velocity = Vector2.ZERO
	timer_post_left = timer_post_time
	update_timer_post_label()
	timer_post_active = true
