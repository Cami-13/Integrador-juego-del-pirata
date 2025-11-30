extends Node2D

@onready var gold_label = $CanvasLayer/GoldLabel

func update_gold(amount):
	gold_label.text = "Oro: " + str(amount)
