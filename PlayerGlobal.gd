extends Node

var coins = 0 setget update_coins, get_coins

signal coins_updated( current_number )

func update_coins( amount ):
	coins += amount
	emit_signal( "coins_updated", get_coins() )

func get_coins():
	return coins