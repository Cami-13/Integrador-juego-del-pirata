extends Area2D

@export var required_gold: int = 10
@export var next_scene_path: String = "res://victoria.tscn"

var triggered: bool = false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if triggered:
		return

	if body.is_in_group("Player"):
		if body.gold >= required_gold:
			triggered = true
			print("Tienes suficiente oro! Cargando la siguiente escena...")
			get_tree().change_scene_to_file(next_scene_path)
		else:
			print("Te falta oro para pasar!")
