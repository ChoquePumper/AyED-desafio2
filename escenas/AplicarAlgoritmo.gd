extends Control

# Variables
var buildheap: BuildHeap
var intentos: int = 0
var intentos_max: int = 3
var fase_actual: Fase
var estado_corrutina	# GDScriptFunctionState
var devolucion_de_respuesta

# Colores
export var color_nodo: Color = Color.steelblue
export var color_nodo_seleccion: Color = Color.yellow
export var color_error: Color = Color.red

onready var nodos_del_arbol: Node = $NodosDelArbol
onready var scroll_lista_valores: Node = $ScrollListaDeValores

# Señales
signal nodo_seleccionado(valor,i)
signal devolucion_de_respuesta(resultado, tu_respuesta)
signal respuesta_enviada(respuesta)

# Input
var is_dragging: bool = false
var mouse_global_position = null

# Called when the node enters the scene tree for the first time.
func _ready():
	if not Global.test_input:
		DescartarNodo($ScrollListaDeValores)
		DescartarNodo($NodosDelArbol)
		scroll_lista_valores = SacarNodoDeRaiz("ScrollListaDeValores")
		nodos_del_arbol = SacarNodoDeRaiz("NodosDelArbol")
		# Aparentemente, remover nodos hace que se desconecten de todas las señales.
		# Reconectar señales
		for i in Global.n_elementos:
			Common.getNodo(i+1).connect("gui_input", self, "_on_node_gui_input", [i+1])
	else:
		# Armar datos de prueba si, por ejemplo, se empieza desde esta escena "AplicarAlgoritmo"
		# sin pasar por el ingreso manual de datos
		
		#Global.generarValoresAleatorios(100)
		# Usando el ejemplo del anexo.
		var valores_de_prueba := [1,2,3,4,5,6,7,8,9]
		#var valores_de_prueba := [21,10,40,54, 5,36, 3, 1,45]
		#var valores_de_prueba := [ 5, 8,12, 9, 7,10,21, 6,14, 4]
		Global.n_elementos = valores_de_prueba.size()
		for i in valores_de_prueba.size():
			Global.setearCampo(i+1, str(valores_de_prueba[i]))
		
		var lista: Node = scroll_lista_valores.get_node("ListaDeValores")
		#ConectarLineEdit($ScrollListaDeValores/ListaDeValores/Valor1, 1)
		for i in Global.n_elementos: if i > 0:
			var dup_node: LineEdit = lista.get_node("Valor1").duplicate()
			dup_node.get_node("Label").text = str(i+1)
			dup_node.rect_position.y += 32
			lista.add_child( dup_node )
			#ConectarLineEdit(dup_node, i+1)
		
		# Armar árbol binario
		Common.ArmarArbolBinarioAlt(nodos_del_arbol, Global.n_elementos)
		for i in Global.n_elementos:
			var valor_campo := str(Global.getValorCampo(i+1))
			var campo: LineEdit = lista.get_child(i)
			campo.text = valor_campo
			(Common.nodos[i+1] as NodoBinario).setearNumeroPorTexto(valor_campo)
		pass
		
	assert(Global.todosLosValoresListos())
	assert(scroll_lista_valores); assert(nodos_del_arbol)
	
	# Crear una BuildHeap
	buildheap = BuildHeap.new( Global.getCopiaLista() )
	if scroll_lista_valores:
		# Deshabilitar la propiedad de editable a los campos
		var lista := scroll_lista_valores.get_node("ListaDeValores") as HBoxContainer
		for nodo in lista.get_children():
			(nodo as LineEdit).editable = false
	if nodos_del_arbol:
		(nodos_del_arbol as Control).connect("gui_input", self, "_on_gui_input")
	
	#CambiarFase( PrimeraFase.new() )
	#print( buildheap.VerNodosQueNoCumplenConLaCondicionDeOrden() )
	#buildheap.AplicarAlgoritmo()
	#print( buildheap.minheap.GetCopiaArreglo() )
	EmpezarSimulador()

func _exit_tree():
	buildheap.free()
	
func EmpezarSimulador():
	estado_corrutina = CorutinaSimulador()
# Éste será la función que aplicará el algoritmo de BuildHeap pero paso a paso.
# Esperará por la respuesta del usuario cuando se le solicite
func CorutinaSimulador() -> bool:
	var respuesta = null
	print("Primero, marcar la lista de elementos desordenados.")
	CambiarFase( PrimeraFase.new() )
	var fase_completada: bool = false
	while not fase_completada:
		respuesta = yield()
		if respuesta is Array:
			fase_completada = (respuesta == buildheap.VerNodosDesordenados())
		emit_signal("devolucion_de_respuesta", fase_completada, respuesta)
	# Señal Fase exitosa
	#emit_signal()
	yield()
	
	var nodos_desordenados: Array = buildheap.VerNodosDesordenados()
	# Si no hay nodos desordenados, se termina.
	if nodos_desordenados.size() > 0:
		print("Siguiente, marcar el nodo por donde comenzar.")
		fase_completada = false
		#CambiarFase( )
		while not fase_completada:
			respuesta = yield()
			fase_completada = respuesta == nodos_desordenados.back()
	else:
		print("No hay nodos desordenados. No hay nada más que hacer. Fin!")
		CambiarFase( FaseFinSinNodosDesordenados.new() )
	return true

func SacarNodoDeRaiz(nombre: String) -> Node:
	var nodo: Node = get_node("/root").get_node_or_null(nombre)
	if nodo:
		get_node("/root").remove_child(nodo)
		add_child(nodo)
		move_child(nodo, 0)
	return nodo

func DescartarNodo(nodo: CanvasItem):
	nodo.visible = false
	nodo.name += "_discard"
	nodo.queue_free()

