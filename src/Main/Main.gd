extends Node2D

@onready var player : Player = $Player
@onready var cam : Camera2D = $Camera2D

var levels = []

var curr_level : int:
	set(value):
		curr_level = value
		level_updated()

func _ready():
	levels = $Levels.get_children()
	levels.sort_custom(func(a,b): return a.index < b.index)
	
	curr_level = 0
	
	Events.player_reached_star.connect(on_player_reached_star)
	
	RenderingServer.set_default_clear_color(Color.BLACK)

func level_updated() -> void:
	for level in $Levels.get_children():
		level.enable() if level.index == curr_level else level.disable()


func on_player_reached_star() -> void:
	player.ascend()
	await player.finished_ascending
	
	
	#curr_level += 1
	#cam.translate(Vector2.UP * 56)
	
	var next_level = levels[curr_level + 1]
	#next_level.modulate = Color("FFFFFF00")
	next_level.show()
	
#	var tween = get_tree().create_tween()
#	tween.set_parallel(true)
#	tween.tween_property(cam, "position", cam.position + Vector2.UP * 56, 1.0)
#	# I have to do this in a shader
#	tween.tween_property(levels[curr_level], "modulate:a", 0.0, 1.0)
#	tween.tween_property(levels[curr_level+1], "modulate:a", 1.0, 1.0)
#
#	await tween.finished
	
	curr_level += 1
	
	cam.translate(Vector2.UP * 56)
	
	player.orc_sprite.show()
	player.global_position = $Levels.get_child(curr_level).player_spawn.global_position
	player.has_control = true
	
