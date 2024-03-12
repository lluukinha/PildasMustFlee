extends CharacterBody2D
class_name Lever

signal pull

@onready var sprite_2d: Sprite2D = $Sprite2D

var isPulled = false
var dealDamage = false

func pull_lever():
	sprite_2d.scale.y = -1
	isPulled = true
	pull.emit()