func AunQuedanIntentos() -> bool: return intentos_max > intentos

func CambiarFase(fase: Fase):
	if fase_actual != null:
		fase_actual.alSalir()
		fase_actual.free()
	fase_actual = fase
	add_child(fase_actual)
	fase_actual.alEntrar()

func _on_respuesta_enviada(respuesta):
	estado_corrutina = estado_corrutina.resume(respuesta)

func _on_devolucion_de_respuesta(resultado, tu_respuesta):
	fase_actual.cb_resultado(resultado, tu_respuesta)

func _on_gui_input(event):
	# Implementación para poder arrastrar el arbol
	if nodos_del_arbol:
		if event is InputEventMouse:
			if is_dragging:
				var delta_pos: Vector2 = event.global_position - mouse_global_position
				nodos_del_arbol.rect_global_position += delta_pos
				mouse_global_position = event.global_position
		if event is InputEventMouseButton:
			# Arrastra con el clic primario
			if event.button_index == BUTTON_LEFT:
				is_dragging = event.pressed
				if is_dragging:
					mouse_global_position = (event as InputEventMouse).global_position
				else:
					mouse_global_position = null

func _on_node_gui_input(event:InputEvent, i:int):
	if event is InputEventMouseButton: if event.pressed:
		var nodobinario: NodoBinario = Common.getNodo(i)
		nodobinario.seleccionar(not nodobinario.esSeleccionado())
		emit_signal("nodo_seleccionado", nodobinario.esSeleccionado(), i)
	pass

func _on_AplicarAlgoritmo_nodo_seleccionado(valor:bool, i:int):
	fase_actual.alSeleccionar(valor,i)
	var nodobinario: NodoBinario = Common.getNodo(i)
	nodobinario.colorear(color_nodo_seleccion if nodobinario.esSeleccionado() else color_nodo)
#	if valor and i>1:
#			if buildheap.CumpleCondicionDeOrden(i):
#				prints("El nodo",i,"cumple la condición de orden.")
#			else:
#				prints("El nodo",i,"NO cumple la condición de orden.")

# Relacionado a fase
func _on_btnConfirmar_pressed():
	fase_actual.alConfirmar()

class Fase extends Node:
	var buildheap: BuildHeap
	func _init(): pass
	# Al entrar o salir de la fase
	func alEntrar():
		buildheap = $"..".buildheap
	func alSalir(): pass
	# Interacción
	func alSeleccionar(valor:bool, i:int):
		pass
	func alConfirmar(): pass
	
	func escribirInstruccion(mensaje: String):
		$"../lblInstruccion".text = mensaje
	func escribirMensaje(mensaje: String = ""):
		$"../lblInfo".text = mensaje
	func enviarRespuesta(respuesta):
		# $"..".estado_corutina = $"..".estado_corutina.resume(respuesta)
		$"..".emit_signal("respuesta_enviada", respuesta)
		#return resultado
	func cb_resultado(resultado, tu_respuesta):
		pass

# Primera fase: seleccionar los elementos que no cumplen con la condición de
# orden de la MinHeap
class PrimeraFase extends Fase:
	var seleccionados: Array = []
	var intentos: int = 0
	var intentos_max: int = 3
	var estado: int = 0
	
	func _init():
		._init()
	func alEntrar():
		.alEntrar() # De la superclase
		$"../btnConfirmar".text = "FIN"
		escribirMensaje("") # Limpiar
	func alSeleccionar(valor:bool, i:int):
		if estado == 0:
			if valor: seleccionados.append(i)
			else: seleccionados.erase(i)
			$"../btnConfirmar".text = "FIN (%d seleccionados)" % seleccionados.size()
	func alConfirmar():
		match estado:
			0: # En progreso
				intentos += 1
				# Enviar respuesta
				enviarRespuesta(seleccionados)
			1: # Éxito
				# Clic en SEGUIR >
				enviarRespuesta(null)
			2: # Falló
				# Clic en REPASAR
				pass
	func cb_resultado(resultado, tu_respuesta):
		var desordenados: Array = buildheap.VerNodosDesordenados()
		seleccionados.sort()
		if desordenados == seleccionados:
			print("Bien")
			escribirInstruccion("Bien hecho")
			escribirMensaje("¡Excelente! Marcaste todos los nodos que no cumplen la condición de orden de una Heap – Dale clic para seguir")
			estado = 1
			$"../btnConfirmar".text = "SEGUIR >"
		else:
			print("Mal")
			var lineas_msj: PoolStringArray
			lineas_msj.append("Para que sea una heap los nodos deben cumplir con una condición de orden (Intento %d/%d)"%[intentos,intentos_max] )
			match intentos:
				2:
					lineas_msj.append("Tal condición la deben cumplir los padres respecto de sus hijos.")
				_:
					if intentos >= 3:
						lineas_msj.append("Repasá los contenidos relacionados y consultá los ejercicios resueltos. Dale clic en REPASAR")
						estado = 2
						escribirInstruccion("Ha fallado")
						$"../btnConfirmar".text = "REPASAR"
			escribirMensaje("\n".join(lineas_msj))

class FaceFin extends Fase:
	func _init():
		._init()
	func alEntrar():
		.alEntrar() # De la superclase
		$"../btnConfirmar".text = "Finalizar"
	func alConfirmar():
		# Salir de la aplicacion
		get_tree().quit(0)

class FaseFinSinNodosDesordenados extends FaceFin:
	func _init():
		._init()
	func alEntrar():
		.alEntrar() # De la superclase
		escribirInstruccion("Bueno... Se acabó.")
		escribirMensaje("No hay nodos desordenados. No hay nada más que hacer.")
