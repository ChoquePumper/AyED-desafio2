extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
#	var He1 = HeapBinaria.new()
#	He1.name = "TestHeapBinaria"
#
#	for x in [10, 12, 1, 14, 6]:
#		He1.Insert(x)
#	print(He1.GetCopiaArreglo())
#
#	for _i in 2: He1.DeleteMin()
#	print(He1.GetCopiaArreglo())
#
#	for x in [5, 8, 15, 3]:
#		He1.Insert(x)
#	print(He1.GetCopiaArreglo())
#
#	for _i in 2: He1.DeleteMin()
#	print(He1.GetCopiaArreglo())
#
#	add_child(He1)
#	var H := HeapBinaria.new()
#	for x in [11, 22, 3, 4, 16, 55, 7, 10, 33, 6, 14, 1, 18, 33, 12]:
#		H.Insert(x)
#		print(H.GetCopiaArreglo())
	$VBoxContainer/btnComenzar.grab_focus()

# Al pulsar el botón de Comenzar, pasar a la siguiente pantalla
func _on_btnComenzar_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://escenas/VentanaPrincipal.tscn")
