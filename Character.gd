extends Node2D

const CHAR_SIZE = 32
const TILE_SIZE = 32
const GRAVITY = 1000
const WALK_SPEED = 300
const MAX_JUMP_SPEED = 650
const JUMP_SPEED = 125
const MIN_ONAIR_TIME = 0.1

var velocity = Vector2()
var on_floor = false

func _ready():
	set_fixed_process( true )

func _fixed_process( delta ):
	
	if Input.is_action_pressed( "ui_up" ) and  on_floor and velocity.y > -MAX_JUMP_SPEED:
		velocity.y -= JUMP_SPEED
	else:
		on_floor = false
	
	velocity.y += delta * GRAVITY
	
	if( Input.is_action_pressed( "ui_left" ) ):
		velocity.x = -WALK_SPEED
	elif( Input.is_action_pressed( "ui_right" ) ):
		velocity.x = WALK_SPEED
	else:
		velocity.x = 0
	
	var motion = velocity * delta
	move( motion )
	
	if( is_colliding() ):
#		print(get_collider().get_pos().x, ", ", get_pos().x)
#		if round(get_collider().get_pos().y) ==  round(get_pos().y + CHAR_SIZE):
#			# Bot
#			print("bot")
#			on_floor = true
#		if round(get_collision_pos().y) ==  round(get_pos().y - CHAR_SIZE):
#			# Top
#			die()
#		if round(get_collider().get_pos().x) == round(get_pos().x + TILE_SIZE):
#			# Right
#			print("right")
#			pass
#		if round(get_collider().get_pos().x) == round(get_pos().x - TILE_SIZE):
#			# Left
#			print("left")
#			pass
#		
#		print("------------")
		
		var n = get_collision_normal()
		motion = n.slide( motion )
		velocity = n.slide( velocity )
		move( motion )
		
		if n == Vector2(0, -1):
				on_floor = true
		elif n == Vector2(0, 1):
			die()

func die():
	print("Bleuargh - i'm dead")
	get_tree().reload_current_scene()