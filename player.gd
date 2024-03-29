extends CharacterBody2D
class_name Player

signal died

const NORMAL_SPEED = 300.0
const DASH_SPEED = NORMAL_SPEED * 5
const JUMP_VELOCITY = -500.0

const DASH: PowerUp = preload("res://powerups/dash.tres")
const DOUBLE_JUMP: PowerUp = preload("res://powerups/double_jump.tres")
const FIST: PowerUp = preload("res://powerups/fist.tres")
const HEALTH_BAR: PowerUp = preload("res://powerups/health_bar.tres")
const FIST_SCENE = preload("res://scenes/powerups/fist.tscn")

@onready var damage_interval_timer: Timer = $DamageIntervalTimer
@onready var power_up_manager: PowerUpManager = %PowerUpManager
@onready var visuals: Node2D = %Visuals
@onready var health_component: HealthComponent = $HealthComponent
@onready var enemy_hurtbox_area: Area2D = %EnemyHurtboxArea
@onready var hud: HUD = $HUD
@onready var vignette: Vignette = $Vignette
@onready var collision_shape_2d: CollisionShape2D = $EnemyHurtboxArea/CollisionShape2D

@onready var angry_body_animation: AnimatedSprite2D = %AngryBodyAnimation
@onready var normal_body_animation: AnimatedSprite2D = %NormalBodyAnimation
@onready var aberration_body_animation: AnimatedSprite2D = %AberrationBodyAnimation


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var body_animation: AnimatedSprite2D

var number_colliding_bodies = 0
var isFacingLeft = false
var jumpCount = 0
var maxJumps = 1
var speed = NORMAL_SPEED
var isTransformed = false
var canMove = true

var canDoubleJump = false
var canDash = false
var canAttack = false
var canUseHealthBar = false

func _ready():
	var powerUpsCount = GameEvents.playerPowerUps.size()
	if powerUpsCount == 3:
		body_animation = angry_body_animation
		normal_body_animation.visible = false
		aberration_body_animation.visible = false
	else:
		body_animation = normal_body_animation
		angry_body_animation.visible = false
		aberration_body_animation.visible = false
	
	if powerUpsCount > 2:
		hud.visible = true
	else:
		hud.visible = false
	
	loadPowerUps()
	enemy_hurtbox_area.body_entered.connect(on_body_entered)
	enemy_hurtbox_area.body_exited.connect(on_body_exited)
	on_player_health_changed()
	health_component.health_changed.connect(on_player_health_changed)
	damage_interval_timer.timeout.connect(takeDamage)


func on_player_health_changed():
	hud.setProgressBarValue(health_component.get_health_percent())


func on_body_exited(other_body: Node2D):
	if "dealDamage" in other_body && other_body.dealDamage == true:
		number_colliding_bodies -= 1


func on_body_entered(other_body: Node2D):
	if "dealDamage" in other_body && other_body.dealDamage == true:
		if canUseHealthBar:
			number_colliding_bodies += 1
			takeDamage()
		else:
			vignette.on_game_over()
			died.emit()
	
	if other_body is Lever:
		other_body.pull_lever()


func takeDamage():
	if number_colliding_bodies == 0 || !damage_interval_timer.is_stopped() || !health_component:
		return
	
	if (health_component.current_health <= 0):
		vignette.on_game_over()
		died.emit()
	else:
		health_component.damage(1)
		vignette.on_player_damaged()
		damage_interval_timer.start()


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
	power_up_manager.resources = GameEvents.playerPowerUps
	for power_up in power_up_manager.resources:
		if (power_up.id == DOUBLE_JUMP.id):
			canDoubleJump = true
			maxJumps = 2
		
		elif (power_up.id == DASH.id):
			canDash = true
			var dashController = power_up.controller.instantiate() as DashPowerUpController
			get_tree().get_first_node_in_group("power_up_controllers").add_child(dashController)
			dashController.DashFinish.connect(on_dash_finish)
		
		elif (power_up.id == HEALTH_BAR.id):
			canUseHealthBar = true
			hud.visible = true
			angry_body_animation.visible = true
			normal_body_animation.visible = false
			body_animation = angry_body_animation
		
		elif (power_up.id == FIST.id):
			canAttack = true
			angry_body_animation.visible = false
			normal_body_animation.visible = false
			aberration_body_animation.visible = true
			body_animation = aberration_body_animation


func attack():
	if !isTransformed:
		return
	
	var fistInstance = FIST_SCENE.instantiate()
	var player = get_tree().get_first_node_in_group("player") as Player
	get_tree().get_first_node_in_group("powerups").add_child(fistInstance)
	if (isFacingLeft):
		fistInstance.global_position = player.global_position - Vector2(50, 50)
		fistInstance.scale = Vector2(-1, 1)
	else:
		fistInstance.global_position = player.global_position - Vector2(-50, 50)


func on_dash_finish():
	speed = NORMAL_SPEED
