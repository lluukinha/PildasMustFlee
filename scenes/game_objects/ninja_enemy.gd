extends CharacterBody2D
class_name NinjaEnemy

signal throwShuriken

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer

@export var isFacingLeft = true

var dealDamage = true

func _ready():
	if !isFacingLeft:
		animated_sprite_2d.scale.x = -1
	timer.timeout.connect(on_timer_timeout)


func on_timer_timeout():
	throwShuriken.emit()
