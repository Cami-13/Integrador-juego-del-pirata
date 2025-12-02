extends CharacterBody2D

@export var shoot_interval := 1.5    
@export var bullet_scene: PackedScene 
@export var bullet_speed := 200

var player_in_range = false
var player_ref = null
var can_shoot = true

func _on_range_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = true
		player_ref = body

func _on_range_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = false
		player_ref = null

func _process(delta):
	if player_in_range and can_shoot:
		shoot()
		start_shoot_cooldown()

func shoot():
	if player_ref == null:
		return
	
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)


	bullet.global_position = $ShootPoint.global_position


	var dir = (player_ref.global_position - global_position).normalized()
	bullet.direction = dir
	bullet.speed = bullet_speed

func start_shoot_cooldown():
	can_shoot = false
	await get_tree().create_timer(shoot_interval).timeout
	can_shoot = true
