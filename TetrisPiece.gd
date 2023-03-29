extends Node2D

var rng = RandomNumberGenerator.new()
var singleBlock = preload("res://SingleBlock.tscn")

var shape setget set_shape
var shape_positions : Array
var rotation_offset : int
var color

var current_sprites : Array

enum SHAPES {I, O, L, J, T, S, Z}

var FORCE_PIECE_SHAPE = null

const I_POSITIONS = [
	[[0 , 0], [0 , 1], [0, 2], [0, 3]], # Up 
	[[-2, 1], [-1, 1], [0, 1], [1, 1]],  # Horizontal (more on the left)
	[[0, -1], [0, 0], [0, 1], [0, 2]], # Up
	[[-1, 1], [0 , 1], [1, 1], [2, 1]], # Horizontal (more on the right)
]

const O_POSITIONS = [[[0,0], [1,0], [0,1], [1,1]]]

const L_POSITIONS = [
	[[0, 0], [0, 1], [0, 2], [1, 2]], # Two on the bottom
	[[-1, 1], [-1, 2], [0,1], [1,1]], # Two on the left
	[[0,  0], [1, 0], [1, 1], [1, 2]], # Two on the top
	[[0, 1], [1, 1], [2, 1], [2, 0]], # Two on the right
]

const J_POSITIONS = [
	[[1, 0], [1, 1], [1, 2], [0, 2]], # Two on the bottom
	[[-1, 1], [-1, 0], [0, 1], [1, 1]], # Two on the left
	[[0, 0], [1, 0], [0, 1], [0, 2]], # Two on the top
	[[0, 1], [1, 1], [2, 1], [2, 2]] # Two on the right
]

const T_POSITIONS = [
	[[0, 0], [1, 0], [1, -1], [2, 0]], # Up
	[[1, -1], [1, 0], [2, 0], [1, 1]], # Right
	[[0, 0], [1, 0], [1, 1], [2, 0]],  # Pointing down
	[[1, -1], [1, 0], [0, 0], [1, 1]], # Left
]

const S_POSITIONS = [
	[[1, 0], [2, 0], [0, 1], [1, 1]], # Horizontal
	[[0, -1], [0, 0], [1, 0], [1, 1]] # Vertical
]

const Z_POSITIONS = [
	[[0, 0], [1, 0], [1, 1], [2, 1]], # Horizontal
	[[0, 0], [1, 0], [1, -1], [0, 1]] # Vertical
]

func positions_for_shape(shape):
	match shape:
		SHAPES.I: return I_POSITIONS
		SHAPES.O: return O_POSITIONS
		SHAPES.L: return L_POSITIONS
		SHAPES.J: return J_POSITIONS
		SHAPES.T: return T_POSITIONS
		SHAPES.S: return S_POSITIONS
		SHAPES.Z: return Z_POSITIONS

func color_for_shape(shape):
	match shape:
		SHAPES.I: return Constants.COLOR.LIGHTBLUE
		SHAPES.O: return Constants.COLOR.YELLOW
		SHAPES.L: return Constants.COLOR.ORANGE
		SHAPES.J: return Constants.COLOR.BLUE
		SHAPES.T: return Constants.COLOR.PURPLE
		SHAPES.S: return Constants.COLOR.RED
		SHAPES.Z: return Constants.COLOR.GREEN

func most_horizontal_orientation():
	match shape:
		SHAPES.I: return 3
		SHAPES.O: return 0
		SHAPES.L: return 3
		SHAPES.J: return 1
		SHAPES.T: return 2
		SHAPES.S: return 0
		SHAPES.Z: return 0



func set_to_most_horizontal_orientation_for_display():
	rotation_offset = most_horizontal_orientation()

func rotate_piece():
	rotation_offset = (rotation_offset + 1) % shape_positions.size()
	
func positions_if_rotated():
	return shape_positions[(rotation_offset + 1) % shape_positions.size()]

func current_positions():
	return shape_positions[rotation_offset]	

# Dimensions, least, etc are just for centering the piece. There's a little duplication but
# it'd be annoying to refactor and doesn't seem worth it.
func calculate_dimension(index):
	var positions = current_positions()
	var dmin = positions[0][index]
	var dmax = positions[0][index]
	for position in positions:
		dmin = min(dmin, position[index])
		dmax = max(dmax, position[index])
	return dmax - dmin + 1

func width():
	return calculate_dimension(0)
	
func height():
	return calculate_dimension(1)

func calc_least(index):
	var positions = current_positions()
	var least = positions[0][index]
	for position in positions: least = min(least, position[index])
	return least

func leftmost(): return calc_least(0)
func upmost(): return calc_least(1)

func clear_piece():
	for piece in current_sprites:
		piece.queue_free()
	current_sprites = []

func render_piece(as_ghost):
	clear_piece()
	for point in current_positions():
		var block = singleBlock.instance()
		var x = point[0] * Constants.PIECE_SIZE
		var y = point[1] * Constants.PIECE_SIZE
		block.position = Vector2(x, y)
		block.init(color, as_ghost)
		add_child(block)
		current_sprites.append(block)

func set_shape(shape_to_set):
	shape = shape_to_set
	color = color_for_shape(shape)
	shape_positions = positions_for_shape(shape)
	rotation_offset = rng.randi_range(0, shape_positions.size() - 1)

func randomize_piece():
	# Doing this in _ready doesn't seem to work because _ready isn't
	# called when this is called???
	rng.randomize()
	if FORCE_PIECE_SHAPE != null:
		print("forcing piece shape %d" % FORCE_PIECE_SHAPE)
		shape = FORCE_PIECE_SHAPE
	else:
		shape = SHAPES.values()[rng.randi_range(0, SHAPES.size() - 1)]
	set_shape(shape)

func init(as_ghost):
	randomize_piece()
	render_piece(as_ghost)
