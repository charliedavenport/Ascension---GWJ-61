extends CharacterBody2D
class_name Player

var max_speed = 50.0
var accel = 8.5
var decel = 0.25

var fall_accell = 10.0
var max_fall_speed = 75.0

var has_control : bool
var lock_state : bool

@onready var anim = $AnimationPlayer
@onready var orc_sprite = $OrcSprite
@onready var shadow_sprite = $ShadowSprite


enum Direction {SE, SW, NE, NW}
var dir : Direction:
	set(value):
		if dir == value or lock_state:
			return
		var old_val = dir
		dir = value
		dir_updated(old_val, value)

enum PlayerState {Idle, Run, Attack, Hurt, Ascend, Fall}
var state : PlayerState:
	set(value):
		if state == value or lock_state:
			return
		var old_val = state
		state = value
		state_updated(old_val, value)


signal finished_ascending()


func _ready():
	state = PlayerState.Idle
	dir = Direction.SE
	has_control = true
	lock_state = false


func _physics_process(delta):
	var input_direction : Vector2
	
	if state == PlayerState.Attack:
		input_direction = Vector2.ZERO
	else:
		input_direction = Vector2(Input.get_axis("Left", "Right"), Input.get_axis("Up", "Down"))
	
	if input_direction == Vector2.ZERO:
		velocity = velocity.lerp(Vector2.ZERO, decel)
		if velocity.length() < 1.0 and state == PlayerState.Run:
			state = PlayerState.Idle
	else:
		velocity += input_direction.normalized() * accel
		if velocity.length() > 1.0 and state == PlayerState.Idle:
			state = PlayerState.Run
	
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	
	if has_control:
		move_and_slide()
		
		if velocity.angle() < -PI/2.0:
			dir = Direction.NW
		elif velocity.angle() < 0.0:
			dir = Direction.NE
		elif velocity.angle() < PI/2.0:
			dir = Direction.SE
		else:
			dir = Direction.SW


func _input(event):
	if event.is_action_pressed("attack"):
		state = PlayerState.Attack


func dir_updated(old_dir, new_dir) -> void:
	anim.play(get_animation_name(state, dir))


func state_updated(old_state, new_state) -> void:
	anim.play(get_animation_name(state, dir))


func ascend() -> void:
	# TODO set state
	# TODO directional ascend anim
	anim.play("ascend")
	has_control = false
	lock_state = true


func fall()-> void:
	anim.play("fall")
	shadow_sprite.hide()
	has_control = false
	lock_state = true
	
	# TODO directional fall anim
	state = PlayerState.Fall


func get_animation_name(_state, _dir) -> String:
	var anim_name : String
	match _state:
		PlayerState.Idle:
			anim_name = "idle"
		PlayerState.Run:
			anim_name = "run"
		PlayerState.Attack:
			anim_name = "atk"
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


func on_atk_finished() -> void:
	state = PlayerState.Idle


func on_ascend_finished() -> void:
	finished_ascending.emit()
	lock_state = false
	state = PlayerState.Idle
