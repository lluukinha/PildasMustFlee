extends Node2D

@onready var lift: Lift = %Lift

const floor_clear_scene = preload("res://scenes/ui/floor_clear.tscn")

var enemiies_killed = 0

func _ready():
	GameEvents.enemy_died.connect(on_enemy_died)


func _process(delta):
	if (enemiies_killed == 2):
		finish()


func finish():
	enemiies_killed = 0
	await get_tree().create_timer(.5).timeout
	
	var floor_clear_instance = floor_clear_scene.instantiate()
	get_tree().get_first_node_in_group("foreground_layer").add_child(floor_clear_instance)
	await get_tree().create_timer(2.0).timeout

	lift.open()
	

func on_enemy_died():
	enemiies_killed +=1
	print(enemiies_killed)
