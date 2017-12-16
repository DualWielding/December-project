extends Node2D

onready var ap = get_node( "AnimationPlayer" )
onready var timer = get_node( "LaserTimer" )

export( float ) var LASER_ANIMATION_SPEED = 0.7
export( float ) var LASER_DURATION = 0.4

var _animation

func _ready():
	timer.set_one_shot( true )
	timer.set_wait_time( LASER_DURATION )

func activate( direction ):
	get_parent().set_disabled()
	
	# If re-activated, reset the time
	if timer.is_processing():
		timer.stop()
		timer.start()
	else:
		var name
		if direction == Directions.right:
			name = "shoot_right"
		else:
			name = "shoot_left"
		ap.play( name )
		ap.connect( "finished", timer, "start", [], CONNECT_ONESHOT )
		timer.connect( "timeout", self, "desactivate", [name], CONNECT_ONESHOT )

func desactivate( animation_name ):
	ap.play_backwards( animation_name )
	ap.connect( "finished", get_parent(), "set_idle" )

func _on_Area2D_body_enter( body ):
	if body.is_in_group( "enemy" ):
		body.die()
	if body.is_in_group( "bullet" ):
		body.queue_free()