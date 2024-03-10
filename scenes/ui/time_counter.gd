extends CanvasLayer
class_name TimeCounter

signal timeout

@export var timer_in_seconds: int = 5
@export var backwards: bool = false

@onready var time_label: Label = %TimeLabel
@onready var timer: Timer = $Timer

var counter = 0

func _ready():
	if backwards:
		counter = timer_in_seconds
	
	format_counter_to_string()
	timer.timeout.connect(on_timer_timeout)


func on_timer_timeout():
	if backwards:
		counter -= 1
	else:
		counter += 1
	
	format_counter_to_string()
	
	if (backwards && counter < 0 || !backwards && counter > timer_in_seconds):
		timer.stop()
		timeout.emit()


func format_counter_to_string():
	time_label.text = "%02d" % counter
