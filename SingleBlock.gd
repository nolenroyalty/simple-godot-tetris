extends Node2D

var blue = preload("res://Images/Single Blocks/Blue.png")
var green = preload("res://Images/Single Blocks/Green.png")
var lightblue = preload("res://Images/Single Blocks/LightBlue.png")
var orange = preload("res://Images/Single Blocks/Orange.png")
var purple = preload("res://Images/Single Blocks/Purple.png")
var red  = preload("res://Images/Single Blocks/Red.png")
var yellow = preload("res://Images/Single Blocks/Yellow.png")
var ghost = preload("res://Images/Ghost Blocks/Single.png")

func init(color, overlay_ghost):
	var textures = []
	match color:
		Constants.COLOR.BLUE: textures.append(blue)
		Constants.COLOR.GREEN: textures.append(green)
		Constants.COLOR.LIGHTBLUE: textures.append(lightblue)
		Constants.COLOR.ORANGE: textures.append(orange)
		Constants.COLOR.PURPLE: textures.append(purple)
		Constants.COLOR.RED: textures.append(red)
		Constants.COLOR.YELLOW: textures.append(yellow)
		
	if overlay_ghost: textures.append(ghost)
	
	for texture in textures:
		var sprite : Sprite = Sprite.new()
		sprite.centered = false
		sprite.position.x = 0
		sprite.position.y = 0
		sprite.scale = Vector2(0.5, 0.5)
		sprite.set_texture(texture)
		add_child(sprite)
