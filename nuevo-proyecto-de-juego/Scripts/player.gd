extends CharacterBody2D

@export var move_speed: float = 100.0
@export var jump_speed: float = 300.0
@onready var spawn_point: Node2D = $"../SpawnPoint"

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

@export var timer_initial_time: float = 55.0
var timer_initial_left: float = timer_initial_time
var timer_initial_active: bool = true
@onready var timer_initial_label: Label = $"../CanvasLayer/TimerInitialLabel"

@export var timer_post_time: float = 20.0
var timer_post_left: float = timer_post_time
var timer_post_active: bool = false
@onready var timer_post_label: Label = $"../CanvasLayer/TimerPostLabel"

@onready var gold_label: Label = $"../CanvasLayer/GoldLabel"
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite

var chest_checkpoint: Vector2 = Vector2.ZERO
var chest_touched: bool = false

var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

@export var default_knockback_horizontal: float = 380.0
@export var default_knockback_vertical: float = 260.0
@export var default_knockback_duration: float = 0.25

# -----------------------------
# ANIMACIONES
# -----------------------------
var animations_default := {
	"Idle": "Idle",
	"Run": "Run",
	"Jump": "Jump",
	"Fall": "Fall"
}

var animations_sword := {
	"Idle": "Idle Sword",
	"Run": "Run Sword",
	"Jump": "Jump Sword",
	"Fall": "Fall Sword"
}

# -------------------------------------------------
# READY
# -------------------------------------------------
func _ready() -> void:
	if spawn_point:
		start_position = spawn_point.global_position
	else:
		start_position = global_position

	timer_initial_left = timer_initial_time
	timer_initial_active = true
	call_deferred("update_timer_initial_label")

	timer_post_label.visible = false  
	update_gold_label()

	global_position = start_position

# -------------------------------------------------
# PHYSICS
# -------------------------------------------------
func _physics_process(delta: float) -> void:
	# Knockback
	if knockback_timer > 0.0:
		velocity = knockback
		knockback_timer -= delta
		if knockback_timer <= 0.0:
			knockback = Vector2.ZERO
			can_move = true
	else:
		_movement(delta)

	# Gravedad
	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()

	if is_dead:
		return

	update_animations()

	# Timer inicial (solo si NO tocó cofre)
	if timer_initial_active and not chest_touched:
		timer_initial_left -= delta
		if timer_initial_left <= 0:
			_on_timer_initial_timeout()
		update_timer_initial_label()

	# Timer post cofre
	if timer_post_active:
		timer_post_left -= delta
		if timer_post_left <= 0:
			_on_timer_post_timeout()
		update_timer_post_label()

# -------------------------------------------------
# MOVIMIENTO
# -------------------------------------------------
func _movement(delta: float) -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor() and can_move:
		velocity.y = -jump_speed

	if can_move:
		move_x()

	flip()

func move_x() -> void:
	if not can_move:
		return

	var input_axis = Input.get_axis("move_left", "move_right")
	velocity.x = input_axis * move_speed

func flip() -> void:
	if (is_facing_right and velocity.x < 0) or (not is_facing_right and velocity.x > 0):
		scale.x = -scale.x
		is_facing_right = !is_facing_right

# -------------------------------------------------
# ANIMACIONES
# -------------------------------------------------
func update_animations():
	if is_dead:
		return

	var anim_set = animations_default
	if chest_touched:
		anim_set = animations_sword

	if not is_on_floor():
		if velocity.y < 0:
			animated_sprite.play(anim_set["Jump"])
		else:
			animated_sprite.play(anim_set["Fall"])
		return

	if velocity.x != 0:
		animated_sprite.play(anim_set["Run"])
	else:
		animated_sprite.play(anim_set["Idle"])

# -------------------------------------------------
# KNOCKBACK
# -------------------------------------------------
func apply_knockback(direction: Vector2, horizontal_force: float = default_knockback_horizontal, vertical_force: float = default_knockback_vertical, duration: float = default_knockback_duration) -> void:
	if direction == Vector2.ZERO:
		return

	can_move = false

	var dir = direction.normalized()
	var kb_x = dir.x * horizontal_force
	var kb_y = -abs(vertical_force)

	knockback = Vector2(kb_x, kb_y)
	knockback_timer = duration

