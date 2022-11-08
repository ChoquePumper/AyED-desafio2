tool
extends "res://Bola.gd"

export(int, 9, 20) var N_elementos = 9 setget _n_setter

func _n_setter(n:int):
	N_elementos = n
	$MeshInstance2D/Label.text = str(N_elementos)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
