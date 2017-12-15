extends KinematicBody2D

var _direction
var _speed

var velocity = Vector2()

func _ready():
	add_to_group( "bullet" )
	set_fixed_process( true )

func init( direction, speed ):
	_direction = direction
	_speed = speed

func _fixed_process( delta):
	if _direction == Directions.right:
		velocity.x = _speed
	else:
		velocity.x = -_speed
	
	var motion = velocity * delta
	move( motion )
	
	if is_colliding():
		var collider = get_collider()
		if collider.is_in_group( "character" ):
			collider.die()
		queue_free()

func change_direction():
	if _direction == Directions.right:
		_direction = Directions.left
	else:
		_direction = Directions.right