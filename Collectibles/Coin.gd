extends "res://Collectibles/Collectible.gd"

func _ready():
	if Player.desactivated_coins.find( get_pos() ) > -1:
		queue_free()
	add_to_group( "coin" )

func desactivate():
	Player.desactivated_coins.append( get_pos() )