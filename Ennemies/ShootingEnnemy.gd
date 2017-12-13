extends "res://Ennemies/Ennemy.gd"

var bullet_scene = preload( "res://Ennemies/Bullet.tscn" )

onready var los = get_node( "LineOfSight" )
onready var at = get_node( "AttackTimer" )

export( int ) var LOS_LENGTH = 500
export( int ) var RELOAD_TIME = 1

var _reloaded = true

func _ready():
	if STARTING_DIRECTION == "Left":
		current_direction = DIRECTION_LEFT
	else:
		current_direction = DIRECTION_RIGHT
	_set_ray()
	
	at.set_wait_time( RELOAD_TIME )
	at.connect( "timeout", self, "reload" )
	at.set_one_shot( true )
	
	set_fixed_process(true)
	_set_ray()

func _fixed_process(delta):
	if los.is_colliding() and los.get_collider().is_in_group( "player" ):
		shoot()

func shoot():
	if _reloaded:
		var b = bullet_scene.instance()
		
		var pos = get_pos()
		
		if current_direction == DIRECTION_RIGHT:
			pos.x += character_size.x
		
		Player.current_level.add_enemy( b, pos )
		b.current_direction = current_direction
		at.start()
		_reloaded = false

func turn():
	if current_direction == DIRECTION_LEFT:
		current_direction = DIRECTION_RIGHT
	else:
		current_direction = DIRECTION_LEFT
	_set_ray()

func reload():
	_reloaded = true

func _set_ray():
	if current_direction == DIRECTION_RIGHT:
		los.set_cast_to( Vector2( LOS_LENGTH, 0 ) )
	elif current_direction == DIRECTION_LEFT:
		los.set_cast_to( Vector2( -LOS_LENGTH, 0 ) )