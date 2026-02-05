extends CharacterBody2D

class_name Player

@export_category("调试状态")
@export var debug_display_status: bool = true

@export_category("玩家属性")
@export var run_speed: float = 180.0 ## 移动速度
@export var jump_velocity: float = 300.0 ## 跳跃高度
@export var jump_max_count: int = 2 ## 跳跃次数
@export var roll_speed: float = 220.0 ## 翻滚速度
@export var roll_time: float = 0.3 ## 翻滚缓停时间，这个时间必须和动画的时间匹配，比如动画有 5 个动画帧，那就意味着要 0.2 秒播完 5 个动画帧，等于 1 秒播完 25 个动画帧，也就是需要配置 animate_sprite 为 25FPS

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var status_label: Label = $StatusLabel

@onready var audio_dead: AudioStreamPlayer = $Audio/Dead
@onready var audio_jump: AudioStreamPlayer = $Audio/Jump
@onready var audio_roll: AudioStreamPlayer = $Audio/Roll
@onready var audio_run: AudioStreamPlayer = $Audio/Run

var input_direction: Vector2 = Vector2.ZERO
var is_dead: bool = false
var is_jumping: bool = false
var jump_count: int = 0
var is_rolling: bool = false
var roll_duration: float = 0.0

func _input(event):
	if is_dead:
		return

	if event.is_action_pressed("jump"):
		if is_on_floor() or jump_count < jump_max_count:
			is_jumping = true
			jump_count += 1
			audio_jump.play()
	if event.is_action_released("roll"):
		if is_on_floor():
			roll_duration = roll_time
			is_rolling = true
			audio_roll.play()

func _process(_delta):
	if is_dead:
		return

	input_direction.x = Input.get_axis("left", "right")

	if debug_display_status:
		update_status_label()

func _physics_process(delta):
	if is_dead:
		if !is_on_floor():
			velocity.x = 0
			velocity.y += get_gravity().y * delta
			move_and_slide()
		return

	if is_rolling:
		roll_duration -= delta

	if is_jumping:
		velocity.y = - jump_velocity

	if is_rolling:
		velocity.x = (-1 if animated_sprite.flip_h else 1) * roll_speed
	else:
		velocity.x = input_direction.x * run_speed

	if !is_on_floor():
		velocity.y += get_gravity().y * delta

	if input_direction.x < 0:
		animated_sprite.flip_h = true
	elif input_direction.x > 0:
		animated_sprite.flip_h = false

	if is_on_floor():
		if is_rolling:
			animated_sprite.play("roll")
		elif input_direction.x == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
			audio_run.play()
	else:
		animated_sprite.play("jump")

	move_and_slide()

	is_jumping = false

	if is_on_floor():
		jump_count = 0

	if roll_duration <= 0:
		is_rolling = false

func update_status_label():
	if status_label:
		status_label.text = "velocity.x: %.1f velocity.y: %.1f is_on_floor %s" % [velocity.x, velocity.y, is_on_floor()]

func on_attack_by_slime() -> void:
	is_dead = true
	animated_sprite.play("dead")
	audio_dead.play()
