extends Node2D

onready var attack_area = get_node("AttackArea")
onready var attack_timer = get_node("AttackTimer")
onready var ap = get_node("AnimationPlayer")

const DIRECTION_RIGHT = 0
const DIRECTION_LEFT = 1
const CHAR_SIZE = 64
const TILE_SIZE = 64

export(int) var GRAVITY = 1000
export(int) var WALK_SPEED = 300
export(int) var JUMP_SPEED = 125
export(int) var MAX_JUMP_SPEED = 650
export(float) var TIME_BETWEEN_ATTACKS = 0.3
export(float) var ONAIR_TIME_BEFORE_DEATH = 1.5

var onair_time = 0
var velocity = Vector2()
var on_floor = false
var current_direction = DIRECTION_RIGHT

var _attacking = false setget set_attacking, is_attacking

func _ready():
	set_fixed_process( true )

func _fixed_process( delta ):
	
	# JUMP
	if Input.is_action_pressed( "jump" ) and  on_floor and velocity.y > -MAX_JUMP_SPEED:
		velocity.y -= JUMP_SPEED
	else:
		on_floor = false
		onair_time += delta
	
	velocity.y += delta * GRAVITY
	
	# ATTACK
	if( not is_attacking() and Input.is_action_pressed( "attack" ) ):
		attack(current_direction)
	# MOVE
	elif( Input.is_action_pressed( "walk_left" ) ):
		current_direction = DIRECTION_LEFT
		velocity.x = -WALK_SPEED
	elif( Input.is_action_pressed( "walk_right" ) ):
		current_direction = DIRECTION_RIGHT
		velocity.x = WALK_SPEED
	else:
		velocity.x = 0
	
	var motion = velocity * delta
	move( motion )
	
	if( is_colliding() ):
#		print(get_collider().get_pos().x, ", ", get_pos().x)
#		if round(get_collider().get_pos().y) ==  round(get_pos().y + CHAR_SIZE/2):
#			# Bot
#			print("bot")
#			on_floor = true
#		if round(get_collision_pos().y) ==  round(get_pos().y - CHAR_SIZE/2):
#			# Top
#			die()
#		if round(get_collider().get_pos().x) == round(get_pos().x + TILE_SIZE/2):
#			# Right
#			print("right")
#			pass
#		if round(get_collider().get_pos().x) == round(get_pos().x - TILE_SIZE/2):
#			# Left
#			print("left")
#			pass
#		
#		print("------------")
		
		# Used to move properly around obstacles
		var n = get_collision_normal()
		motion = n.slide( motion )
		velocity = n.slide( velocity )
		move( motion )
		
		if n == Vector2(0, -1):
			on_floor = true # Detect floor, usefull for jumping
			
			if onair_time >= ONAIR_TIME_BEFORE_DEATH:
				# Fall from too high and die
				die()
			onair_time = 0
		elif n == Vector2(0, 1):
			# Hit his head on the brick wall and die
			die()

#############
# ATTACKING
#############

func set_attacking(boolean):
	_attacking = boolean


func is_attacking():
	return _attacking


func attack(direction):
	set_attacking(true)
	if direction == DIRECTION_LEFT:
		ap.play("attack_left")
	elif direction == DIRECTION_RIGHT:
		ap.play("attack_right")
	ap.connect("finished", self, "set_attacking", [false], CONNECT_ONESHOT)


func die():
	print("Bleuargh - i'm dead")
	get_tree().reload_current_scene()