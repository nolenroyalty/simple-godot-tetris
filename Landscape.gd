extends Node2D

var singleBlock = preload("res://SingleBlock.tscn")
var points = []
var rendered_pieces = []

func init_points():
	# Someday we could store null / sprite here instead
	for _y in range(Constants.BOARD_HEIGHT):
		var row = []
		for _x in range(Constants.BOARD_WIDTH):
			row.append(null)
		points.append(row)

func maybe_signal_full_rows(impacted_rows):
	var full_rows = []

func add_to_landscape(new_points, color):
	var impacted_rows = {}
	var full_rows = []
	
	for point in new_points:
		var x = point[0]
		var y = point[1]
		assert(x < Constants.BOARD_WIDTH, new_points)
		assert(x >= 0, new_points)
		assert(y < Constants.BOARD_HEIGHT, new_points)
		points[y][x] = color
		impacted_rows[y] = true
	
	for row in impacted_rows:
		var full = true
		for cell in points[row]:
			if not cell:
				full = false
				break
		if full:
			full_rows.append(row)
	
	return full_rows
	
func is_occupied(x, y):
	return points[y][x]

func _clear_row(index):
	# I think this is doing a bunch of copying that is maybe inefficient in godot (idk)
	# but surely it doesn't matter here
	var rows_above = []
	if index != 0:
		rows_above = points.slice(0, index - 1)
	var rows_below = points.slice(index + 1, Constants.BOARD_HEIGHT - 1)
	var new_row = []
	for _x in range(Constants.BOARD_WIDTH):
		new_row.append(null)
	var new_points = [new_row]
	new_points += rows_above
	new_points += rows_below
	points = new_points
	
func clear_rows(rows):
	# We sort the rows because our (lazy!) row-clearing logic won't work if we clear a
	# "higher" row sooner (e.g. clearing 19 before 18) - because after clearing row 19,
	# row 18 *becomes* row 19.
	rows.sort()
	for row in rows: _clear_row(row)

func current_points():
	var ret = []
	var y = 0
	for row in points:
		var x = 0
		for cell in points[y]:
			if cell != null:
				 ret.append([x, y, cell])
			x += 1
		y += 1
	return ret

func render_landscape():
	for piece in rendered_pieces:
		piece.queue_free()
	
	rendered_pieces = []
	
	for point in current_points():
		# If we care and it matters we could track which pieces we've
		# already rendered and not render those, but I really doubt that
		# that matters for this game?
		var block = singleBlock.instance()
		var x = point[0] * Constants.PIECE_SIZE
		var y = point[1] * Constants.PIECE_SIZE
		var color = point[2]
		block.position = Vector2(x, y)
		block.init(color, false)
		add_child(block)
		rendered_pieces.append(block)
	
func _ready():
	init_points()

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
