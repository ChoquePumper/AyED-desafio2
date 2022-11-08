extends Control

#var minheap := HeapBinaria.new()
#var nodos := Array()
var retardo_setear_posicion: int = 1
# Input
var is_dragging: bool = false
var mouse_global_position = null

# Called when the node enters the scene tree for the first time.
func _ready():
	$ScrollListaDeValores.rect_position.y -= 64
	$AnimationPlayer.play_backwards("Entrada")
	var lista: Node = $ScrollListaDeValores/ListaDeValores
	ConectarLineEdit($ScrollListaDeValores/ListaDeValores/Valor1, 1)
	for i in Global.n_elementos: if i > 0:
		var dup_node: LineEdit = $ScrollListaDeValores/ListaDeValores/Valor1.duplicate()
		dup_node.get_node("Label").text = str(i+1)
		dup_node.rect_position.y += 32
		lista.add_child( dup_node )
		ConectarLineEdit(dup_node, i+1)
	#($ScrollListaDeValores/ListaDeValores.get_child(3) as Control).rect_global_position.y += 50
	$Label.text = "Ingresá los %d valores de tu heap" % Global.n_elementos
	
	Common.ArmarArbolBinarioAlt($NodosDelArbol, Global.n_elementos)
	$ScrollListaDeValores/ListaDeValores/Valor1.grab_focus()
	
	# Ocultar botón de confirmar valores
	$btnConfirmarValores.margin_bottom = 80

# Auxiliar
func getNodoCampo(i: int) -> LineEdit:
	return $ScrollListaDeValores/ListaDeValores.get_child(i-1) as LineEdit

# Señales

func _on_RetardoSetearCampo_timeout():
	SetearCampo(retardo_setear_posicion)

func _on_field_text_changed(new_text: String, i:int):
# warning-ignore:return_value_discarded
	#(nodos[i] as NodoBinario).setearNumeroPorTexto(new_text)
	Common.getNodo(i).setearNumeroPorTexto(new_text)
	$RetardoSetearCampo.stop()
	retardo_setear_posicion = i
	$RetardoSetearCampo.start()
	
func _on_field_text_entered(_new_text: String, i:int):
	$RetardoSetearCampo.stop()
	SetearCampo(i)

func _on_field_focus(flag:bool, i: int):
	#(nodos[i] as NodoBinario).resaltar(flag)
	Common.getNodo(i).resaltar(flag)
	if not flag:
		var nodo := getNodoCampo(i)
		nodo.emit_signal("text_entered", nodo.text)
		
func _on_node_gui_input(event: InputEvent, i: int):
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.pressed: getNodoCampo(i).grab_focus()

func _on_btnAtras_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://escenas/VentanaPrincipal.tscn")
	pass # Replace with function body.

func ConectarLineEdit(nodo:LineEdit, i:int):
# warning-ignore:return_value_discarded
	nodo.connect("text_changed", self, "_on_field_text_changed", [i], CONNECT_DEFERRED)
# warning-ignore:return_value_discarded
	nodo.connect("text_entered", self, "_on_field_text_entered", [i])
# warning-ignore:return_value_discarded
	nodo.connect("focus_entered", self, "_on_field_focus", [true,i])
# warning-ignore:return_value_discarded
	nodo.connect("focus_exited", self, "_on_field_focus", [false,i])
	
	nodo.text = Global.getValorString(i)
	nodo.emit_signal("text_changed", nodo.text)

#func ArmarArbolBinarioAlt(n: int):
#	# Nodos
#	nodos.append(0)
#	for i in n:
#		var nodo := CrearNodo(Vector2.ZERO)
#		nodo.colorear(Color.steelblue)
#		#nodo.setearNumero(i+1)
#		nodos.append( nodo )
#		nodo.connect("gui_input", self, "_on_node_gui_input", [i+1])
#	# Asociar nodos
#	for i in nodos.size(): if i > 0:
#		var nodo: NodoBinario = nodos[i]
#		var i_izq = HeapBinaria.posicionHijoIzquierdo(i)
#		var i_der = HeapBinaria.posicionHijoDerecho(i)
#		if i_izq < nodos.size():
#			nodo.setHijoIzquierdo( nodos[i_izq] )
#		if i_der < nodos.size():
#			nodo.setHijoDerecho( nodos[i_der] )
#	var espacios: Array = (nodos[1] as NodoBinario).calcularEspacioHorizontal()
#	var espacio_arbol: float = espacios[0]+espacios[1]
#	var base_x: float = rect_size.x/2 - espacio_arbol/2 - nodos[1].rect_size.x/2
#
#	#for i in nodos.size(): if i > 0:
#	#	print(nodos[i].rel_hpos)
#	(nodos[1] as NodoBinario).setPosiciones(base_x+espacio_arbol*(espacios[0]/espacio_arbol), 80)
#
#func CrearNodo(pos: Vector2) -> NodoBinario:
#	var nodo = preload("res://Bola.tscn").instance()
#	nodo.set_script(NodoBinario)
#	nodo.rect_position = pos
#	nodo.rect_size /= 4
#	$NodosDelArbol.add_child(nodo)
#	return nodo

func SetearCampo(i: int):
	Global.setearCampo(i, getNodoCampo(i).text)
	if ValidarCampo(i):
		if Global.todosLosValoresListos():
			$AnimationPlayer.play_backwards("MostrarBotonConfirmar", 1)

func ValidarCampo(i: int, error_si_esta_vacio: bool = false) -> bool:
	var campo: LineEdit = getNodoCampo(i)
	var campo_valido: bool = Global.validarCampo(i)
	if not campo_valido:
		if not campo.text.empty() or error_si_esta_vacio:
			var stylebox: StyleBoxFlat = preload("res://temas/default_theme/lineedit_error_normal.tres")
			campo.add_stylebox_override("normal", stylebox)
	else:
		campo.remove_stylebox_override("normal")
	return campo_valido

# Input

func _on_gui_input(event):
	# Implementación para poder arrastrar el arbol
	if event is InputEventMouse:
		if is_dragging:
			var delta_pos: Vector2 = event.global_position - mouse_global_position
			$NodosDelArbol.rect_global_position += delta_pos
			mouse_global_position = event.global_position
	if event is InputEventMouseButton:
		# Arrastra con el clic primario
		if event.button_index == BUTTON_LEFT:
			is_dragging = event.pressed
			if is_dragging:
				mouse_global_position = (event as InputEventMouse).global_position
			else:
				mouse_global_position = null
			

func _on_btnConfirmarValores_pressed():
	# Verificar que todos los valores de la lista sean válidos
	if not Global.todosLosValoresListos():
		for i in Global.n_elementos:
			ValidarCampo(i+1, true)
	else:
		Global.test_input = false
		# Para transferir nodos de una escena a otra, se los quita de la escena
		# actual y se los pone al nodo raiz ("/root")
		MoverARaiz($NodosDelArbol)
		MoverARaiz($ScrollListaDeValores)
		get_tree().change_scene("res://escenas/AplicarAlgoritmo.tscn")

func MoverARaiz(nodo: Node):
	remove_child(nodo)
	get_node("/root").add_child(nodo)
