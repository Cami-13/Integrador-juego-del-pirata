extends CanvasLayer  # Nodo raíz del menú

# Precargamos la escena del juego
@onready var escena_juego = preload("res://cartel_info.tscn")  # Cambia la ruta a tu escena real

# Referencias a los botones
@onready var boton_jugar = $Jugar
@onready var boton_salir = $Salir

func _ready():
	# Conectamos las señales de los botones
	boton_jugar.pressed.connect(_on_boton_jugar_pressed)
	boton_salir.pressed.connect(_on_boton_salir_pressed)

func _on_boton_jugar_pressed():
	# Cambiar a la escena del juego usando PackedScene
	get_tree().change_scene_to_packed(escena_juego)

func _on_boton_salir_pressed():
	# Salir del juego
	get_tree().quit()
