extends Node2D

@onready var player : Player = $Player
@onready var cam : Camera2D = $Camera2D

var levels = []

var curr_level_ind : int

var curr_level : Level:
	get:
		return levels[curr_level_ind]

func _ready() -> void:
	levels = $Levels.get_children()
	levels.sort_custom(func(a,b): return a.index < b.index)
	
	curr_level_ind = 0
	for level in $Levels.get_children():
		level.disable()
	$Levels/Level_0.enable()
	
	Events.player_reached_star.connect(on_player_reached_star)
	
	RenderingServer.set_default_clear_color(Color.BLACK)


func _physics_process(delta : float) -> void:
	var player_pos = player.global_position
	var player_tile = curr_level.local_to_map(curr_level.to_local(player_pos))
	if curr_level.get_cell_source_id(0, player_tile) != 2:
		pass

func level_updated() -> void:
	for level in $Levels.get_children():
		if level.index == curr_level_ind:
			level.enable()
		else:
			level.disable()


func on_player_reached_star() -> void:
	player.ascend()
	await player.finished_ascending
	
	var next_level = levels[curr_level_ind + 1]
	next_level.modulate = Color("FFFFFF00")
	next_level.enable()
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(cam, "position", cam.position + Vector2.UP * 56, 1.0)
	# I have to do this in a shader
	tween.tween_property(curr_level, "modulate:a", 0.0, 1.0)
	tween.tween_property(next_level, "modulate:a", 1.0, 1.0)
	
	await tween.finished
	
	curr_level.disable()
	curr_level.modulate = Color.WHITE
	curr_level_ind += 1
	
	player.orc_sprite.show()
	player.global_position = $Levels.get_child(curr_level_ind).player_spawn.global_position
	player.has_control = true
	
