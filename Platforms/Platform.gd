extends KinematicBody2D

const TILE_SIZE = Vector2( 64, 64 )

onready var dir_t = get_node( "DirectionTimer" )

export( int ) var SPEED = 70
export( bool ) var IS_MOVING_PLATFORM = false
export( int ) var DIR_CHANGE_TIMER = 1
export( int, "Left-Right", "Right-Left", "Top-Down", "Bottom-Up" ) var DIR_PLATFORM = 0

var _velocity = Vector2( 0, 0 ) setget set_velocity, get_velocity
var movement_phase = 1

var left_size
var right_size

func _ready():
	left_size = TILE_SIZE.x * ( ( get_scale().x - 1 ) / 2 )
	right_size = TILE_SIZE.x * ( ( get_scale().x + 1 ) / 2 )
	
	add_to_group( "platform" )
	
	if IS_MOVING_PLATFORM:
		add_to_group( "moving_platform" )
		
		if DIR_PLATFORM == 2 or DIR_PLATFORM == 3:
			add_to_group( "v_moving_platform" )
		
		set_fixed_process( true )
		
		dir_t.set_wait_time( DIR_CHANGE_TIMER )
		dir_t.connect( "timeout", self, "direction_change")
		dir_t.start()
		
		# Start the platform
		direction_change()

func _fixed_process( delta ):
	move( _velocity * delta )
	
	# Change direction if hitting another platform
	if is_colliding():
		var n = get_collision_normal()
		if not get_collider().is_in_group( "character" ):
			direction_change()
			dir_t.stop()
			dir_t.start()
		else:
			if n == Vector2( 0, -1 ):
				get_collider().die()

##################
# DIRECTION
##################

func direction_change():
	if not IS_MOVING_PLATFORM:
		return
		
	if DIR_PLATFORM == 0:
		if movement_phase == 0:
			_velocity = Vector2( SPEED, 0 )
		else:
			_velocity = Vector2( -SPEED, 0 )
	elif DIR_PLATFORM == 1:
		if movement_phase == 0:
			_velocity = Vector2( -SPEED, 0 )
		else:
			_velocity = Vector2( SPEED, 0 )
	elif DIR_PLATFORM == 2:
		if movement_phase == 0:
			_velocity = Vector2( 0, -SPEED )
		else:
			_velocity = Vector2( 0, SPEED )
	elif DIR_PLATFORM == 3:
		if movement_phase == 0:
			_velocity = Vector2( 0, SPEED )
		else:
			_velocity = Vector2( 0, -SPEED )
	
	movement_phase = abs(movement_phase - 1)


##################
# SETGET
##################

func set_velocity( vector ):
	_velocity = vector

func get_velocity():
	return _velocity