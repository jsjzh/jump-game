extends CharacterBody2D

class_name Player

enum Status {
	IDLE,
	RUN,
	JUMP,
	# ROLL,
	DEAD,
}

@export_category("玩家状态")
@export var initial_status: Status = Status.IDLE
@export var debug_display_status: bool = true

@export_category("玩家属性")
@export var run_speed: float = 150.0 ## 移动速度
@export var run_time: float = 0.2 ## 移动缓停时间
@export var jump_velocity: float = 300.0 ## 跳跃高度
@export var jump_max_count: int = 2 ## 跳跃次数
@export var roll_speed: float = 200.0 ## 翻滚速度
@export var roll_time: float = 0.5 ## 翻滚缓停时间

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var roll_timer: Timer = $RollTimer
@onready var status_label: Label = $StatusLabel

@onready var audio_dead: AudioStreamPlayer = $Audio/Dead
@onready var audio_jump: AudioStreamPlayer = $Audio/Jump
@onready var audio_roll: AudioStreamPlayer = $Audio/Roll
@onready var audio_run: AudioStreamPlayer = $Audio/Run

var current_status: Status = initial_status
var previous_status: Status = initial_status
var current_jump_count: int = 0
var is_facing_right: bool = true
# 原先是把 roll 放在 status 状态里维护
# 但是想想，我为什么不能在 jump 的过程中 roll，那我如果在天空 roll 了
# 那我应该是 jump 态还是 roll 态？
# 所以，我还是把这个当成是标志位来处理
var is_roll: bool = false

var status_timer: float = 0.0

func _ready():
	enter_status(current_status)

	if debug_display_status:
		update_status_label()

func _process(delta):
	if status_timer > 0:
		status_timer -= delta

	match current_status:
		Status.IDLE:
			handle_idle(delta)
		Status.RUN:
			handle_run(delta)
		Status.JUMP:
			handle_jump(delta)
		Status.DEAD:
			handle_dead(delta)

	if debug_display_status:
		update_status_label()

func _physics_process(delta: float) -> void:
	match current_status:
		Status.IDLE:
			pass
		Status.RUN:
			velocity.x = move_toward(velocity.x, 0, roll_speed / run_time * delta)
		Status.JUMP:
			pass

	apply_gravity(delta)
	move_and_slide()

func handle_idle(_delta: float):
	var input_direction = get_input_direction()

	if input_direction != 0 and is_on_floor():
		change_status(Status.RUN)
	elif Input.is_action_just_pressed("jump") and is_on_floor():
		change_status(Status.JUMP)
	# elif Input.is_action_just_pressed("roll") and is_on_floor():
		# change_status(Status.ROLL)

	if input_direction != 0:
		change_facing_direction(input_direction > 0)

func handle_run(_delta: float):
	var input_direction = get_input_direction()

	velocity.x = input_direction * run_speed

	if input_direction == 0 and is_on_floor():
		change_status(Status.IDLE)
	elif Input.is_action_just_pressed("jump") and is_on_floor():
		change_status(Status.JUMP)
	# elif Input.is_action_just_pressed("roll") and is_on_floor():
	# 	change_status(Status.ROLL)

	if input_direction != 0:
		change_facing_direction(input_direction > 0)

func handle_jump(_delta: float):
	var input_direction = get_input_direction()

	velocity.x = input_direction * run_speed * 0.8
	velocity.y = - jump_velocity

	if is_on_floor():
		if input_direction != 0:
			change_status(Status.RUN)
		elif input_direction == 0:
			change_status(Status.IDLE)
		# elif Input.is_action_just_pressed("roll"):
		# 	change_status(Status.ROLL)
	# else:
	# 	if Input.is_action_just_pressed("roll"):
	# 		change_status(Status.ROLL)

	if input_direction != 0:
		change_facing_direction(input_direction > 0)

func handle_roll(_delta: float):
	pass
	# var input_direction = get_input_direction()

	# var roll_direction = 1 if is_facing_right else -1
	# velocity.x = roll_direction * roll_speed

	# if is_on_floor():
	# 	change_status(Status.IDLE)
	# else:
	# 	change_status(Status.JUMP)

func handle_dead(_delta: float):
	pass

func change_status(new_status: Status):
	if current_status == new_status:
		return
	
	exit_status(current_status)

	previous_status = current_status
	current_status = new_status

	enter_status(new_status)

	print("switch status: %s -> %s" % [Status.keys()[previous_status], Status.keys()[current_status]])

