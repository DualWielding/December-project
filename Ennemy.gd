extends "res://Character.gd"

const CHAR_SIZE = 64
const TILE_SIZE = 64

func _ready():
	add_to_group( "enemy" )

func turn():
	if current_direction == DIRECTION_LEFT:
		current_direction = DIRECTION_RIGHT
	else:
		current_direction = DIRECTION_LEFT