extends "res://Character.gd"

var _lootbox_class = preload( "res://Items/LootBox.tscn" )

export( String, "Left", "Right" ) var STARTING_DIRECTION = "Left"

func _ready():
	if STARTING_DIRECTION == "Left":
		current_direction = Directions.left
	else:
		current_direction = Directions.right
	
	add_to_group( "enemy" )
	set_fixed_process( true )

func _fixed_process(delta):
	if is_colliding() and get_collider().is_in_group( "player" ):
		get_collider().die()

func turn():
	if current_direction == Directions.left:
		current_direction = Directions.right
	else:
		current_direction = Directions.left

func _additional_general_collision_behaviour():
	if get_collider().is_in_group( "player" ):
		get_collider().die()

func _additional_collide_bot():
	set_walking()

func _collide_left():
	turn()

func _collide_right():
	turn()

func gets_hit( by ):
	set_kb()
	velocity.y += HIT_KNOCKBACK.y
	if get_pos() > by.get_pos():
		current_direction = Directions.right
	else:
		current_direction = Directions.left

func die():
	var lb = _lootbox_class.instance()
	Player.current_level.add_item( lb, get_pos() )
	queue_free()