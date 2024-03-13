extends Node2D

@onready var lift: Lift = %Lift
@onready var camera_animation: AnimationPlayer = $CameraAnimation
@onready var player: Player = $Foreground/Player

const floor_clear_scene = preload("res://scenes/ui/floor_clear.tscn")
const full_screen_text_ui_scene = preload("res://scenes/ui/full_screen_text_ui.tscn")

var levelClear = false

func _ready():
	player.visible = false
	player.canMove = false
	get_tree().call_group("enemy", "stopMovement")
	
	var start_text_instance = full_screen_text_ui_scene.instantiate() as FullScreenTextUI
	start_text_instance.labelText = "Kill all Scientists!"
	start_text_instance.pressKeylabelText = "Press [space] to start, [z] to attack"
	add_child(start_text_instance)
	start_text_instance.start.connect(on_start_level)

	player.died.connect(on_player_died)
	lift.level_up.connect(on_level_up)


func _process(_delta):
	var enemies = get_tree().get_nodes_in_group("enemy").size()
	if enemies == 0:
		if !levelClear:
			levelClear = true
			finish()

func on_level_up():
	camera_animation.play("lift_up")
	await get_tree().create_timer(1).timeout
	GameEvents.finishGame()
	ScreenTransition.transition_to_scene("res://scenes/ui/screen_text_between_levels_ui.tscn")


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
	
	player.isTransformed = true
