extends CanvasLayer

@onready var button: Button = $MarginContainer/Button

func _ready():
	button.pressed.connect(on_button_pressed)


func on_button_pressed():
	ScreenTransition.transition_to_scene("res://scenes/levels/Level0.tscn")
