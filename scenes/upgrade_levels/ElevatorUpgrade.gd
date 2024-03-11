extends Node2D


@onready var injection_animation: AnimationPlayer = $InjectionAnimation
@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var scientist_sprite: AnimatedSprite2D = $ScientistSprite
@onready var injection: Node2D = $Injection


func _ready():
	injection.visible = false
	startAnimation()
	

func startAnimation():
	await get_tree().create_timer(2).timeout
	scientist_sprite.play("side")
	await get_tree().create_timer(.5).timeout
	player_sprite.play("back")
	await get_tree().create_timer(1).timeout
	injection_animation.play("apply")
	await get_tree().create_timer(1.5).timeout
	injection_animation.play_backwards("apply")
	await get_tree().create_timer(1.2).timeout
	injection.visible = false
	player_sprite.play("default")
	await get_tree().create_timer(.5).timeout
	scientist_sprite.play("default")
	
