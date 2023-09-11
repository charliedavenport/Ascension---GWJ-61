extends TileMap
class_name Level

const star_scene = preload("res://src/Star/star.tscn")

@export var index : int

@onready var player_spawn = $PlayerSpawn
@onready var star_spawn = $StarSpawn

func enable() -> void:
	#show()
	for layer_ind in get_layers_count():
		set_layer_enabled(layer_ind, true)
	
	var star = star_scene.instantiate()
#	star.global_position = star_spawn.global_position
	add_child(star)
	star.position = star_spawn.position


func disable() -> void:
	#hide()
	for layer_ind in get_layers_count():
		set_layer_enabled(layer_ind, false)
