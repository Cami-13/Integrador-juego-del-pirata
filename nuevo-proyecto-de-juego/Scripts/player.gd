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

# --- Timer inicial (20s) ---
@export var timer_initial_time: float = 25.0
var timer_initial_left: float = timer_initial_time
var timer_initial_active: bool = true
@onready var timer_initial_label: Label = $"../CanvasLayer/TimerInitialLabel"

# --- Timer post-cofre (10s) ---
@export var timer_post_time: float = 15.0
var timer_post_left: float = timer_post_time
var timer_post_active: bool = false
@onready var timer_post_label: Label = $"../CanvasLayer/TimerPostLabel"

# --- Gold Label ---
@onready var gold_label: Label = $"../CanvasLayer/GoldLabel"

# --- Checkpoint del cofre ---
var chest_checkpoint: Vector2
var chest_touched: bool = false  # indica si el jugador tocó el cofre

func _ready() -> void:
	start_position = global_position
	timer_initial_left = timer_initial_time
	timer_initial_active = true
	call_deferred("update_timer_initial_label")
	timer_post_label.visible = false  # empieza oculto
	update_gold_label()  # actualizar oro al inicio

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_speed

	move_x()
	flip()
	move_and_slide()

	# Timer inicial solo si está activo
	if timer_initial_active:
		timer_initial_left -= delta
		if timer_initial_left <= 0:
			_on_timer_initial_timeout()
		update_timer_initial_label()

	# Timer post-cofre
	if timer_post_active:
		timer_post_left -= delta
		if timer_post_left <= 0:
			_on_timer_post_timeout()
		update_timer_post_label()

func move_x() -> void:
	var input_axis = Input.get_axis("move_left", "move_right")
	velocity.x = input_axis * move_speed

func flip() -> void:
	if (is_facing_right and velocity.x < 0) or (not is_facing_right and velocity.x > 0):
		scale.x = -scale.x
		is_facing_right = not is_facing_right

# --- Funciones de vida ---
func lose_life(damage_from_position = null) -> void:
	if frontal_immune and damage_from_position != null:
		var dir_to_damage = (damage_from_position - global_position).normalized()
		if (is_facing_right and dir_to_damage.x > 0) or (not is_facing_right and dir_to_damage.x < 0):
			print("¡Ataque bloqueado por la espada!")
			return

	life -= 1
	velocity = Vector2.ZERO

	# Teletransportar según checkpoint
	if chest_checkpoint != Vector2.ZERO:
		global_position = chest_checkpoint
	else:
		global_position = start_position

	# --- Reiniciar Timer Inicial o Post Timer ---
	if chest_touched:
		# Si tocó el cofre, reinicia Post Timer
		timer_post_left = timer_post_time
		timer_post_active = true
		timer_post_label.visible = true
		update_timer_post_label()
	elif timer_initial_active:
		timer_initial_left = timer_initial_time
		update_timer_initial_label()

func lose_life_from_direction(dir_to_damage: Vector2) -> void:
	if frontal_immune:
		if (is_facing_right and dir_to_damage.x > 0) or (not is_facing_right and dir_to_damage.x < 0):
			print("¡Ataque bloqueado por la espada!")
			return

	life -= 1
	velocity = Vector2.ZERO

	# Teletransportar según checkpoint
	if chest_checkpoint != Vector2.ZERO:
		global_position = chest_checkpoint
	else:
		global_position = start_position

	# --- Reiniciar Timer Inicial o Post Timer ---
	if chest_touched:
		# Si tocó el cofre, reinicia Post Timer
		timer_post_left = timer_post_time
		timer_post_active = true
		timer_post_label.visible = true
		update_timer_post_label()
	elif timer_initial_active:
		timer_initial_left = timer_initial_time
		update_timer_initial_label()

# --- Cofre y oro ---
func add_gold(amount: int):
	gold += amount
	print("Oro total:", gold)
	update_gold_label()

func add_sword(sword_name: String):
	inventory_sword = sword_name
	print("Has obtenido la espada:", sword_name)
	frontal_immune = true

func update_gold_label():
	if gold_label:
		gold_label.text = "Oro: " + str(gold)


# --- Checkpoint ---
func set_checkpoint(new_position: Vector2) -> void:
	chest_checkpoint = new_position
	print("Checkpoint del cofre activado en ", chest_checkpoint)

# --- Timer inicial ---
func update_timer_initial_label():
	if not timer_initial_active:
		if timer_initial_label:
			timer_initial_label.visible = false
		return

	if timer_initial_label:
		timer_initial_label.visible = true
		timer_initial_label.text = "Tiempo: " + str(ceil(timer_initial_left)) + "s"

func _on_timer_initial_timeout():
	if not timer_initial_active:
		return

	print("Se acabó el tiempo inicial! Volviendo al inicio")
	if chest_checkpoint != Vector2.ZERO:
		global_position = chest_checkpoint
	else:
		global_position = start_position
	velocity = Vector2.ZERO

	timer_initial_left = timer_initial_time
	update_timer_initial_label()

# --- Timer post-cofre ---
func start_post_chest_timer():
	timer_post_left = timer_post_time
	timer_post_active = true
	timer_post_label.visible = true

func update_timer_post_label():
	if timer_post_label:
		timer_post_label.text = "Bonus: " + str(ceil(timer_post_left)) + "s"

func _on_timer_post_timeout():
	print("Se acabó el tiempo post-cofre! Respawneando en checkpoint")
	global_position = chest_checkpoint
	velocity = Vector2.ZERO

	# --- Reiniciar timer post ---
	timer_post_left = timer_post_time
	update_timer_post_label()
	timer_post_active = true

# --- Cofre tocado ---
func on_chest_opened():
	chest_touched = true
	timer_initial_active = false
	if timer_initial_label:
		timer_initial_label.visible = false
