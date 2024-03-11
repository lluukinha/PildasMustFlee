extends Node2D


@onready var injection_animation: AnimationPlayer = $InjectionAnimation
@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var scientist_sprite: AnimatedSprite2D = $ScientistSprite
@onready var injection: Node2D = $Injection
@onready var scientist_animation: AnimationPlayer = $ScientistAnimation
@onready var punch_animation_player: AnimationPlayer = $PunchAnimationPlayer
@onready var ability_text_ui: CanvasLayer = $AbilityTextUI
@onready var press_to_continue_label: Label = $AbilityTextUI/MarginContainer/VBoxContainer/PressToContinueLabel
@onready var fist_sprite: Sprite2D = $FistSprite

@onready var player_hit_flash_component: HitFlashComponent = $PlayerHitFlashComponent
@onready var scientist_hit_flash_component: HitFlashComponent = $ScientistHitFlashComponent


@onready var ability_name_label: Label = %AbilityNameLabel
@onready var ability_tip_label: Label = %AbilityTipLabel

const HEALTH_BAR = preload("res://powerups/health_bar.tres")
const FIST = preload("res://powerups/fist.tres")

var powerUp: PowerUp
var canContinue: bool = false

func _ready():
	fist_sprite.visible = false
	powerUp = GameEvents.get_power_up() as PowerUp
	
	ability_name_label.text = powerUp.name
	ability_tip_label.text = powerUp.description
	
	ability_text_ui.visible = false
	injection.visible = false
	
	if powerUp.id == FIST.id:
		player_sprite.play("angry")
	
	startAnimation()


func startAnimation():
	await get_tree().create_timer(1).timeout
	scientist_sprite.play("side")
	await get_tree().create_timer(.5).timeout
	player_sprite.play("back")
	await get_tree().create_timer(1).timeout
	injection_animation.play("apply")
	await get_tree().create_timer(1).timeout
	injection_animation.play_backwards("apply")
	await get_tree().create_timer(1.2).timeout
	injection.visible = false
	
	if powerUp.id == FIST.id:
		player_sprite.play("angry")
	else:
		player_sprite.play("default")
	
	await get_tree().create_timer(.5).timeout
	
	if powerUp.id == HEALTH_BAR.id || powerUp.id == FIST.id:
		fist_sprite.visible = !fist_sprite.visible
		punch_animation_player.play("punch")
		await get_tree().create_timer(.1).timeout
		player_hit_flash_component.flash()
		await get_tree().create_timer(.2).timeout
		fist_sprite.visible = !fist_sprite.visible
		await get_tree().create_timer(.3).timeout
		fist_sprite.visible = !fist_sprite.visible
		punch_animation_player.play("punch")
		player_hit_flash_component.flash()
		await get_tree().create_timer(.2).timeout
		fist_sprite.visible = !fist_sprite.visible
		await get_tree().create_timer(.3).timeout
		fist_sprite.visible = !fist_sprite.visible
		punch_animation_player.play("punch")
		player_hit_flash_component.flash()
		await get_tree().create_timer(.2).timeout
		fist_sprite.visible = !fist_sprite.visible
		await get_tree().create_timer(.5).timeout
		
		if powerUp.id == FIST.id:
			player_sprite.play("aberration")
		else:
			player_sprite.play("angry")
	
	if powerUp.id != FIST.id:
		endAnimation()
	else:
		killScientist()

func endAnimation():
	scientist_sprite.play("leave")
	scientist_animation.play("scientist_leave")
	await get_tree().create_timer(1).timeout
	ability_text_ui.visible = true
	GameEvents.up_level(powerUp)
	canContinue = true


func killScientist():
	await get_tree().create_timer(1).timeout
	fist_sprite.scale.x = 1
	
	fist_sprite.visible = !fist_sprite.visible
	punch_animation_player.play_backwards("punch")
	await get_tree().create_timer(.1).timeout
	scientist_hit_flash_component.flash()
	await get_tree().create_timer(.2).timeout
	fist_sprite.visible = !fist_sprite.visible
	await get_tree().create_timer(.3).timeout
	fist_sprite.visible = !fist_sprite.visible
	punch_animation_player.play_backwards("punch")
	scientist_hit_flash_component.flash()
	await get_tree().create_timer(.2).timeout
	fist_sprite.visible = !fist_sprite.visible
	await get_tree().create_timer(.3).timeout
	fist_sprite.visible = !fist_sprite.visible
	punch_animation_player.play_backwards("punch")
	scientist_hit_flash_component.flash()
	await get_tree().create_timer(.4).timeout
	scientist_sprite.visible = false
	GameEvents.up_level(powerUp)
	ability_text_ui.visible = true
	canContinue = true
	

func _unhandled_key_input(event):
	if event.is_pressed() && canContinue:
		ScreenTransition.transition_to_scene("res://scenes/levels/Level0.tscn")
