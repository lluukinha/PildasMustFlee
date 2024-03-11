extends CanvasLayer
class_name HUD

@onready var progress_bar: ProgressBar = %ProgressBar

func setProgressBarValue(newValue: float):
	progress_bar.value = newValue
