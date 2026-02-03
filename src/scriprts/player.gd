extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var roll_timer: Timer = $RollTimer

enum PlayStatus {DEAD, IDLE, JUMP, ROLL, RUN}

class Player:
	var current_status: int = PlayStatus.IDLE
	var run_speed: float = 150.0
	var run_time: float = 0.2
	var jump_speed: float = 300.0
	var jump_max_count: int = 2
	var jump_count: int = 0
	var roll_speed: float = 200.0
	var roll_time: float = 0.5

var player = Player.new()

func _physics_process(delta: float) -> void:
	# 如果不在地面上，就施加重力
	if !is_on_floor():
		if Input.is_action_just_pressed("jump") and player.jump_count < player.jump_max_count:
			player.jump_count += 1
			velocity.y = - player.jump_speed
		velocity.y += get_gravity().y * delta
	else:
		player.jump_count = 0
		if Input.is_action_just_pressed("jump"):
			velocity.y = - player.jump_speed
			player.jump_count += 1
		if Input.is_action_just_pressed("roll"):
			if player.current_status != PlayStatus.ROLL:
				player.current_status = PlayStatus.ROLL
				roll_timer.start(player.roll_time)

	var direction = Input.get_axis("left", "right")

	if direction:
		if player.current_status == PlayStatus.ROLL:
			# 这里不需要乘以 delta，因为下面的 move_and_slide() 会自动乘以 delta
			velocity.x = direction * player.roll_speed
		else:
			# 这里不需要乘以 delta，因为下面的 move_and_slide() 会自动乘以 delta
			velocity.x = direction * player.run_speed
		if direction > 0:
				animated_sprite.flip_h = false
		else:
			animated_sprite.flip_h = true
	else:
		if player.current_status == PlayStatus.ROLL:
			# 这里需要乘以 delta，因为我算的是加速度，而加速度是每帧的加速度，所以需要乘以 delta
			velocity.x = move_toward(velocity.x, 0, player.roll_speed / player.roll_time * delta)
		else:
			# 这里需要乘以 delta，因为我算的是加速度，而加速度是每帧的加速度，所以需要乘以 delta
			velocity.x = move_toward(velocity.x, 0, player.run_speed / player.run_time * delta)

	move_and_slide()
	play_animate(velocity)

func play_animate(speed: Vector2):
	if is_on_floor():
		if speed.x != 0:
			if player.current_status == PlayStatus.ROLL:
				animated_sprite.play("roll")
			else:
				animated_sprite.play("run")
		else:
			animated_sprite.play("idle")
	else:
		animated_sprite.play("jump")

func _on_roll_timer_timeout() -> void:
	player.current_status = PlayStatus.IDLE

func on_attack_by_slime() -> void:
	animated_sprite.play("dead")
