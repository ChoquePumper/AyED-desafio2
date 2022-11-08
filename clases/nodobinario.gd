extends "res://Bola.gd"
class_name NodoBinario

var espacio: float = 96

var dato
var hijo_izquierdo: NodoBinario
var hijo_derecho: NodoBinario

var rel_hpos: float = 0

func _init(dato = null):
	setDato(dato)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# warning-ignore:shadowed_variable
func setDato(dato):
	self.dato = dato

func getHijoIzquierdo():	return hijo_izquierdo
	
func getHijoDerecho():	return hijo_derecho

func setHijoIzquierdo(arbol: NodoBinario):
	hijo_izquierdo = arbol
	
func setHijoDerecho(arbol: NodoBinario):
	hijo_derecho = arbol

func esHoja(): return (hijo_izquierdo==null) and (hijo_derecho==null)
	
func calcularEspacioHorizontal() -> Array:
	#if esHoja(): return 0.0
	var total_l: float = 0.0
	var total_r: float = 0.0
	if hijo_izquierdo != null:
		var espacios: Array = hijo_izquierdo.calcularEspacioHorizontal()
		var calc_r: float = espacios[1]
		var calc_l: float = espacios[0]
		hijo_izquierdo.rel_hpos = -(espacio/2 + calc_r)
		total_l += calc_l + calc_r + espacio/2
	if hijo_derecho != null:
		var espacios: Array = hijo_derecho.calcularEspacioHorizontal()
		var calc_r: float = espacios[1]
		var calc_l: float = espacios[0]
		hijo_derecho.rel_hpos = espacio/2 + calc_l
		total_r += espacio/2 + calc_l + calc_r
	return [total_l, total_r]
	
func setPosiciones(offset_x: float = 0.0, offset_y: float = 0.0):
	offset_x += rel_hpos
	rect_position.x = offset_x
	rect_position.y = offset_y
	if hijo_izquierdo != null: hijo_izquierdo.setPosiciones(offset_x, offset_y+80)
	if hijo_derecho != null: hijo_derecho.setPosiciones(offset_x, offset_y+80)

func seleccionar(valor:bool):
	es_seleccionado = valor

func esSeleccionado() -> bool: return es_seleccionado
