extends Area2D

func _on_PatrolEndpoint_body_enter( body ):
	if body.is_in_group( "enemy" ):
		body.turn()