extends "res://Character.gd"

var _lootbox_class = preload( "res://Items/LootBox.tscn" )

func _ready():
	add_to_group( "enemy" )
	set_fixed_process( true )

func _fixed_process(delta):
	if is_colliding() and get_collider().is_in_group( "player" ):
		get_collider().die()

func turn():
	if current_direction == DIRECTION_LEFT:
		current_direction = DIRECTION_RIGHT
	else:
		current_direction = DIRECTION_LEFT

func _additional_collide_bot():
	set_walking()

func _collide_left():
	turn()

func _collide_right():
	turn()

func gets_hit( by ):
	set_kb()
	velocity.y += HIT_KNOCKBACK.y

func die():
	var lb = _lootbox_class.instance()
	Player.current_level.add_item( lb, get_pos() )
	queue_free()