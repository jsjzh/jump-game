extends CharacterBody2D

enum PlayStatus {
	DEAD,
	IDLE,
	JUMP,
	ROLL,
	RUN,
}

@export var SPEED = 150
@export var JUMP_VELOCITY = -300

@export var state: Dictionary = {
	"status": PlayStatus.IDLE,
}

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	handleJump()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func handleJump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		pass

func on_attack_by_slime() -> void:
	animated_sprite.play("dead")
