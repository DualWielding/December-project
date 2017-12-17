extends "res://Character.gd"

onready var sprite = get_node ( "Sprite" )
onready var life_aura = get_node( "LifeAura" )
onready var frenzy_aura = get_node( "FrenzyAura" )
onready var weapon_laser = get_node( "WeaponLaser" )
onready var weapon_gun = get_node( "WeaponGun" )
onready var holding_container = get_node( "HoldingContainer" )
onready var attack_area = get_node( "AttackArea" )
onready var pu_area = get_node( "PickUpArea" )
onready var atck_p = get_node( "AttackPlayer" )
onready var ap = get_node( "AnimationPlayer" )
onready var invul_timer = get_node( "InvulnerabilityTimer" )
onready var gun_timer = get_node( "GunTimer" )
onready var laser = get_node( "Laser" )

export( int ) var JUMP_SPEED = 75
export( int ) var MAX_JUMP_SPEED = 450
export( float ) var ATTACK_ANIMATION_SPEED = 1.0
export( float ) var INVULNERABILITY_TIME_ON_ATTACK = 0.3
export( float ) var FRENZY_KB_MOLTIPLICATOR = 2.5
export( float ) var GUN_TIME_BETWEEN_BULLETS = 0.6
export( int ) var GUN_BULLETS_NUMBER = 1

var _attacking = false setget set_attacking, is_attacking
var _jumping = false setget set_jumping, is_jumping
var _invulnerable = false setget set_invulnerability, is_invulnerable
var _frenzy = false setget set_frenzy, get_frenzy
var _extra_life = false setget set_extra_life, get_extra_life

var holding = null
var bullets_left = 0


func _ready():
	add_to_group( "player" )
	
	Player.character = self
	
	Player.connect( "power_up_gained", self, "show_power_up" )
	invul_timer.connect( "timeout", self, "set_invulnerability", [false] )
	gun_timer.connect( "timeout", self, "shoot" )
	gun_timer.set_wait_time( GUN_TIME_BETWEEN_BULLETS )
	
	set_idle()
	set_process_input( true )
	
	if Player.checkpoint != null:
		set_pos( Player.checkpoint )


func _input( event ):
	if is_disabled():
		return
	
	if event.is_action_released( "jump" ):
		set_jumping( false )
	elif not is_attacking() and event.is_action_pressed( "attack_left" ):
		attack_left()
	elif not is_attacking() and event.is_action_pressed( "attack_right" ):
		attack_right()
	elif event.is_action_pressed( "use" ) and not is_attacking():
		if not pick_up() and not activate_checkpoint():
			use_item()
	elif event.is_action_pressed( "use_power" ):
		use_power_up()


func _fixed_process( delta ):
	if is_disabled():
		return
	
	elif (is_on_v_moving_platform or on_floor) and can_move and Input.is_action_pressed( "jump" ):
		if current_direction == Directions.right:
			jump_right()
		else:
			jump_left()
	
	if Input.is_action_pressed( "walk_left" ):
		if not is_walking() or current_direction != Directions.left or not ap.is_playing():
			set_walking_left()
	elif Input.is_action_pressed( "walk_right" ):
		if not is_walking() or current_direction != Directions.right or not ap.is_playing():
			set_walking_right()
	else:
		set_idle()
		ap.stop_all()
		if not on_floor:
			sprite.set_frame( 14 )
		else:
			sprite.set_frame( 11 )
		
	
	if is_jumping() and Input.is_action_pressed( "jump" ):
		if velocity.y > -MAX_JUMP_SPEED:
			velocity.y -= JUMP_SPEED
		else:
			set_jumping( false )

func _additional_general_collision_behaviour():
	if get_collider().is_in_group( "enemy" ) or get_collider().is_in_group( "bullet" ):
		die()


func _collide_up():
	# Hit his head on the brick wall and die
	sprite.get_node( "Sprite" ).show() #Blood
	die()


func die():
	if not is_invulnerable():
		if get_extra_life():
			set_extra_life( false )
		else:
			if current_direction == Directions.right:
				ap.play( "die_right" )
			else:
				ap.play( "die_left" )
			set_invulnerability( true )
			set_disabled()
			ap.connect( "finished", Player.ui, "show_death_screen" )

#############
# WALKING
#############

func set_walking_right():
	current_direction = Directions.right
	if on_floor:
		ap.play( "run_right" )
	else:
		sprite.set_flip_h( false )
	set_walking()

func set_walking_left():
	current_direction = Directions.left
	if on_floor:
		ap.play( "run_left" )
	else:
		sprite.set_flip_h( true )
	set_walking()


#############
# ATTACKING
#############

