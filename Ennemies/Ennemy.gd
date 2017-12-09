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

func _collide_left():
	turn()

func _collide_right():
	turn()

func gets_hit( by ):
	if (get_pos() - by.get_pos()).normalized().x == 1:
		velocity += HIT_KNOCKBACK
	else:
		velocity += Vector2(-HIT_KNOCKBACK.x, HIT_KNOCKBACK.y)
	turn()