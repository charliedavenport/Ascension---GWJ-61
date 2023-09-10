extends CharacterBody2D
class_name Player

enum Direction {SE, SW, NE, NW}
var dir : Direction:
	set(value):
		if dir == value:
			return
		var old_val = dir
		dir = value
		dir_updated(old_val, value)

enum PlayerState {Idle, Run, Attack, Hurt}
var state : PlayerState:
	set(value):
		if state == value:
			return
		var old_val = state
		state = value
		state_updated(old_val, value)

var max_speed = 40.0
var accel = 7.5
var decel = 0.25

@onready var anim = $AnimationPlayer
@onready var sprite = $Sprite2D

func _ready():
	state = PlayerState.Idle
	dir = Direction.SE


func _physics_process(delta):
	var input_direction = Vector2(Input.get_axis("Left", "Right"), Input.get_axis("Up", "Down"))
	
	if input_direction == Vector2.ZERO:
		velocity = velocity.lerp(Vector2.ZERO, decel)
		if velocity.length() < 1.0:
			state = PlayerState.Idle
	else:
		velocity += input_direction.normalized() * accel
		if velocity.length() > 1.0:
			state = PlayerState.Run
	
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	
	move_and_slide()
	
	if velocity.angle() < -PI/2.0:
		dir = Direction.NW
	elif velocity.angle() < 0.0:
		dir = Direction.NE
	elif velocity.angle() < PI/2.0:
		dir = Direction.SE
	else:
		dir = Direction.SW


func dir_updated(old_dir, new_dir) -> void:
	anim.play(get_animation_name(state, dir))


func state_updated(old_state, new_state) -> void:
	anim.play(get_animation_name(state, dir))


func get_animation_name(_state, _dir) -> String:
	var anim_name : String
	match _state:
		PlayerState.Idle:
			anim_name = "idle"
		PlayerState.Run:
			anim_name = "run"
	match _dir:
		Direction.SE:
			anim_name += "_SE"
		Direction.SW:
			anim_name += "_SW"
		Direction.NE:
			anim_name += "_NE"
		Direction.NW:
			anim_name += "_NW"
	return anim_name
