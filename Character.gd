extends KinematicBody2D

const DIRECTION_RIGHT = 0
const DIRECTION_LEFT = 1


export(int) var GRAVITY = 1000
export(int) var WALK_SPEED = 300
export(float) var ONAIR_TIME_BEFORE_DEATH = 1.5

var onair_time = 0
var velocity = Vector2()
var on_floor = false
var current_direction = DIRECTION_RIGHT

var _walking = true setget set_walking, is_walking

func _ready():
	set_fixed_process( true )

func _fixed_process( delta ):
	
	on_floor = false
	onair_time += delta
	
	velocity.y += delta * GRAVITY
	
	if is_walking():
		if current_direction == DIRECTION_LEFT:
			velocity.x = -WALK_SPEED
		elif current_direction == DIRECTION_RIGHT:
			velocity.x = WALK_SPEED
	else:
		velocity.x = 0
	
	var motion = velocity * delta
	move( motion )
	
	if is_colliding() :
		_handle_kinematic_character_collision( motion )

func die():
	queue_free()

################
# COLLIDING
################

func _handle_kinematic_character_collision( motion ):
	# Used to move properly around obstacles
	var n = get_collision_normal()
	motion = n.slide( motion )
	velocity = n.slide( velocity ) #Care about that, it might become strange
	move( motion )
	
	if n == Vector2(0, -1):
		_collide_bot()
	elif n == Vector2(0, 1):
		_collide_up()
	elif n == Vector2(-1, 0):
		_collide_left()
	elif n == Vector2(1, 0):
		_collide_right()


func _collide_bot():
	on_floor = true # Detect floor, useful for jumping
	
	# Detect if fell from high place and die if so
	if onair_time >= ONAIR_TIME_BEFORE_DEATH:
		die()
	onair_time = 0


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
