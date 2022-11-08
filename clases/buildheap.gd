extends Node
class_name BuildHeap

# BuildHeap usando MinHeap

var minheap: HeapBinaria

func _init(lista: Array):
	minheap = HeapBinaria.new()
	minheap.arreglo.append_array(lista)
	minheap.size = minheap.arreglo.size() -1
	add_child(minheap)

func CumpleCondicionDeOrden(posicion: int) -> bool:
	assert(posicion > 1)
	var pos_padre = HeapBinaria.posicionPadre(posicion)
	return minheap.getValor(posicion) >= minheap.getValor(pos_padre)

func VerNodosDesordenados() -> Array:
	var lista_de_posiciones := Array()
	for i in minheap.getSize(): if i>0:
		#printt(i, minheap.getSize())
		if not CumpleCondicionDeOrden(i+1):
			lista_de_posiciones.append(i+1)
	return lista_de_posiciones

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func AplicarAlgoritmo():
	# Se empieza filtrando desde el elemento que está en la posición (tamaño/2):
	# *	se filtran los nodos que tienen hijos
	# *	el resto de los nodos son hojas
# warning-ignore:integer_division
	var i_elemento: int = minheap.getSize() / 2
	while i_elemento >= 1:
		print( minheap._PercolateDown(i_elemento) )
		i_elemento -= 1
