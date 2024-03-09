extends Node2D
class_name Lift

signal level_up

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $Area2D/CollisionShape2D
@onready var area_2d: Area2D = $Area2D


var can_enter = false

# Called when the node enters the scene tree for the first time.
func _ready():
	area_2d.body_entered.connect(on_body_entered)
	area_2d.body_exited.connect(on_body_exited)


func _process(delta):
	if Input.is_action_just_pressed("UP") && can_enter:
		close_and_transitionate()


func open():
	animated_sprite_2d.play("open")
	await get_tree().create_timer(.5).timeout
	animated_sprite_2d.play("opened")
	collision.disabled = false


func close_and_transitionate():
	var player = get_tree().get_first_node_in_group("player") as Player
	if player == null:
		return
	
	animated_sprite_2d.play("close")
	player.visible = false
	player.canMove = false
	await get_tree().create_timer(.5).timeout
	animated_sprite_2d.play("closed")
	await get_tree().create_timer(.5).timeout
	level_up.emit()


func on_body_entered(body: Node2D):
	if body is Player:
		can_enter = true


func on_body_exited(body: Node2D):
	if body is Player:
		can_enter = false
