extends CanvasLayer

onready var coins_number = get_node( "CoinsNumber" )

func _ready():
	Player.connect( "coins_updated", self, "update_coins" )
	update_coins( Player.coins )

func update_coins( current_amount ):
	coins_number.set_text( str( "Coins: ", current_amount ) )