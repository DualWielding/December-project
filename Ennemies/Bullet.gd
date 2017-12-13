extends "res://Ennemies/Ennemy.gd"

func _ready():
	add_to_group( "bullet" )

func _on_VisibilityNotifier2D_exit_screen():
	queue_free()