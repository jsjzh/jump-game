extends CharacterBody2D

enum PlayStatus {DEAD, IDLE, JUMP, ROLL, RUN, }

class Player:
	var current_status: int = PlayStatus.IDLE
	var run_speed: float = 100
	var run_reduce_speed: float = 10
	var jump_speed: float = 300
	var jump_count: int = 2
	var roll_speed: float = 150
	var roll_time: float = 0.5

	func _init():
		self.run_speed = self.run_speed * 100
		self.roll_speed = self.roll_speed * 100
		self.run_reduce_speed = self.run_reduce_speed * 100

var player = Player.new()

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# 如果不在地面上，就施加重力
	if !is_on_floor():
		if Input.is_action_just_pressed("jump") and player.jump_count > 0:
			player.jump_count -= 1
			velocity.y = - player.jump_speed
		velocity.y += get_gravity().y * delta
	else:
		player.jump_count = 2
		if Input.is_action_just_pressed("jump"):
			velocity.y = - player.jump_speed
			player.jump_count -= 1
		if Input.is_action_just_pressed("roll"):
			player.current_status = PlayStatus.ROLL
			await get_tree().create_timer(player.roll_time).timeout
			player.current_status = PlayStatus.IDLE
			pass

	var direction = Input.get_axis("left", "right")

	if direction:
		if player.current_status == PlayStatus.ROLL:
			velocity.x = direction * player.roll_speed * delta
		else:
			velocity.x = direction * player.run_speed * delta
		if direction > 0:
				animated_sprite.flip_h = false
		else:
			animated_sprite.flip_h = true
	else:
		velocity.x = move_toward(velocity.x, 0, player.run_reduce_speed * delta)

	play_animate(velocity)
	move_and_slide()

	if Input.is_action_just_pressed("attack"):
		print("attack")
		pass

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

func on_attack_by_slime() -> void:
	animated_sprite.play("dead")
