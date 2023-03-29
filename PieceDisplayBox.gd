extends Node2D
var tetrisPiece = preload("res://TetrisPiece.tscn")
var displayed_piece = null

# If we were more principled we'd do the calculations below based on the height of the box
# But we're not, we're bad and lazy people.

func display_piece(piece):
	if displayed_piece: displayed_piece.queue_free()
	
	displayed_piece = tetrisPiece.instance()
	displayed_piece.shape = piece.shape
	displayed_piece.set_to_most_horizontal_orientation_for_display()
	displayed_piece.render_piece(false)
	
	var xpos = 0
	var ypos = 0
	match displayed_piece.width():
		4: xpos = 4
		3: xpos = 20
		2: xpos = 36
		
	match displayed_piece.height():
		2: ypos = 24
		1: ypos = 48
	
	# xpos and ypos assume that the piece starts at 0, 0 but they often don't	
	xpos -= displayed_piece.leftmost() * Constants.PIECE_SIZE
	ypos -= displayed_piece.upmost() * Constants.PIECE_SIZE
	
	displayed_piece.position = Vector2(xpos, ypos)
	add_child(displayed_piece)
