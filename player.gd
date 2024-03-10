extends CharacterBody2D
class_name Player

signal died

const NORMAL_SPEED = 300.0
const DASH_SPEED = NORMAL_SPEED * 5
const JUMP_VELOCITY = -500.0

const DASH: PowerUp = preload("res://powerups/dash.tres")
const DOUBLE_JUMP: PowerUp = preload("res://powerups/double_jump.tres")
const FIST: PowerUp = preload("res://powerups/fist.tres")
const FIST_SCENE = preload("res://scenes/powerups/fist.tscn")

@onready var power_up_manager: PowerUpManager = %PowerUpManager
@onready var fist: Sprite2D = $Visuals/fist
@onready var attack_animation: AnimationPlayer = $AttackAnimation
@onready var visuals: Node2D = %Visuals
@onready var health_component: HealthComponent = $HealthComponent
@onready var enemy_hurtbox_area: Area2D = %EnemyHurtboxArea

@onready var angry_body_animation: AnimatedSprite2D = %AngryBodyAnimation
@onready var normal_body_animation: AnimatedSprite2D = %NormalBodyAnimation



# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var body_animation: AnimatedSprite2D

var isFacingLeft = false
var jumpCount = 0
var maxJumps = 1
var speed = NORMAL_SPEED
var isTransformed = false
var canMove = true

var canDoubleJump = false
var canDash = false
var canAttack = false

func _ready():
	body_animation = normal_body_animation
	angry_body_animation.visible = false
	loadPowerUps()
	enemy_hurtbox_area.body_entered.connect(on_enemy_body_entered)


func on_enemy_body_entered(other_area: Node2D):
	if other_area is BasicEnemy:
		died.emit()


func _physics_process(delta):
	if is_on_floor():
		jumpCount = 0
	else:
		velocity.y += gravity * delta
	
	if canMove:
		handle_keys_pressed()
		move_and_slide()


func handle_keys_pressed():
	# Handle dash
	if  canDash && Input.is_action_just_pressed("Dash"):
		dash()
	
	# Handle jump.
	if Input.is_action_just_pressed("Jump"): #and is_on_floor():
		jump()
		
	# Handle attack
	if canAttack && Input.is_action_just_pressed("Attack"):
		attack()
	
	#if Input.is_action_just_pressed("Transform"):
		#isTransformed = !isTransformed
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("MoveLeft", "MoveRight")
	move_player(direction)


func jump():
	var canJump =  jumpCount < maxJumps
	if canJump:
		jumpCount += 1
		velocity.y = JUMP_VELOCITY


func dash():
	var dashController = get_tree().get_first_node_in_group("dash_power_up") as DashPowerUpController
	
	if (dashController != null && !dashController.is_dashing):
		dashController.start_dash(.2)
		if dashController.is_dashing:
			speed = DASH_SPEED
		else:
			speed = NORMAL_SPEED


func move_player(direction: float):
	if direction:
		velocity.x = direction * speed
		if sign(direction) < 0:
			body_animation.play("walk_left")
			isFacingLeft = true
		else:
			body_animation.play("walk")
			isFacingLeft = false
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		body_animation.play("default")
	

func loadPowerUps():
	for power_up in power_up_manager.resources:
		if (power_up.id == DOUBLE_JUMP.id):
			canDoubleJump = true
			maxJumps = 2
		
		elif (power_up.id == DASH.id):
			canDash = true
			var dashController = power_up.controller.instantiate() as DashPowerUpController
			get_tree().get_first_node_in_group("power_up_controllers").add_child(dashController)
			dashController.DashFinish.connect(on_dash_finish)
		
		elif (power_up.id == FIST.id):
			canAttack = true


func attack():
	if !isTransformed:
		return
	
	var fistInstance = FIST.instantiate()
	var player = get_tree().get_first_node_in_group("player") as Player
	get_tree().get_first_node_in_group("powerups").add_child(fistInstance)
	if (isFacingLeft):
		fistInstance.global_position = player.global_position - Vector2(50, 50)
		fistInstance.scale = Vector2(-1, 1)
	else:
		fistInstance.global_position = player.global_position - Vector2(-50, 50)


func on_dash_finish():
	speed = NORMAL_SPEED
