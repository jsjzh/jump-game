extends Area2D

@export var flight_time: float = 2.0
@export var speed: float = 300.0

# TODO 射箭音效

var is_shooted: bool = false
var direction: Vector2
var current_flight_time: float = 0.0

func _process(delta):
	if is_shooted:
		current_flight_time += delta
		if current_flight_time >= flight_time:
			queue_free()

func _physics_process(delta: float) -> void:
	if is_shooted:
		position += speed * direction * delta

func handle_shoot(dire: Vector2) -> void:
	direction = dire
	is_shooted = true

func handle_position(pos: Vector2) -> void:
	position = pos

func handle_rotation(angle: float) -> void:
	rotation = angle
