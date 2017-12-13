extends KinematicBody2D

const DIRECTION_RIGHT = 1
const DIRECTION_LEFT = -1

const TILE_SIZE = Vector2( 64, 64 )

export(int) var GRAVITY = 1000
export(int) var WALK_SPEED = 300
export(Vector2) var HIT_KNOCKBACK = Vector2(800, -500)
export(int) var VELOCITY_DEATH_CEIL = 900

var global_velocity_death_ceil = VELOCITY_DEATH_CEIL + 1000
var velocity = Vector2()
var on_floor = false
var current_direction = DIRECTION_RIGHT
var character_size = Vector2( 64, 64 )
var can_move = true
var is_kb = false
var is_on_v_moving_platform = false
var mp = null

enum status {
	picking,
	walking,
	idle,
	kb
}

var current_status = status.walking

func _ready():
	add_to_group( "character" )
	set_fixed_process( true )

func _fixed_process( delta ):
	if velocity.y >= global_velocity_death_ceil:
		die()
	
	on_floor = false
	
	velocity.x = 0
	
	# For v moving platform
	if is_on_v_moving_platform:
		velocity = mp.get_velocity()
		_check_if_still_on_platform() # Used to fall down from a v moving platform
	else:
		velocity.y += delta * GRAVITY
	
	if is_walking():
		if current_direction == DIRECTION_LEFT:
			velocity.x += -WALK_SPEED
		elif current_direction == DIRECTION_RIGHT:
			velocity.x += WALK_SPEED
	elif is_kb():
		if current_direction == DIRECTION_LEFT:
			velocity.x -= HIT_KNOCKBACK.x
		elif current_direction == DIRECTION_RIGHT:
			velocity.x += HIT_KNOCKBACK.x
	
	var motion = velocity * delta
	move( motion )
	
	
	if is_colliding():
		var collider = get_collider()
		# For H moving platforms
		if collider.is_in_group( "moving_platform" ):
			motion += collider.get_velocity() * delta
		
		_handle_kinematic_character_collision( motion )


func die():
	queue_free()


################
# GETTING HIT
################

func gets_hit(by):
	pass


################
# COLLIDING
################

func _handle_kinematic_character_collision( motion ):
	
	# Used to move properly around obstacles
	var n = get_collision_normal()
	
	if n == Vector2(0, -1):
		_collide_bot()
	elif n == Vector2(0, 1):
		_collide_up()
	elif n == Vector2(-1, 0):
		_collide_left()
	elif n == Vector2(1, 0):
		_collide_right()
	
	motion = n.slide( motion )
	velocity = n.slide( velocity ) #Care about that, it might become strange
	move( motion )


func _collide_bot():
	_additional_collide_bot()
	on_floor = true # Detect floor, useful for jumping
	
	if get_collider().is_in_group( "v_moving_platform" ):
		is_on_v_moving_platform = true
		mp = get_collider()
		set_pos( Vector2( get_pos().x, mp.get_pos().y - character_size.y ) )
	
	# Detect if fell from high place and die if so
	if velocity.y >= VELOCITY_DEATH_CEIL:
		die()


func _additional_collide_bot():
	pass


func _collide_up():
	pass


func _collide_left():
	pass


func _collide_right():
	pass


func _check_if_still_on_platform():
	if get_global_pos().x + character_size.x < mp.get_global_pos().x - mp.left_size\
	or get_global_pos().x > mp.get_global_pos().x + mp.right_size:
		is_on_v_moving_platform = false


######################
# WALKING
######################

func set_walking():
	current_status = status.walking

func is_walking():
	return current_status == status.walking


######################
# KNOCKBACK
######################

func set_kb():
	current_status = status.kb


func is_kb():
	return current_status == status.kb


######################
# IDLE
######################

func set_idle():
	current_status = status.idle


func is_idle():
	return current_status == status.idle