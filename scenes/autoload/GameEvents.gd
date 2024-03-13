extends Node

signal experience_vial_collected(number: float)
signal ability_upgrade_added(upgrade, current_upgrades: Dictionary)
signal player_damaged
signal enemy_died

var player: Player
var level: int = 0
var startedGame = false
var endGame = false

const DOUBLE_JUMP = preload("res://powerups/double_jump.tres")
const DASH = preload("res://powerups/dash.tres")
const FIST = preload("res://powerups/fist.tres")
const HEALTH_BAR = preload("res://powerups/health_bar.tres")

var powerUps = [
	DOUBLE_JUMP,
	DASH,
	HEALTH_BAR,
	FIST
]

var playerPowerUps: Array[PowerUp] = []

func up_level(newPowerUp: PowerUp):
	playerPowerUps.append(newPowerUp)
	level += 1


func finishGame():
	endGame = true


func get_power_up():
	return powerUps[level]


func emit_experience_vial_collected(number: float):
	experience_vial_collected.emit(number)


func emit_ability_upgrade_added(upgrade, current_upgrades: Dictionary):
	ability_upgrade_added.emit(upgrade, current_upgrades)


func emit_player_damaged():
	player_damaged.emit()


func emit_enemy_died():
	enemy_died.emit()


