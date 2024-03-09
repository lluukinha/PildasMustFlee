extends CanvasLayer

@onready var timer: Timer = $Timer

func _ready():
	timer.timeout.connect(on_timer_timeout)


func on_timer_timeout():
	print("remove clear")
	queue_free()
