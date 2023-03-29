extends Node2D

onready var you_lose = $YouLoseNode

func _ready():
	you_lose.visible = false

func game_lost():
	you_lose.visible = true
	get_tree().paused = true

func _on_TetrisBoard_lost_game(): game_lost()
