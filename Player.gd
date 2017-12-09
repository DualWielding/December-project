extends "res://Character.gd"

onready var attack_area = get_node("AttackArea")
onready var attack_timer = get_node("AttackTimer")
onready var ap = get_node("AnimationPlayer")

const CHAR_SIZE = 64
const TILE_SIZE = 64

export(int) var JUMP_SPEED = 125
export(int) var MAX_JUMP_SPEED = 650
export(float) var TIME_BETWEEN_ATTACKS = 0.3

var _attacking = false setget set_attacking, is_attacking
var _jumping = false setget set_jumping, is_jumping

func _ready():
	set_walking(false)
	set_process_input(true)

func _input(event):
	if on_floor and event.is_action_pressed( "jump" ):
		jump()
	
	if event.is_action_released( "jump" ):
		set_jumping(false)
	elif event.is_action_released( "walk_left" ) or event.is_action_released( "walk_right" ):
		set_walking(false)
	
	if not is_attacking() and Input.is_action_pressed( "attack" ):
		attack(current_direction)
	elif Input.is_action_pressed( "walk_left" ) :
		current_direction = DIRECTION_LEFT
		set_walking(true)
	elif Input.is_action_pressed( "walk_right" ):
		current_direction = DIRECTION_RIGHT
		set_walking(true)

func _fixed_process( delta ):
	if is_jumping():
		velocity.y -= JUMP_SPEED
	
	if velocity.y < -MAX_JUMP_SPEED:
		set_jumping(false)

#############
# ATTACKING
#############

func set_attacking(boolean):
	_attacking = boolean


func is_attacking():
	return _attacking


func attack(direction):
	if direction == DIRECTION_LEFT:
		ap.play("attack_left")
	elif direction == DIRECTION_RIGHT:
		ap.play("attack_right")
	set_attacking(true)
	ap.connect("finished", self, "set_attacking", [false], CONNECT_ONESHOT)

#############
# JUMPING
#############

func set_jumping(boolean):
	_jumping = boolean

func is_jumping():
	return _jumping

func jump():
	set_jumping(true)

func die():
	print("Bleuargh - i'm dead")
	get_tree().reload_current_scene()

func _collide_up():
	# Hit his head on the brick wall and die
	die()