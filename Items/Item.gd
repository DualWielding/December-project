extends KinematicBody2D

export( int ) var FLYING_SPEED = 600
export( int ) var GRAVITY = 175

var flying = false
var direction = Vector2()

var velocity = Vector2()

func _ready():
	add_to_group( "item" )
	set_fixed_process( true )

func _fixed_process( delta ):
	if flying:
		set_rot( get_rot() - 0.15 )
		velocity.x = FLYING_SPEED * direction.x
		velocity.y += GRAVITY * delta
		
		var motion = velocity * delta
		move( motion )
		
	if is_colliding():
		if get_collider().is_in_group( "enemy" ):
			get_collider().gets_hit( self )
		queue_free()

func configure_for_holding():
	set_collision_mask_bit( 11, false )

func configure_for_hitting_ennemies():
	set_collision_mask_bit( 1, true )
	set_collision_mask_bit( 4, true )

func threw_to( direction ):
	configure_for_hitting_ennemies()
	self.direction = direction
	flying = true

func use( by ):
	pass