func enter_status(status: Status):
	status_timer = 0.0

	match status:
		Status.IDLE:
			animated_sprite.play("idle")
			# status_timer = 0.2
		Status.RUN:
			animated_sprite.play("run")
			audio_run.play()
		Status.JUMP:
			animated_sprite.play("jump")
			audio_jump.play()
		# Status.ROLL:
		# 	animated_sprite.play("roll")
		# 	status_timer = roll_time
			# audio_roll.play()
		Status.DEAD:
			animated_sprite.play("dead")
			audio_dead.play()
			# velocity = Vector2.ZERO
			set_process_input(false)
			# set_collision_layer_value(1, false)
			# set_collision_mask_value(1, false)

func exit_status(status: Status):
	match status:
		pass

# func _physics_process(delta: float) -> void:
# 	# match current_status:
# 	# 	Status.DEAD:
# 	# 		handle_dead(delta)
# 	# 	Status.IDLE:
# 	# 		handle_idle(delta)
# 	# 	Status.JUMP:
# 	# 		handle_jump(delta)
# 	# 	Status.ROLL:
# 	# 		handle_roll(delta)
# 	# 	Status.RUN:
# 	# 		handle_run(delta)
# 	if current_status == Status.DEAD:
# 		if !is_on_floor():
# 			velocity.y += get_gravity().y * delta
# 		velocity.x = 0
# 	else:
# 		# 如果不在地面上，就施加重力
# 		if !is_on_floor():
# 			if Input.is_action_just_pressed("jump") and current_jump_count < jump_max_count:
# 				audio_jump.play()
# 				current_jump_count += 1
# 				velocity.y = - jump_velocity
# 			velocity.y += get_gravity().y * delta
# 		else:
# 			current_jump_count = 0
# 			if Input.is_action_just_pressed("jump"):
# 				audio_jump.play()
# 				velocity.y = - jump_velocity
# 				current_jump_count += 1
# 			if Input.is_action_just_pressed("roll"):
# 				if current_status != Status.ROLL:
# 					current_status = Status.ROLL
# 					roll_timer.start(roll_time)

# 		var direction = Input.get_axis("left", "right")

# 		if direction:
# 			if current_status == Status.ROLL:
# 				# 这里不需要乘以 delta，因为下面的 move_and_slide() 会自动乘以 delta
# 				velocity.x = direction * roll_speed
# 			else:
# 				# 这里不需要乘以 delta，因为下面的 move_and_slide() 会自动乘以 delta
# 				velocity.x = direction * run_speed
# 			if direction > 0:
# 					animated_sprite.flip_h = false
# 			else:
# 				animated_sprite.flip_h = true
# 		else:
# 			if current_status == Status.ROLL:
# 				# 这里需要乘以 delta，因为我算的是加速度，而加速度是每帧的加速度，所以需要乘以 delta
# 				velocity.x = move_toward(velocity.x, 0, roll_speed / roll_time * delta)
# 			else:
# 				# 这里需要乘以 delta，因为我算的是加速度，而加速度是每帧的加速度，所以需要乘以 delta
# 				velocity.x = move_toward(velocity.x, 0, run_speed / run_time * delta)

# 	move_and_slide()
# 	play_animate(velocity)

# ============================== 工具函数 ==============================

func get_input_direction() -> float:
	return Input.get_axis("left", "right")

func change_facing_direction(facing_right: bool):
	if is_facing_right != facing_right:
		is_facing_right = facing_right
		animated_sprite.flip_h = not is_facing_right

func apply_gravity(delta: float):
	if not is_on_floor():
			velocity.y += get_gravity().y * delta # 标准重力

# func play_animate(speed: Vector2):
# 	if current_status == Status.DEAD:
# 		return
# 	if is_on_floor():
# 		if speed.x != 0:
# 			if current_status == Status.ROLL:
# 				animated_sprite.play("roll")
# 			else:
# 				animated_sprite.play("run")
# 		else:
# 			animated_sprite.play("idle")
# 	else:
# 		animated_sprite.play("jump")

func update_status_label():
	if status_label:
		status_label.text = "status: %s velocity.x: %.1f velocity.y: %.1f is_on_floor %s" % [Status.keys()[current_status], velocity.x, velocity.y, is_on_floor()]

# ============================== 外部接口 ==============================

func _on_roll_timer_timeout() -> void:
	current_status = Status.IDLE

func on_attack_by_slime() -> void:
	current_status = Status.DEAD
	animated_sprite.play("dead")
	audio_dead.play()
