extends CanvasLayer


func _on_button_button_down() -> void:
	get_tree().change_scene_to_file("res://Escenas/nivel_1.tscn")
