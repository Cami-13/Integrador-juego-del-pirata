extends Area2D

var speed = 300
var direction = Vector2.RIGHT

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.name == "Player":
		body.lose_life()
		queue_free()

func _ready():
	$CollisionShape2D.disabled = false
