extends KinematicBody2D

const DIRECTION_RIGHT = 1
const DIRECTION_LEFT = -1


export(int) var GRAVITY = 1000
export(int) var WALK_SPEED = 300
export(Vector2) var HIT_KNOCKBACK = Vector2(800, -500)
export(int) var VELOCITY_DEATH_CEIL = 900

var velocity = Vector2()
var on_floor = false
var current_direction = DIRECTION_RIGHT

var _walking = true setget set_walking, is_walking

func _ready():
	add_to_group( "character" )
	set_fixed_process( true )

func _fixed_process( delta ):
	
	on_floor = false
	
	velocity.y += delta * GRAVITY
	
	if is_walking():
		if current_direction == DIRECTION_LEFT:
			if velocity.x > -WALK_SPEED * 1.1 and velocity.x < -WALK_SPEED * 0.9:
				velocity.x = -WALK_SPEED
			elif velocity.x < -WALK_SPEED * 1.1:
				velocity.x -= -WALK_SPEED * 0.1
			else:
				velocity.x += -WALK_SPEED * 0.1 
		elif current_direction == DIRECTION_RIGHT:
			if velocity.x < WALK_SPEED * 1.1 and velocity.x > WALK_SPEED * 0.9:
				velocity.x = WALK_SPEED
			elif velocity.x > WALK_SPEED * 1.1:
				velocity.x -= WALK_SPEED * 0.1
			else:
				velocity.x += WALK_SPEED * 0.1 
	else:
		velocity.x = 0
	
	var motion = velocity * delta
	move( motion )
	
	if is_colliding() :
		var collider = get_collider()
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
	on_floor = true # Detect floor, useful for jumping
	
	# Detect if fell from high place and die if so
	if velocity.y >= VELOCITY_DEATH_CEIL:
		die()


func _collide_up():
	pass


func _collide_left():
	pass


func _collide_right():
	pass


######################
# WALKING
######################


func set_walking(boolean):
	_walking = boolean

func is_walking():
	return _walking
