extends CanvasLayer
class_name FullScreenTextUI

signal start

@export var labelText: String
@export var pressKeylabelText: String = "Press spacebar to start"

@onready var press_any_key_label: Label = %PressAnyKeyLabel
@onready var level_description_label: Label = %LevelDescriptionLabel

func _ready():
	level_description_label.text = labelText
	press_any_key_label.text = pressKeylabelText
	pressKeylabelText
	get_tree().paused = true


func _unhandled_key_input(event):
	if event.is_action("Jump"):
		get_tree().paused = false
		start.emit()
		queue_free()
