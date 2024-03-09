extends CanvasLayer

@onready var progress_bar: ProgressBar = %ProgressBar

@export var player: Player

func _ready():
	on_player_health_changed()
	player.health_component.health_changed.connect(on_player_health_changed)


func on_player_health_changed():
	progress_bar.value = player.health_component.get_health_percent()
