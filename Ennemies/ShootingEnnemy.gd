extends "res://Ennemies/Ennemy.gd"

onready var los = get_node( "LineOfSight" )
onready var at = get_node( "AttackTimer" )
onready var pt = get_node( "PrimoTimer" )

export( int ) var LOS_LENGTH = 500
export( int ) var RELOAD_TIME = 1

var _reloaded = true
var _pt_working = false

func _ready():
	if STARTING_DIRECTION == "Left":
		current_direction = Directions.left
	else:
		current_direction = Directions.right
	_set_ray()
	
	at.set_wait_time( RELOAD_TIME )
	at.connect( "timeout", self, "reload" )
	pt.connect( "timeout", self, "shoot" )
	
	set_fixed_process(true)
	_set_ray()

func _fixed_process(delta):
	if is_walking() and los.is_colliding() and los.get_collider().is_in_group( "player" ):
		shooting_delay()

func shooting_delay():
	if not _pt_working:
		pt.start()
		_pt_working = true

func shoot():
	_pt_working = false
	if _reloaded:
		pop_bullet() # Func def is in Character
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