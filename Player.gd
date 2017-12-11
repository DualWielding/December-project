extends "res://Character.gd"

onready var holding_container = get_node( "HoldingContainer" )
onready var attack_area = get_node( "AttackArea" )
onready var pu_area = get_node( "PickUpArea" )
onready var ap = get_node( "AnimationPlayer" )

const CHAR_SIZE = 64
const TILE_SIZE = 64

export( int ) var JUMP_SPEED = 75
export( int ) var MAX_JUMP_SPEED = 450
export( float ) var TIME_BETWEEN_ATTACKS = 0.3

var _attacking = false setget set_attacking, is_attacking
var _jumping = false setget set_jumping, is_jumping

var holding = null
var can_move = true


func _ready():
	set_walking( false )
	set_process_input( true )


func _input( event ):
	if not is_attacking() and event.is_action_pressed( "pick_up" ):
		pick_up()
	elif on_floor and can_move and event.is_action_pressed( "jump" ):
		jump()
	elif event.is_action_released( "jump" ):
		set_jumping( false )
	elif not is_attacking() and Input.is_action_pressed( "attack" ):
		attack( current_direction )
	
	if Input.is_action_pressed( "walk_left" ) :
		current_direction = DIRECTION_LEFT
		set_walking( true )
	elif Input.is_action_pressed( "walk_right" ):
		current_direction = DIRECTION_RIGHT
		set_walking( true )
	else:
		set_walking( false )


func _fixed_process( delta ):
	
	if is_jumping() and Input.is_action_pressed( "jump" ):
		if velocity.y > -MAX_JUMP_SPEED:
			velocity.y -= JUMP_SPEED
		else:
			set_jumping( false )


func _collide_bot():
	set_jumping( false )
	on_floor = true # Detect floor, useful for jumping
	
	# Detect if fell from high place and die if so
	if velocity.y >= VELOCITY_DEATH_CEIL:
		die()

func _collide_up():
	# Hit his head on the brick wall and die
	die()


func die():
	print( "Bleuargh - i'm dead" )
	get_tree().reload_current_scene()


#############
# ATTACKING
#############

func set_attacking(boolean):
	_attacking = boolean


func is_attacking():
	return _attacking


func attack( direction ):
	
	if holding != null:
		throw()
		return
	
	if direction == DIRECTION_LEFT:
		ap.play( "attack_left" )
	elif direction == DIRECTION_RIGHT:
		ap.play( "attack_right" )
	set_attacking( true )
	ap.connect( "finished", self, "set_attacking", [false], CONNECT_ONESHOT )


func _on_AttackArea_body_enter( body ):
	body.gets_hit( self )


func throw():
	var item = holding_container.get_children()[0]
	holding_container.remove_child( item )
	Player.current_level.add_item( item, get_pos() + holding_container.get_pos() )
	item.threw_to( Vector2( current_direction, 0 ) )
	holding = null


#############
# JUMPING
#############

func set_jumping( boolean ):
	_jumping = boolean


func is_jumping():
	return _jumping


func jump():
	set_jumping( true )
	velocity.y -= JUMP_SPEED


############
# PICKING UP
############

func pick_up():
	var areas = pu_area.get_overlapping_areas()
	
	if areas.size() == 0:
		return
	
	can_move = false
	
	for area in areas:
		var body = area.get_parent()
		if body.is_in_group( "item" ):
			body.get_parent().remove_child( body )
			hold( body )
			break
	
	can_move = true


func hold( item ):
	holding = item
	for child in holding_container.get_children():
		child.queue_free()
	holding_container.add_child( item )
	
	# Must change its pos, relative to the holding container node
	item.set_pos( Vector2( 0, 0 ) )
	
	# Must change its collision layer and mask
	item.configure_for_holding()


#############
# COLLECTING
#############

func _on_CollectibleArea_area_enter( area ):
	collect( area.get_parent() )

func collect( collectible ):
	if collectible.is_in_group( "coin" ):
		Player.update_coins( 1 )
		collectible.queue_free()