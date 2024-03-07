extends Node2D
class_name DashPowerUpController

signal DashFinish

@onready var timer: Timer = $Timer

const COOLDOWN = .5

var is_dashing = false

func _ready():
	timer.timeout.connect(on_timer_timeout)


func start_dash(duration: float):
	timer.wait_time = duration
	timer.start()
	is_dashing = true


func on_timer_timeout():
	DashFinish.emit()
	await get_tree().create_timer(COOLDOWN).timeout
	is_dashing = false
