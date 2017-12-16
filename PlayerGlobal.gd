extends Node

const STARTING_COINS = 20
const LIFE_COST = 10

var coins = STARTING_COINS setget update_coins, get_coins
var current_level = null

var character
var ui
var checkpoint = null #DO NOT FORGET TO CLEAN THE CHECKPOINT AT LVL CHANGE
var current_pu = null setget set_power_up, get_power_up

enum power_ups {
	none,
	laser
}

signal coins_updated( current_number )
signal power_up_gained( power_up )

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

func set_power_up( power_up ):
	current_pu = power_up
	emit_signal( "power_up_gained", get_power_up() )

func get_power_up():
	return current_pu