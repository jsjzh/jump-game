extends CharacterBody2D

enum PlayStatus {
	DEAD,
	IDLE,
	JUMP,
	ROLL,
	RUN,
}

@export var state: Dictionary = {
	"current_status": PlayStatus.IDLE,
	"run_speed": 100,
	"run_reduce_speed": 10,
	"jump_speed": 300,
}

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = - state.get("jump_speed")
	else:
		velocity.y += get_gravity().y * delta
		animated_sprite.play("jump")

	var direction = Input.get_axis("left", "right")

	if direction:
		velocity.x = direction * state.get("run_speed") * 100 * delta
		if direction > 0:
				animated_sprite.flip_h = false
		else:
			animated_sprite.flip_h = true
	else:
		velocity.x = move_toward(velocity.x, 0, state.get("run_reduce_speed") * 100 * delta)

	if is_on_floor():
		if velocity.x != 0:
			animated_sprite.play("run")
		else:
			animated_sprite.play("idle")

	move_and_slide()

func on_attack_by_slime() -> void:
	animated_sprite.play("dead")
