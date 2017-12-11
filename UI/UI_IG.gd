extends CanvasLayer

onready var coins_number = get_node( "CoinsNumber" )
onready var death_screen = get_node( "DeathScreen" )

var _window_size

func _ready():
	Player.ui = self
	
	_window_size = OS.get_window_size()
	
	Player.connect( "coins_updated", self, "update_coins" )
	update_coins( Player.coins )
	
	# DEATH SCREEN
	death_screen.hide()
	death_screen.set_size( _window_size )
	death_screen.get_node( "Quit" ).set_pos( Vector2( _window_size.x/3, _window_size.y/10 * 9 ) )
	death_screen.get_node( "Retry" ).set_pos( Vector2( _window_size.x/3 * 2, _window_size.y/10 * 9 ) )


##########################
# COINS
##########################

func update_coins( current_amount ):
	coins_number.set_text( str( "Coins: ", current_amount ) )
	

###########################
# DEATH
###########################

func show_death_screen():
	get_tree().set_pause( true )
	death_screen.show()


func _on_Quit_pressed():
	get_tree().quit()


func _on_Retry_pressed():
	for coin in range(Player.LIFE_COST):
		Player.update_coins( - 1 )
	
	get_tree().set_pause( false )
	
	get_tree().reload_current_scene()