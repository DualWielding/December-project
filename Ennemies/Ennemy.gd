extends "res://Character.gd"

var _lootbox_class = preload( "res://Items/LootBox.tscn" )

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
	if ( get_pos() - by.get_pos() ).normalized().x > 0:
		velocity += HIT_KNOCKBACK
	else:
		velocity += Vector2(-HIT_KNOCKBACK.x, HIT_KNOCKBACK.y)
	turn()

func die():
	var lb = _lootbox_class.instance()
	Player.current_level.add_item( lb, get_pos() )
	queue_free()