extends CharacterBody2D
class_name BasicEnemy

@onready var velocity_component = $VelocityComponent
@onready var visuals = $Visuals
@onready var animated_sprite_2d: AnimatedSprite2D = $Visuals/AnimatedSprite2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var canMove = true

func _ready():
	health_component.died.connect(on_died)


func _physics_process(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
		
	accelerate_to_player()
	
	var move_sign = sign(velocity.x)
	if move_sign != 0:
		visuals.scale = Vector2(-move_sign, 1)


func accelerate_to_player():
	var player = get_tree().get_first_node_in_group("player") as Player
	if player == null:
		return
	
	var direction = player.global_position.x - global_position.x
	if !player.isTransformed:
		direction = 0
	
	if direction > 0 || direction < 0:
		animated_sprite_2d.play("walk")
	else:
		animated_sprite_2d.play("default")
	
	accelerate_in_direction(direction)
	if canMove:
		move_and_slide()


func stopMovement():
	canMove = false


func startMovement():
	canMove = true


func accelerate_in_direction(direction: float):
	var desired_velocity = Vector2(direction, 1)
	velocity = velocity.lerp(desired_velocity, 1 - exp(-3 * get_process_delta_time()))


func on_died():
	canMove = false
	animation_player.play("die")
	await get_tree().create_timer(.5).timeout
	GameEvents.emit_enemy_died()
	queue_free()
