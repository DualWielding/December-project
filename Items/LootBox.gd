extends "res://Items/Item.gd"

export( int ) var COST_TO_OPEN = 4

func _ready():
	add_to_group( "lootbox" )

func use():
	if Player.update_coins( -COST_TO_OPEN ):
		Player.character.get_random_power_up()
		return true
	return false