extends Label

func set_level(level):
	text = "Level: %d" % level

func _ready():
	text = "Level: 1"

func _on_TetrisBoard_levelup(level):
	set_level(level)
