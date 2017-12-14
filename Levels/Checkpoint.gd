extends Area2D

export( int ) var SAVE_COST = 3

func _ready():
	add_to_group( "checkpoint" )

func activate():
	if Player.update_coins( -SAVE_COST ):
		Player.checkpoint = get_pos()