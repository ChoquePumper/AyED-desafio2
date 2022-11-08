extends Node

var nodos := Array()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func ArmarArbolBinarioAlt(control: Control, n: int):
	# Nodos
	nodos.append(0)
	for i in n:
		var nodo := CrearNodo(control, Vector2.ZERO)
		nodo.colorear(Color.steelblue)
		#nodo.setearNumero(i+1)
		nodos.append( nodo )
		nodo.connect("gui_input", control.get_parent(), "_on_node_gui_input", [i+1])
	# Asociar nodos
	for i in nodos.size(): if i > 0:
		var nodo: NodoBinario = nodos[i]
		var i_izq = HeapBinaria.posicionHijoIzquierdo(i)
		var i_der = HeapBinaria.posicionHijoDerecho(i)
		if i_izq < nodos.size():
			nodo.setHijoIzquierdo( nodos[i_izq] )
		if i_der < nodos.size():
			nodo.setHijoDerecho( nodos[i_der] )
	var espacios: Array = (nodos[1] as NodoBinario).calcularEspacioHorizontal()
	var espacio_arbol: float = espacios[0]+espacios[1]
	var base_x: float = control.rect_size.x/2 - espacio_arbol/2 - nodos[1].rect_size.x/2
	
	#for i in nodos.size(): if i > 0:
	#	print(nodos[i].rel_hpos)
	(nodos[1] as NodoBinario).setPosiciones(base_x+espacio_arbol*(espacios[0]/espacio_arbol), 80)

func CrearNodo(parent:Control, pos:Vector2) -> NodoBinario:
	var nodo = preload("res://Bola.tscn").instance()
	nodo.set_script(NodoBinario)
	nodo.rect_position = pos
	nodo.rect_size /= 4
	parent.add_child(nodo)
	return nodo
	
func getNodo(i: int) -> NodoBinario:
	return nodos[i] as NodoBinario

func limpiarListaDeNodos():
	nodos.clear()
