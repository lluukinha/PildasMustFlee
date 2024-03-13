extends CanvasLayer


@onready var beggining_label: Label = %BegginingLabel
@onready var double_jump_label: Label = %DoubleJumpLabel
@onready var dash_label: Label = %DashLabel
@onready var health_bar_label: Label = %HealthBarLabel
@onready var aberration_label: Label = %AberrationLabel
@onready var finish_label: Label = %FinishLabel
@onready var show_bottom_timer: Timer = $ShowBottomTimer
@onready var restart_button: Button = %RestartButton
@onready var quit_button: Button = %QuitButton


@onready var press_any_key_label: Label = %PressAnyKeyLabel
@onready var buttons_h_box_container: HBoxContainer = %ButtonsHBoxContainer


const DOUBLE_JUMP = preload("res://powerups/double_jump.tres")
const DASH = preload("res://powerups/dash.tres")
const FIST = preload("res://powerups/fist.tres")
const HEALTH_BAR = preload("res://powerups/health_bar.tres")

var canMoveToNextLevel = false
var endGame = false
var nextLevelScene: String

func _ready():
	beggining_label.visible = false
	double_jump_label.visible = false
	dash_label.visible = false
	health_bar_label.visible = false
	aberration_label.visible = false
	finish_label.visible = false
	press_any_key_label.visible = false
	buttons_h_box_container.visible = false
	show_bottom_timer.timeout.connect(onTimerTimeout)
	restart_button.pressed.connect(onRestartPressed)
	quit_button.pressed.connect(onQuitPressed)
	
	if GameEvents.endGame:
		finish_label.visible = true
		buttons_h_box_container.visible = true
		endGame = true
	else:
		var powerUp = GameEvents.get_power_up()
		if !GameEvents.startedGame:
			beggining_label.visible = true
			GameEvents.startedGame = true
			nextLevelScene = "res://scenes/levels/Level0.tscn"
		elif powerUp.id == DOUBLE_JUMP.id:
			double_jump_label.visible = true
			nextLevelScene = "res://scenes/levels/Level1.tscn"
			GameEvents.up_level(powerUp)
		elif powerUp.id == DASH.id:
			dash_label.visible = true
			nextLevelScene = "res://scenes/levels/Level0.tscn"
			GameEvents.up_level(powerUp)
		elif powerUp.id == HEALTH_BAR.id:
			health_bar_label.visible = true
			nextLevelScene = "res://scenes/levels/Level1.tscn"
			GameEvents.up_level(powerUp)
		elif powerUp.id == FIST.id:
			aberration_label.visible = true
			nextLevelScene = "res://scenes/levels/Level4.tscn"
			GameEvents.up_level(powerUp)


func _unhandled_key_input(event):
	if event.is_action("Jump") && canMoveToNextLevel:
		ScreenTransition.transition_to_scene(nextLevelScene)


func onTimerTimeout():
	if !endGame:
		press_any_key_label.visible = true
		canMoveToNextLevel = true


func onRestartPressed():
	ScreenTransition.transition_to_scene("res://scenes/ui/menu.tscn")


func onQuitPressed():
	get_tree().quit()
