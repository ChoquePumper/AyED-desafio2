extends Node
class_name HeapBinaria

# Es un árbol binario completo.
#            1  2  3  4  5  6  7  8  9 10 11 ...
# Arreglo: [  |  |  |  |  |  |  |  |  |  |  ]
#       raiz^ (niv1)(___niv2___)(________niv3_...
# La raíz está almacenada en la posición 1
# Para un elemento que está en la posición i:
# * El hijo izquierdo está en la posición 2*i
# * El hijo derecho está en la posición 2*i+1
# * El padre está en la posición i/2
static func posicionHijoIzquierdo(i:int) -> int:	return 2*i
static func posicionHijoDerecho(i:int) -> int:	return 2*i+1
# warning-ignore:integer_division
static func posicionPadre(i:int) -> int:	return i/2

static func getNivel(i:int) -> int:
	assert(i > 0)
	return int( floor( log(i)/log(2) ) )

var arreglo := Array()
var size: int = 0

func _init(_arg=null):
	arreglo.append(0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func getValor(posicion:int):
	assert(posicion != 0)
	return arreglo[posicion]

func getSize() -> int: return size

# Métodos de cola de prioridad
func Insert(dato):
	arreglo.append(dato)
	size += 1
	var N = size
	# Filtrado hacia arriba o Precolate Up
#	while N>1 and arreglo[N/2] > dato:
#		arreglo[N] = arreglo[N/2]
#		N = N/2
#	arreglo[N] = dato
	_PercolateUp(N)

# Filtrado hacia arriba
# Devuelve: cantidad de niveles en subida
func _PercolateUp(p:int) -> int:
	var niveles: int = 0
	var dato = arreglo[p]
	while p>1 and arreglo[posicionPadre(p)] > dato:
		arreglo[p] = arreglo[posicionPadre(p)]
		p = posicionPadre(p)
		niveles += 1
	arreglo[p] = dato
	return niveles

func DeleteMin():
	assert(size > 0)
	var dato = arreglo[1]
	var ultimo = arreglo.pop_back()
	size -= 1
	arreglo[1] = ultimo
	# Filtrado hacia abajo o Percolate Down
	var p := 1
	_PercolateDown(p)
	return dato

# Filtrado hacia abajo
# Devuelve: cantidad de niveles en bajada
func _PercolateDown(p:int) -> Array:
	#var p := 1
	var recorrido := Array()
	while p*2 <= size:
		var i_candidato: int = p*2 # Ver en hijo izquierdo
		if i_candidato+1 <= size:
			# Ver si el hijo derecho es menor
			if arreglo[i_candidato+1] < arreglo[i_candidato]:
				i_candidato += 1
		if arreglo[i_candidato] < arreglo[p]:
			# Hacer el intercambio
			var tmp = arreglo[i_candidato]
			arreglo[i_candidato] = arreglo[p]
			arreglo[p] = tmp
			p = i_candidato
			recorrido.append(i_candidato)
		else:
			break
	return recorrido

func SimularPercolateDown(p:int):
	var recorrido := Array()
	var valor = arreglo[p]
	while p*2 <= size:
		var i_candidato: int = p*2 # Ver en hijo izquierdo
		if i_candidato+1 <= size:
			# Ver si el hijo derecho es menor
			if arreglo[i_candidato+1] < arreglo[i_candidato]:
				i_candidato += 1
		if arreglo[i_candidato] < valor:
			# No hacer intercambio
			p = i_candidato
			recorrido.append(i_candidato)
		else:
			break
	return recorrido

func GetCopiaArreglo() -> Array: return arreglo.slice(1, size)
