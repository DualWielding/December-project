extends "res://Ennemies/Ennemy.gd"

onready var los = get_node( "LineOfSight" )
onready var at = get_node( "AttackTimer" )

export( int ) var LOS_LENGTH = 500
export( int ) var RELOAD_TIME = 1

var _reloaded = true

func _ready():
	if STARTING_DIRECTION == "Left":
		current_direction = Directions.left
	else:
		current_direction = Directions.right
	_set_ray()
	
	at.set_wait_time( RELOAD_TIME )
	at.connect( "timeout", self, "reload" )
	at.set_one_shot( true )
	
	set_fixed_process(true)
	_set_ray()

func _fixed_process(delta):
	if is_walking() and los.is_colliding() and los.get_collider().is_in_group( "player" ):
		shoot()

func shoot():
	if _reloaded:
		pop_bullet() # In Character
		at.start()
		_reloaded = false

func turn():
	if current_direction == Directions.left:
		current_direction = Directions.right
	else:
		current_direction = Directions.left
	_set_ray()

func reload():
	_reloaded = true

func _set_ray():
	if current_direction == Directions.right:
		los.set_cast_to( Vector2( LOS_LENGTH, 0 ) )
	elif current_direction == Directions.left:
		los.set_cast_to( Vector2( -LOS_LENGTH, 0 ) )