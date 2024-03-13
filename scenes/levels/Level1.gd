extends Node2D

@onready var ninja_enemy_bottom: NinjaEnemy = %NinjaEnemyBottom
@onready var ninja_enemy_top: NinjaEnemy = %NinjaEnemyTop
@onready var player: Player = $Foreground/Player
@onready var lift: Lift = $Scenario/Lift
@onready var lever: Lever = $Foreground/Lever

const SHURIKEN_SCENE = preload("res://scenes/game_objects/shuriken.tscn")
const FLOOR_CLEAR_SCENE = preload("res://scenes/ui/floor_clear.tscn")
const FULL_SCREEN_TEXT_UI_SCENE = preload("res://scenes/ui/full_screen_text_ui.tscn")

var levelClear = false

func _ready():
	ninja_enemy_bottom.throwShuriken.connect(throwShuriken.bind(ninja_enemy_bottom))
	ninja_enemy_top.throwShuriken.connect(throwShuriken.bind(ninja_enemy_top))
	lever.pull.connect(onPullLever)

	player.visible = false
	player.canMove = false
	get_tree().call_group("enemy", "stopMovement")
	
	var start_text_instance = FULL_SCREEN_TEXT_UI_SCENE.instantiate() as FullScreenTextUI
	start_text_instance.labelText = "Pull the lever!"
	add_child(start_text_instance)
	start_text_instance.start.connect(on_start_level)

	player.died.connect(on_player_died)
	lift.level_up.connect(on_level_up)

func goToNextLevel():
	ScreenTransition.transition_to_scene("res://scenes/upgrade_levels/ElevatorUpgrade.tscn")

func on_level_up():
	var tween = create_tween()
	var targetPositionY = global_position.y + 1200
	tween.tween_method(level_tween_method, global_position.y, targetPositionY, 1)
	tween.tween_callback(goToNextLevel)


func level_tween_method(newPositionY: float):
	global_position.y = newPositionY


func on_player_died():
	var player_died_text_instance = FULL_SCREEN_TEXT_UI_SCENE.instantiate() as FullScreenTextUI
	player_died_text_instance.labelText = "You got caught!"
	player_died_text_instance.pressKeylabelText = "Press [space] to restart level!"
	add_child(player_died_text_instance)
	player_died_text_instance.start.connect(on_restart)


func on_restart():
	get_tree().reload_current_scene()


func on_start_level():
	lift.open(false)
	await get_tree().create_timer(.4).timeout
	player.visible = true
	player.canMove = true
	
	
	lift.close()
	await get_tree().create_timer(.5).timeout
	
	get_tree().call_group("enemy", "startMovement")
	
	player.isTransformed = true


func throwShuriken(parentNode: NinjaEnemy):
	if levelClear:
		return
	var shuriken_instance = SHURIKEN_SCENE.instantiate()
	get_tree().get_first_node_in_group("entities_layer").add_child(shuriken_instance)
	shuriken_instance.global_position = parentNode.global_position
	shootShuriken(shuriken_instance, parentNode.isFacingLeft)
	

func shootShuriken(shuriken: Shuriken, isFacingLeft: bool):
	var tween = create_tween()
	var targetPositionX = shuriken.global_position.x - 1200 if isFacingLeft else shuriken.global_position.x + 1200
	
	tween.tween_method(tween_method.bind(shuriken), shuriken.global_position.x, targetPositionX, 2)
	tween.tween_callback(shuriken.queue_free)


func tween_method(newPositionX: float, shuriken: Shuriken):
	shuriken.global_position.x = newPositionX


func onPullLever():
	if !levelClear:
		finish()


func finish():
	await get_tree().create_timer(.5).timeout
	levelClear = true
	var floor_clear_instance = FLOOR_CLEAR_SCENE.instantiate()
	get_tree().get_first_node_in_group("foreground_layer").add_child(floor_clear_instance)
	await get_tree().create_timer(2.0).timeout

	lift.open(true)