# -------------------------------------------------
# MUERTE
# -------------------------------------------------
func play_dead_hit():
	can_move = false
	is_dead = true
	velocity = Vector2.ZERO

	animated_sprite.play("Dead Hit")
	await animated_sprite.animation_finished

	play_dead_ground()

func play_dead_ground():
	can_move = false
	is_dead = true
	velocity = Vector2.ZERO

	animated_sprite.play("Dead Ground")
	await animated_sprite.animation_finished

	await get_tree().create_timer(1.5).timeout  
	respawn_player()

# -------------------------------------------------
# RESPAWN
# -------------------------------------------------
func respawn_player():
	if chest_touched and chest_checkpoint != Vector2.ZERO:
		global_position = chest_checkpoint
	else:
		global_position = start_position

	is_dead = false
	can_move = true
	velocity = Vector2.ZERO

	# Timer inicial → solo si NO tocó el cofre
	if not chest_touched:
		timer_initial_left = timer_initial_time
		timer_initial_active = true
		update_timer_initial_label()
	else:
		timer_initial_active = false
		timer_initial_label.visible = false
		# Bonus timer se reinicia cada vez que mueres después de tocar el cofre
		start_post_chest_timer()

	# Animación correcta al respawnear
	if chest_touched:
		animated_sprite.play(animations_sword["Idle"])
	else:
		animated_sprite.play(animations_default["Idle"])

# -------------------------------------------------
# PERDER VIDA
# -------------------------------------------------
func lose_life(damage_from_position = null) -> void:
	if is_dead:
		return

	if frontal_immune and damage_from_position != null:
		var dir_to_damage = (damage_from_position - global_position).normalized()
		if (is_facing_right and dir_to_damage.x > 0) or (not is_facing_right and dir_to_damage.x < 0):
			return

	life -= 1

	if damage_from_position != null:
		var dir = (body_pos_to_player_direction(damage_from_position)).normalized()
		apply_knockback(dir)

	play_dead_hit()

func lose_life_from_direction(dir_to_damage: Vector2):
	if is_dead:
		return

	if frontal_immune:
		if (is_facing_right and dir_to_damage.x > 0) or (not is_facing_right and dir_to_damage.x < 0):
			return

	life -= 1
	apply_knockback(dir_to_damage)
	play_dead_hit()

func body_pos_to_player_direction(damage_from_position: Vector2) -> Vector2:
	return (global_position - damage_from_position) * -1

# -------------------------------------------------
# ORO / ESPADA
# -------------------------------------------------
func add_gold(amount: int):
	gold += amount
	update_gold_label()

func add_sword(sword_name: String):
	inventory_sword = sword_name
	frontal_immune = true

func update_gold_label():
	if gold_label:
		gold_label.text = "Oro: " + str(gold)

# -------------------------------------------------
# CHECKPOINT / COFRE
# -------------------------------------------------
func set_checkpoint(new_position: Vector2) -> void:
	chest_checkpoint = new_position

func on_chest_opened():
	chest_touched = true
	timer_initial_active = false
	timer_initial_label.visible = false

	start_post_chest_timer()  # bonus timer se activa al tocar el cofre

# -------------------------------------------------
# TIMERS
# -------------------------------------------------
func update_timer_initial_label():
	if not timer_initial_active:
		timer_initial_label.visible = false
		return

	timer_initial_label.visible = true
	timer_initial_label.text = "Tiempo: " + str(ceil(timer_initial_left)) + "s"

func _on_timer_initial_timeout():
	if not timer_initial_active:
		return

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
	if chest_checkpoint != Vector2.ZERO:
		global_position = chest_checkpoint

	velocity = Vector2.ZERO
	timer_post_left = timer_post_time
	update_timer_post_label()
	timer_post_active = true
