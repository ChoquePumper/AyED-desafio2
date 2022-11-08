tool
extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var coloreado: Color = Color.white
var coloreado_resaltado: Color = coloreado
var es_resaltado: bool = false
var es_seleccionado: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	arreglarTamanios()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Bola_item_rect_changed():
	arreglarTamanios()

func arreglarTamanios():
	rect_pivot_offset = rect_size / 2
	$MeshInstance2D.scale.y = rect_size.y / 256
	$MeshInstance2D.scale.x = rect_size.x / 256
	$MeshInstance2D.position = rect_pivot_offset
	
func colorear(color: Color):
	coloreado = color
	coloreado_resaltado = color.lightened(0.25)
	colorear2()

func colorear2():
	$MeshInstance2D.self_modulate = coloreado_resaltado if es_resaltado else coloreado

func resaltar(flag: bool):
	es_resaltado = flag
	colorear2()

func setearNumero(n: int):
	$MeshInstance2D/Label.text = str(n)

func setearNumeroPorTexto(num: String) -> bool:
	if Global.valorValido(num):
		setearNumero(int(num))
		return true
	else:
		$MeshInstance2D/Label.text = ""
		return false
