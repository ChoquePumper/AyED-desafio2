extends Node

var test_input = true

var n_elementos: int = 9
var lista_elementos := Array()

const MAX_ELEMENTOS: int = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in MAX_ELEMENTOS: lista_elementos.append(null)
	#print("global loaded")
	#print(lista_elementos)

func valorValido(valor: String):
	return valor.is_valid_integer()

func setearCampo(i:int, valor: String):
	assert(i>0); assert(i<=MAX_ELEMENTOS)
	var res = null
	if valorValido(valor):
		res = int(valor)
	lista_elementos[i-1] = res

func validarCampo(i: int):
	return lista_elementos[i-1] != null

func getValorCampo(i: int): return lista_elementos[i-1]

func getValorString(i: int) -> String:
	var res = getValorCampo(i)
	return "" if not res else str(res)

func todosLosValoresListos():
	for i in n_elementos:
		if not validarCampo(i+1): return false
	return true

func generarValoresAleatorios(maximo:int = 999):
	randomize()
	for i in n_elementos:
		lista_elementos[i] = 1 + randi() % maximo
		
func getCopiaLista() -> Array: return lista_elementos.slice(0,n_elementos-1)
