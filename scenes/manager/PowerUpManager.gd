extends Node
class_name PowerUpManager

@export var resources: Array[PowerUp]


func get_power_up_ids():
	return resources.map(
		func (resource: PowerUp):
			return resource.id
	)
