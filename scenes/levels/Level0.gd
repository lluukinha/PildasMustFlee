extends Node2D

@onready var lift: Lift = %Lift
@onready var time_counter: TimeCounter = $TimeCounter
@onready var camera_animation: AnimationPlayer = $CameraAnimation
@onready var player = $Foreground/Player

const floor_clear_scene = preload("res://scenes/ui/floor_clear.tscn")
const full_screen_text_ui_scene = preload("res://scenes/ui/full_screen_text_ui.tscn")


func _ready():
	player.visible = false
	player.canMove = false
	get_tree().call_group("enemy", "stopMovement")
	
	var powerUpsCount = GameEvents.playerPowerUps.size()
	if powerUpsCount < 2:
		%BasicEnemy3.queue_free()
		%BasicEnemy4.queue_free()
	
	var start_text_instance = full_screen_text_ui_scene.instantiate() as FullScreenTextUI
	start_text_instance.labelText = "Survive for 10 seconds!"
	add_child(start_text_instance)
	start_text_instance.start.connect(on_start_level)

	time_counter.timeout.connect(on_counter_timeout)
	player.died.connect(on_player_died)
	lift.level_up.connect(on_level_up)


func on_level_up():
	camera_animation.play("lift_up")
	await get_tree().create_timer(1).timeout
	ScreenTransition.transition_to_scene("res://scenes/upgrade_levels/ElevatorUpgrade.tscn")


func on_player_died():
	var player_died_text_instance = full_screen_text_ui_scene.instantiate() as FullScreenTextUI
	player_died_text_instance.labelText = "You got caught!"
	player_died_text_instance.pressKeylabelText = "Press [space] to restart level!"
	add_child(player_died_text_instance)
	player_died_text_instance.start.connect(on_restart)


func on_restart():
	get_tree().reload_current_scene()


func finish():
	await get_tree().create_timer(.5).timeout
	
	var floor_clear_instance = floor_clear_scene.instantiate()
	get_tree().get_first_node_in_group("foreground_layer").add_child(floor_clear_instance)
	await get_tree().create_timer(2.0).timeout

	lift.open(true)


func on_start_level():
	lift.open(false)
	await get_tree().create_timer(.4).timeout
	player.visible = true
	player.canMove = true
	
	
	lift.close()
	await get_tree().create_timer(.5).timeout
	
	get_tree().call_group("enemy", "startMovement")
	
	time_counter.visible = true
	player.isTransformed = true


func on_counter_timeout():
	time_counter.queue_free()
	get_tree().call_group("enemy", "on_died")
	finish()
