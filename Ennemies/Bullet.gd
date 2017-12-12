extends "res://Ennemies/Ennemy.gd"

func _on_VisibilityNotifier2D_exit_screen():
	queue_free()
