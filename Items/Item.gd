extends Sprite

onready var a2d = get_node( "Area2D" )

export(int) var FLYING_SPEED = 600

var flying = false
var direction = Vector2( 0, 0 )

func _ready():
	add_to_group( "item" )
	set_process( true )

func _process( delta ):
	if flying:
		set_pos( Vector2( get_pos().x + FLYING_SPEED * delta * direction.x, get_pos().y ) )
		set_rot( get_rot() - 0.15 )

func configure_for_holding():
	a2d.set_collision_mask_bit( 3,false )
	a2d.set_layer_mask_bit( 3, false )

func configure_for_hitting_ennemies():
	a2d.set_collision_mask_bit( 1, true )
	a2d.set_layer_mask_bit( 1, true )

func threw_to( direction ):
	configure_for_hitting_ennemies()
	self.direction = direction
	flying = true

func _on_Area2D_body_enter( body ):
	body.gets_hit( self )
	queue_free()