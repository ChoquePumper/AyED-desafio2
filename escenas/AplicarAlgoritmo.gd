extends Control

# Variables
var buildheap: BuildHeap
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
# warning-ignore:unused_signal
signal respuesta_enviada(respuesta)
signal info_a_fase(info)

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
		#var valores_de_prueba := [1,2,3,4,5,6,7,8,9]
		var valores_de_prueba := [21,10,40,54, 5,36, 3, 1,45]
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
	# Fase exitosa
	yield()
	
	var nodos_desordenados: Array = buildheap.VerNodosDesordenados()
	# Si no hay nodos desordenados, se termina.
	if nodos_desordenados.size() > 0:
		print("Siguiente, marcar el nodo por donde comenzar.")
		# Empezar por tamaño/2
		var p: int = buildheap.GetSize() / 2
		var primera_iteracion: bool = true
		while p >= 1:
			fase_completada = false
			CambiarFase( FaseOrdenarNodoPrimeraVez.new() if primera_iteracion else FaseOrdenarNodo.new() )
			# Seleccionar nodo con hojas
			while not fase_completada:
				respuesta = yield()
				fase_completada = (respuesta == p)
				emit_signal("devolucion_de_respuesta", fase_completada, respuesta)
			# Seleccionar hijo izquierdo
			print("¿Y ahora? ¿Cómo sigue?")
			emit_signal("info_a_fase", {"siguiente":"seleccione_un_nodo"})
			fase_completada = false
			while not fase_completada:
				respuesta = yield()
				fase_completada = (respuesta == HeapBinaria.posicionHijoIzquierdo(p))
				emit_signal("devolucion_de_respuesta", fase_completada, HeapBinaria.posicionHijoIzquierdo(p))
			# Seleccionar hijo derecho, si tiene.
			if HeapBinaria.posicionHijoDerecho(p) <= buildheap.GetSize():
				emit_signal("info_a_fase", {
					"siguiente":"seleccione_un_nodo"
				})
				fase_completada = false
				while not fase_completada:
					respuesta = yield()
					fase_completada = (respuesta == HeapBinaria.posicionHijoDerecho(p))
					emit_signal("devolucion_de_respuesta", fase_completada, HeapBinaria.posicionHijoDerecho(p))
			# Seleccionar con que nodo hay que filtrar
			CambiarFase( FaseFiltrado.new(p) )
			fase_completada = false
			var p_filtrado: int = p
			while not fase_completada:
				respuesta = yield()
				# Comprobar si hay que filtrar
				var respuesta_correcta = VerSiguienteFiltradoHaciaAbajo(p_filtrado)
				var correcto: bool = respuesta == respuesta_correcta
				if correcto and respuesta!=null:
					# Realizar el filtrado si la respuesta es correcta
					IntercambiarNodos(p_filtrado, int(respuesta))
					p_filtrado = int(respuesta)
				emit_signal("devolucion_de_respuesta", correcto, respuesta)
				fase_completada = respuesta_correcta == null
			p -= 1
			primera_iteracion = false
	else:
		print("No hay nodos desordenados. No hay nada más que hacer. Fin!")
		CambiarFase( FaseFinSinNodosDesordenados.new() )
		yield()
	return true

# Devuelve null si no se puede filtrar o una posicion
func VerSiguienteFiltradoHaciaAbajo(p: int):
	if HeapBinaria.posicionHijoIzquierdo(p) <= buildheap.GetSize():
		var i_hijo_menor = HeapBinaria.posicionHijoIzquierdo(p)
		if (i_hijo_menor+1) <= buildheap.GetSize():
			if buildheap.GetValor(i_hijo_menor+1) < buildheap.GetValor(i_hijo_menor):
				i_hijo_menor = i_hijo_menor+1
		if buildheap.GetValor(i_hijo_menor) < buildheap.GetValor(p):
			return i_hijo_menor
	return null

func IntercambiarNodos(p_a:int, p_b:int):
	assert( buildheap.IntercambiarNodos(p_a, p_b) )
	SetValorArreglo(p_a)
	SetValorArreglo(p_b)

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

func SetValorArreglo(i:int):
	var valor: String = str( buildheap.GetValor(i) )
	scroll_lista_valores.get_node("ListaDeValores").get_child(i-1).text = valor
	Common.getNodo(i).setearNumeroPorTexto( valor )

func CambiarFase(fase: Fase):
	if fase_actual != null:
		fase_actual.alSalir()
		fase_actual.free()
	fase_actual = fase
	add_child(fase_actual)
	fase_actual.alEntrar()

func SeleccionarNodo(i: int, valor: bool):
	var nodobinario: NodoBinario = Common.getNodo(i)
	nodobinario.seleccionar(valor)
	emit_signal("nodo_seleccionado", nodobinario.esSeleccionado(), i)

func _on_respuesta_enviada(respuesta):
	estado_corrutina = estado_corrutina.resume(respuesta)

func _on_devolucion_de_respuesta(resultado, tu_respuesta):
	fase_actual.cb_resultado(resultado, tu_respuesta)

func _on_info_a_fase(info):
	fase_actual.cb_info_fase(info)

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
		SeleccionarNodo(i, not nodobinario.esSeleccionado())
	pass

