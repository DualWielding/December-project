extends Node

const STARTING_COINS = 20
const LIFE_COST = 10

var coins = STARTING_COINS setget update_coins, get_coins
var current_level = null

var character
var ui

signal coins_updated( current_number )

func update_coins( amount ):
	if coins + amount >= 0:
		coins += amount
		emit_signal( "coins_updated", get_coins() )
		return true
	else:
		buy_coins()
		return false

func buy_coins():
	pass #TODO

func get_coins():
	return coins