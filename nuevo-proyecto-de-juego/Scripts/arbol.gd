extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	if animated_sprite_2d:
		animated_sprite_2d.play("Idle")  
