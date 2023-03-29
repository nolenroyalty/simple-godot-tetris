extends Label

var rows_cleared = 0

func increment_rows_cleared(count):
	rows_cleared += count
	text = "Score: %d" % rows_cleared

func _ready():
	text = "Score: 0"