func set_attacking(boolean):
	_attacking = boolean


func is_attacking():
	return _attacking

func attack_left():
	if holding != null:
		throw( Directions.left )
		return
	attack( "attack_left" )

func attack_right():
	if holding != null:
		throw( Directions.right )
		return
	attack( "attack_right" )


func attack( animation_name ):
	atck_p.play( animation_name, -1, ATTACK_ANIMATION_SPEED )
	set_attacking( true )
	atck_p.connect( "finished", self, "set_attacking", [false], CONNECT_ONESHOT )


func _on_AttackArea_body_enter( body ):
	if body.is_in_group( "enemy" ):
		if get_frenzy():
			body.gets_hit( self, FRENZY_KB_MOLTIPLICATOR )
			set_frenzy( false )
		else:
			body.gets_hit( self, 1.0 )
		set_invulnerability( true, INVULNERABILITY_TIME_ON_ATTACK )
	elif body.is_in_group( "bullet" ):
		body.change_direction()


func throw( direction ):
	var item = holding_container.get_children()[0]
	holding_container.remove_child( item )
	Player.current_level.add_item( item, get_pos() + holding_container.get_pos() )
	item.threw_to( Vector2( direction, 0 ) )
	holding = null


#############
# JUMPING
#############

func set_jumping( boolean ):
	_jumping = boolean


func is_jumping():
	return _jumping


func jump_right():
	ap.stop()
	ap.play( "jump_right" )
	jump()


func jump_left():
	ap.stop()
	ap.play( "jump_left" )
	jump()


func jump():
	is_on_v_moving_platform = false
	set_jumping( true )
	velocity.y -= JUMP_SPEED


############
# PICKING UP
############

func pick_up():
	var bodies = pu_area.get_overlapping_bodies()
	
	if bodies.size() == 0:
		return false
	
	can_move = false
	
	for body in bodies:
		if body.is_in_group( "item" ):
			body.get_parent().remove_child( body )
			hold( body )
			break
		return false
	
	can_move = true
	return true


func hold( item ):
	holding = item
	for child in holding_container.get_children():
		child.queue_free()
	holding_container.add_child( item )
	
	# Must change its pos, relative to the holding container node
	item.set_pos( Vector2( 0, 0 ) )
	
	# Must change its collision layer and mask
	item.configure_for_holding()


func has_item():
	return holding != null

#############
# COLLECTING
#############

func _on_CollectibleArea_area_enter( area ):
	collect( area.get_parent() )


func collect( collectible ):
	if collectible.is_in_group( "coin" ):
		Player.update_coins( 1 )
		collectible.queue_free()


#############
# USING
#############

func use_item():
	if has_item():
		var item = holding_container.get_children()[0]
		if item.use():
			holding_container.remove_child( item )
			item.queue_free()
			holding = null


#############
# POWER UPS
#############

func set_invulnerability( boolean, time=0.0 ):
	if not boolean:
		_invulnerable = false
	else:
		_invulnerable = true
		invul_timer.set_wait_time( time )
		invul_timer.start()


func is_invulnerable():
	return _invulnerable


func get_random_power_up():
	Player.rand_power_up()


func use_power_up():
	if Player.get_power_up() == Player.power_ups.laser:
		laser.activate( current_direction )
	elif Player.get_power_up() == Player.power_ups.gun:
		bullets_left = GUN_BULLETS_NUMBER
		shoot()
		gun_timer.start()
	elif Player.get_power_up() == Player.power_ups.life:
		set_extra_life( true )
	elif Player.get_power_up() == Player.power_ups.frenzy:
		set_frenzy( true )
	Player.set_power_up( Player.power_ups.none )


func show_power_up( pu ):
	weapon_laser.hide()
	weapon_gun.hide()
	
	if pu == Player.power_ups.laser:
		weapon_laser.show()
	elif pu == Player.power_ups.gun:
		weapon_gun.show()

# Frenzy

func set_frenzy( boolean ):
	_frenzy = boolean
	if _frenzy:
		frenzy_aura.show()
	else:
		frenzy_aura.hide()


func get_frenzy():
	return _frenzy


# Extra life

func set_extra_life( boolean ):
	_extra_life = boolean
	if _extra_life:
		life_aura.show()
	else: 
		life_aura.hide()

func get_extra_life():
	return _extra_life


# Gun

func shoot():
	if bullets_left == 0:
		gun_timer.stop()
		return
	
	bullets_left -= 1
	
	pop_bullet() # In character


#############
# SAVING
#############


func activate_checkpoint():
	var areas = pu_area.get_overlapping_areas()
	
	for area in areas:
		if area.is_in_group( "checkpoint" ):
			return area.activate()
	
	return false