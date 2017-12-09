extends Camera2D

export(int) var SCREEN_PORTION_ADVANCEMENT = 300
var _screen_portion
var _third_of_screen

func _ready():
	_screen_portion =  OS.get_window_size().x / SCREEN_PORTION_ADVANCEMENT
	_third_of_screen = OS.get_window_size() / 3
	set_process(true)

func _process(delta):
	if get_parent().is_walking():
		if get_parent().current_direction == get_parent().DIRECTION_LEFT and get_offset().x > -_third_of_screen.x:
				set_offset( Vector2( get_offset().x - _screen_portion, 0 ) )
		
		if get_parent().current_direction == get_parent().DIRECTION_RIGHT and get_offset().x < _third_of_screen.x:
				set_offset( Vector2( get_offset().x + _screen_portion, 0 ) )