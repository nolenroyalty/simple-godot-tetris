extends Node2D

signal chose_next_piece(piece)
signal held_piece(piece)
signal dropped
signal placed
signal rows_cleared(count)
signal lost_game
signal levelup(level)

const START_X = Constants.BOARD_WIDTH / 2 - 1
const START_Y = -1
const TICKDOWN_TIMER_START = 1.1

var tetrisPiece = preload("res://TetrisPiece.tscn")
onready var landscape = $Landscape
onready var input_timer = $InputTimer
onready var tickdown_timer = $TickdownTimer

var tickdown_timer_amount = TICKDOWN_TIMER_START 
var current_piece
var next_piece
var held_piece
var current_x
var current_y
var ghost

func decrement_tickdown_timer():
	# It might be nice if we increased how long it took to level up every time we decremented this
	if tickdown_timer_amount > 0.2:
		tickdown_timer_amount -= 0.1
		emit_signal("levelup", 1 + int((TICKDOWN_TIMER_START - tickdown_timer_amount) * 10))

func set_piece_position(x, y):
	current_piece.position = Vector2(x * Constants.PIECE_SIZE, y * Constants.PIECE_SIZE)
	current_x = x
	current_y = y
	
func calculate_absolute_positions(x, y, relative_positions):
	var absolute_positions = []
	for pos in relative_positions:
		absolute_positions.append([pos[0] + x, pos[1] + y])
	return absolute_positions

func choose_next_piece():
	next_piece = tetrisPiece.instance()
	next_piece.init(false)
	emit_signal("chose_next_piece", next_piece)

func spawn_current_piece():
	if current_piece:
		current_piece.queue_free()
		
	current_piece = next_piece
	add_child(current_piece)
	set_piece_position(START_X, START_Y)
	if not verify_proposed_coordinates(START_X, START_Y, current_piece.current_positions()):
		emit_signal("lost_game")
	choose_next_piece()

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	choose_next_piece()
	spawn_current_piece()
	tickdown_timer.set_wait_time(tickdown_timer_amount)

func verify_proposed_coordinates(proposed_x, proposed_y, positions):
	for position in calculate_absolute_positions(proposed_x, proposed_y, positions):
		var x = position[0]
		var y = position[1]
		if x < 0 or x >= Constants.BOARD_WIDTH or y >= Constants.BOARD_HEIGHT: return false
		if y < 0:
			# Outside the landscape but legal
			pass
		elif landscape.is_occupied(x, y): return false
	return true

func maybe_clear_rows(rows_to_clear):
	if rows_to_clear:
		landscape.clear_rows(rows_to_clear)
		landscape.render_landscape()
		emit_signal("rows_cleared", len(rows_to_clear))
	
func add_to_landscape():
	var absolute_positions = calculate_absolute_positions(current_x, current_y, current_piece.current_positions())
	var rows_to_clear = landscape.add_to_landscape(absolute_positions, current_piece.color)
	maybe_clear_rows(rows_to_clear)
	landscape.render_landscape()
	emit_signal("placed")

func _on_TickdownTimer_timeout():
	var proposed_y = current_y + 1
	if verify_proposed_coordinates(current_x, proposed_y, current_piece.current_positions()):
		set_piece_position(current_x, proposed_y)
	else:
		# We've ticked down into the landscape
		add_to_landscape()
		spawn_current_piece()

func y_coordinate_for_drop():
	var proposed_y = current_y
	while verify_proposed_coordinates(current_x, proposed_y, current_piece.current_positions()):
		proposed_y += 1
	return proposed_y - 1
	
func perform_drop():
	var proposed_y = y_coordinate_for_drop()
	set_piece_position(current_x, proposed_y)
	add_to_landscape()
	spawn_current_piece()
	emit_signal("dropped")
	
func perform_hold():
	if held_piece == null:
		held_piece = current_piece
		remove_child(current_piece)
		current_piece = null
		spawn_current_piece()
	else:
		var temp_held = held_piece
		held_piece = current_piece
		remove_child(current_piece)
		current_piece = temp_held
		add_child(current_piece)
		set_piece_position(START_X, START_Y)
	
	emit_signal("held_piece", held_piece)
	
func maybe_redisplay_ghost_coordinates():
	var ghost_y = y_coordinate_for_drop()
	if ghost:
		ghost.queue_free()
	
	ghost = tetrisPiece.instance()
	var x = current_piece.position.x
	ghost.position = Vector2(x, ghost_y * Constants.PIECE_SIZE)
	ghost.z_index = -1
	ghost.shape = current_piece.shape
	ghost.rotation_offset = current_piece.rotation_offset
	ghost.render_piece(true)
	add_child(ghost)

func attempt_rotation():
	var proposed_positions = current_piece.positions_if_rotated()
	# If rotation at the current position doesn't work, try moving one to the left or right
	var dx_options = [0, -1, 1]
	if current_piece.shape == current_piece.SHAPES.I:
		dx_options = [0, -1, 1, -2, 2]
		
	for dx in dx_options:
		if verify_proposed_coordinates(current_x + dx, current_y, proposed_positions):
			current_piece.rotate_piece()
			current_piece.render_piece(false)
			set_piece_position(current_x + dx, current_y)
			return true
	return false

func reset_tickdown_timer(amount):	
	if tickdown_timer.time_left <= amount:
		tickdown_timer.start(amount)
		tickdown_timer.set_wait_time(tickdown_timer_amount)

func _process(_delta):
	var proposed_x = current_x
	var proposed_y = current_y
	var attempt_a_move = false
	var down_pressed_so_we_can_add_to_landscape = false
	var performed_an_action = false
	var can_move_piece = input_timer.is_stopped()
	
	if Input.is_action_just_pressed("drop"):
		perform_drop()
		reset_tickdown_timer(1.0)
		return
	
	if Input.is_action_just_pressed("hold_piece"):
		perform_hold()
		reset_tickdown_timer(0.3)
		return	
	
	if Input.is_action_pressed("left") and can_move_piece:
		proposed_x -= 1
		attempt_a_move = true
	if Input.is_action_pressed("right") and can_move_piece:
		proposed_x += 1
		attempt_a_move = true
	if Input.is_action_pressed("down") and can_move_piece:
		proposed_y += 1
		attempt_a_move = true
		down_pressed_so_we_can_add_to_landscape = true
	
	if Input.is_action_just_pressed("rotate"):
		var rotation_succeeded = attempt_rotation()
		if rotation_succeeded: performed_an_action = true
			
	if attempt_a_move:
		input_timer.start()
		if verify_proposed_coordinates(proposed_x, proposed_y, current_piece.current_positions()):
			set_piece_position(proposed_x, proposed_y)
			performed_an_action = true
		elif down_pressed_so_we_can_add_to_landscape:
			add_to_landscape()
			spawn_current_piece()
	
	if performed_an_action:
		reset_tickdown_timer(0.2)
	
	maybe_redisplay_ghost_coordinates()
	
	if Input.is_action_just_pressed("debug_spawn"):
		add_to_landscape()
		spawn_current_piece()