func _on_AplicarAlgoritmo_nodo_seleccionado(valor:bool, i:int):
	fase_actual.alSeleccionar(valor,i)
	#var nodobinario: NodoBinario = Common.getNodo(i)
	#nodobinario.colorear(color_nodo_seleccion if nodobinario.esSeleccionado() else color_nodo)
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
	func alSeleccionar(_valor:bool, _i:int):
		pass
	func alConfirmar(): pass
	
	func escribirInstruccion(mensaje: String):
		$"../lblInstruccion".text = mensaje
	func escribirMensaje(mensaje: String = ""):
		$"../lblInfo".text = mensaje
	func setEtiquetaBotonConfirmar(mensaje: String = ""):
		$"../btnConfirmar".text = mensaje
	func enviarRespuesta(respuesta):
		# $"..".estado_corutina = $"..".estado_corutina.resume(respuesta)
		$"..".emit_signal("respuesta_enviada", respuesta)
		#return resultado
	# Funciones fuera de la clase interna
	func seleccionarNodo(i: int, valor: bool):
		$"..".SeleccionarNodo(i,valor)
	# Callbacks
	func cb_resultado(_resultado, _tu_respuesta):
		pass
	func cb_info_fase(_info): pass

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
		setEtiquetaBotonConfirmar("FIN")
		escribirMensaje("") # Limpiar
	func alSalir():
		.alSalir()
		for i in seleccionados.duplicate():
			seleccionarNodo(i, false)
			Common.colorearNodo(i, $"..".color_nodo)
	func alSeleccionar(valor:bool, i:int):
		if estado == 0:
			if valor: seleccionados.append(i)
			else: seleccionados.erase(i)
			setEtiquetaBotonConfirmar( "FIN (%d seleccionados)" % seleccionados.size() )
			Common.colorearNodo(i, $"..".color_nodo_seleccion if valor else $"..".color_nodo)
	func alConfirmar():
		match estado:
			0: # En progreso
				intentos += 1
				# Enviar respuesta
				seleccionados.sort()
				enviarRespuesta(seleccionados)
			1: # Éxito
				# Clic en SEGUIR >
				enviarRespuesta(null)
			2: # Falló
				# Clic en REPASAR
				pass
	func cb_resultado(resultado, tu_respuesta):
		if resultado: # == true
			print("Bien")
			escribirInstruccion("¡Excelente!")
			escribirMensaje("Marcaste todos los nodos que no cumplen la condición de orden de una Heap – Dale clic para seguir")
			estado = 1
			setEtiquetaBotonConfirmar("SEGUIR >")
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
						setEtiquetaBotonConfirmar("REPASAR")
			escribirMensaje("\n".join(lineas_msj))

class FaseOrdenarNodo extends Fase:
	var paso: String
	var seleccionado: int = 0
	var str_ins_inicio: String = "Buenísimo!!! – ¿Por qué nodo corresponde seguir ahora?"
	var str_ins_correcto: String = "¡Correcto!"
	func _init(): ._init()
	func alEntrar():
		.alEntrar()
		escribirInstruccion(str_ins_inicio)
		escribirMensaje("")
		cambiarPaso("seleccionar_nodo_a_ordenar")
	func alSeleccionar(valor:bool, i:int):
		seleccionado = i
		enviarRespuesta(i)
	func cb_resultado(resultado, tu_respuesta):
		match paso:
			"seleccionar_nodo_a_ordenar":
				if resultado:
					Common.colorearNodo(int(tu_respuesta), Color.darkgreen)
					Common.getNodo(int(tu_respuesta)).seleccionar(false)
					escribirInstruccion(str_ins_correcto)
				else:
					escribirInstruccion("No es correcto - Reintentá")
					escribirMensaje("Recordá que hay una fórmula y un criterio para saber por dónde se comienza")
			"seleccione_un_nodo":
				if resultado:
					Common.colorearNodo(int(tu_respuesta), Color.yellow)
					escribirInstruccion("Bien. ¿Cuál otro?")
	func cb_info_fase(info):
		assert(info is Dictionary)
		if info.has("siguiente"):
			cambiarPaso( info["siguiente"] )
	func cambiarPaso(nombre:String):
		match nombre:
			"seleccionar_nodo_a_ordenar":
				pass
			"seleccione_un_nodo":
				print("paso: nombre ",nombre)
				if paso!=nombre:
					escribirMensaje("¿Y ahora? ¿Cómo sigue?")
				else:
					escribirMensaje("¿Cómo sigue?")
			_:
				printerr("Paso desconocido: "+nombre)
		paso = nombre

class FaseOrdenarNodoPrimeraVez extends FaseOrdenarNodo:
	func _init():
		._init()
		str_ins_inicio = "Comenzá a aplicar el algoritmo - Marcá el nodo por el cual debemos comenzar"
		str_ins_correcto = "¡Correcto! Es nuestro comienzo"

class FaseFiltrado extends Fase:
	var posicion: int
	var seleccionado
	func _init(i:int):
		._init()
		posicion = i
	func alEntrar():
		.alEntrar()
		assert(posicion <= buildheap.GetSize())
		escribirInstruccion("Ok. ¿Y ahora? ¿Hay que intercambiar? ¿Cual?")
		escribirMensaje("Seleccione un nodo o haga clic en NO si no hay que intercambiar")
		setEtiquetaBotonConfirmar("NO")
	func alSeleccionar(valor:bool, i:int):
		enviarRespuesta(i)
	func alConfirmar():
		enviarRespuesta(null)
		
class FaceFin extends Fase:
	func _init():
		._init()
	func alEntrar():
		.alEntrar() # De la superclase
		setEtiquetaBotonConfirmar("Finalizar")
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

