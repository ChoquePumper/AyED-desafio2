extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	# Animación de entrada
	$AnimationPlayer.play_backwards("Entrada")
	$SliderNElementos.max_value = Global.MAX_ELEMENTOS
	$SliderNElementos.value = Global.n_elementos
	
	$btnContinuar.shortcut = ShortCut.new()
	$btnContinuar.shortcut.shortcut = InputEventKey.new()
	($btnContinuar.shortcut.shortcut as InputEventKey).scancode = KEY_ENTER

func incrementarN(incremento: int):
	$SliderNElementos.value += incremento

func _on_btnDecInc_pressed(incremento: int): incrementarN(incremento)

func _on_SliderNElementos_value_changed(value):
	$CenterContainer/Bola.N_elementos = int(value)
	Global.n_elementos = int(value)
	pass # Replace with function body.

func _on_btnContinuar_pressed():
# warning-ignore:return_value_discarded
	TransicionarASiguiente()

func TransicionarASiguiente():
	$SliderNElementos.visible = false
	# Animaciones de salida
	$AnimationPlayer.play("btnDecInc_salida", 1)
	$AnimationPlayer.play("Salida", 1)
	# Desconectar acciones de los botones
	$CenterContainer/Bola/btnDecrementar.disconnect("pressed", self, "_on_btnDecInc_pressed")
	$CenterContainer/Bola/btnIncrementar.disconnect("pressed", self, "_on_btnDecInc_pressed")
	$btnContinuar.disconnect("pressed", self, "_on_btnContinuar_pressed")
	# Temporizador para pasar a la siguiente pantalla luego de la animación
	#get_tree().create_timer(0.5).connect("timeout", self, "CambiarASiguiente")

func CambiarASiguiente():
# warning-ignore:return_value_discarded
	Common.limpiarListaDeNodos()
	get_tree().change_scene("res://escenas/IngresarValores.tscn")

const pluskeys = [KEY_PLUS, KEY_KP_ADD]
const minuskeys = [KEY_MINUS, KEY_KP_SUBTRACT]

func _input(event):
	var handled: bool = false
	if event is InputEventKey:
		if event.pressed:
			if event.scancode in pluskeys:
				incrementarN(1); handled = true
			elif event.scancode in minuskeys:
				incrementarN(-1); handled = true
	if handled: get_tree().set_input_as_handled()

func _on_AnimationPlayer_animation_finished(anim_name):
	#print(anim_name)
	if anim_name == "Salida":
		CambiarASiguiente()
